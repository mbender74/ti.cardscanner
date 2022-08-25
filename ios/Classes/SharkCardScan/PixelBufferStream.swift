//
//  PixelBufferStream.swift
//  SharkCardScan
//
//  Created by Gymshark on 04/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreImage

public protocol PixelBufferStream: AnyObject {
    var output: (CVPixelBuffer, CGImagePropertyOrientation) -> Void { get set }
    var running: Bool { get set }
    var toggleTorch: Bool { get set }

    var previewView: UIView { get }
    /// Non-locking main thread only
    func cameraRegion(forPreviewRegion previewRegion: CGRect) -> CGRect
}

public class CameraPixelBufferStream: NSObject, PixelBufferStream, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let capturerQueue = DispatchQueue(label: "ti.cardscanner")
    public var captureDevice : AVCaptureDevice!
    private let session = AVCaptureSession()
    private let writeSafe: WriteSafe
    private let contentView = LayerContentView(contentLayer: AVCaptureVideoPreviewLayer()).withAspectRatio(9.0 / 16.0)
    public let previewView = UIView()
    @ThreadSafe public var output: (CVPixelBuffer, CGImagePropertyOrientation) -> Void
    
    private var runningBacking = false
    public var running: Bool {
        get { writeSafe.perform { runningBacking } }
        set {
            writeSafe.perform {
                guard runningBacking != newValue else { return }
                runningBacking = newValue
                if newValue {
                    
                    if !session.isRunning {
                        capturerQueue.async {
                            self.session.startRunning()
                        }
                    }
                    
//                    session.startRunning()
                } else {
                    if session.isRunning {
                        capturerQueue.async {
                            self.session.stopRunning()
                        }
                    }
//                    session.stopRunning()
                }
            }
        }
    }
    
    
    public var toggleTorch: Bool {
        get {
            if (self.captureDevice != nil){

                if (self.captureDevice.torchMode == .on){
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
        }
        set {
            if (self.captureDevice != nil){
                if self.captureDevice.hasTorch {
                    do {
                        try self.captureDevice.lockForConfiguration()

                        if newValue == true {
                            self.captureDevice.torchMode = .on
                        } else {
                            self.captureDevice.torchMode = .off
                        }

                        self.captureDevice.unlockForConfiguration()
                    } catch {
                    }
                } else {
                }
            }
        }
    }
    
    
    public override init() {
        let writeSafe = WriteSafe()
        self.writeSafe = writeSafe
        self._output = ThreadSafe(wrappedValue: { _, _ in }, writeSafe: writeSafe)
        
        super.init()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        self.captureDevice = device
        session.sessionPreset = device.supportsSessionPreset(.hd4K3840x2160) ? .hd4K3840x2160 : .hd1920x1080
        
        try? device.lockForConfiguration()
        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
        }
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        if device.isLowLightBoostSupported {
            device.automaticallyEnablesLowLightBoostWhenAvailable = true
        }
        if device.isTorchModeSupported(.auto) {
            device.torchMode = .auto
        }
        device.unlockForConfiguration()
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        session.addInputWithNoConnections(input)
        
        let output = AVCaptureVideoDataOutput()
        // sampleBufferDelegate is weak but I dont see that documented anywhere
        
    //    capturerQueue
//        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.gymshark.cardscan.SampleBufferDelegate", qos: .userInteractive))

        output.setSampleBufferDelegate(self, queue: capturerQueue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        
        guard session.canAddOutput(output) else {
            // If the input and output is incompatible, this may lead to an assertion.
            return
        }
        
        session.addOutputWithNoConnections(output)

        let connection = AVCaptureConnection(inputPorts: input.ports , output: output)
        if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .auto
        }
        
        connection.videoOrientation = .portrait
        
        session.addConnection(connection)
        session.commitConfiguration()
        
        contentView.contentLayer.session = session
        previewView.withAspectFilledContent {[
            contentView
        ]}
    }
    
    deinit {
        running = false
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = sampleBuffer.imageBuffer else { return }
        writeSafe.perform {
            if runningBacking {
                _output.unsafeValue(imageBuffer, .up)
            }
        }
    }
    
    public func cameraRegion(forPreviewRegion previewRegion: CGRect) -> CGRect {
        let contentSize = contentView.bounds.size
        let contentRegion = contentView.convert(previewRegion, from: previewView)
        return CGRect(
            x: contentRegion.origin.x / contentSize.width,
            y: 1 - (contentRegion.origin.y + contentRegion.size.height) / contentSize.height, // Change co-ord system
            width: contentRegion.size.width / contentSize.width,
            height: contentRegion.size.height / contentSize.height
        )
    }
}
