//
//  CardScanViewModel.swift
//  SharkCardScan
//
//  Created by Gymshark on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import Foundation
import Vision
import VisionKit
import AudioToolbox
import TitaniumKit

struct CardScanViewModelState: Equatable {
    var response: CardScannerResponse?
    var overlayMaskAlpha: CGFloat {
        response == nil ? 0.5 : 0.9
    }
    var cuttoutBackgroundAlpha: CGFloat {
        response == nil ? 0 : 0.5
    }
    var selectEnabled: Bool {
        response != nil
    }
}


enum Vibration {
        case error
        case success
        case warning
        case light
        case medium
        case heavy
        @available(iOS 13.0, *)
        case soft
        @available(iOS 13.0, *)
        case rigid
        case selection
        case oldSchool

        public func vibrate() {
            switch self {
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .soft:
                if #available(iOS 13.0, *) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            case .rigid:
                if #available(iOS 13.0, *) {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .oldSchool:
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
}


public class CardScanViewModel {
    private let cameraAccess: CameraAccessProtocol
    public let cameraStream: PixelBufferStream
    private let cardReader: CardScannerProtocol
    private let noPermissionAction: () -> Void
    var didDismiss: (() -> Void)?
    private let successHandler: (CardScannerResponse) -> Void
    private var timerActive = false
    public var isRunning = false
    private var module: TiCardscannerModule!
    public var closeButtonTitle: String = "Close"

    public var insturctionText: String = "Position your card within the box \nand we'll scan it for you"
    
    var previewView: UIView {
        cameraStream.previewView
    }
    var state = CardScanViewModelState() {
        didSet {
            update(state)
        }
    }
    var update: (CardScanViewModelState) -> Void = { _ in } {
        didSet {
            update(state)
        }
    }
    
    public init(cameraAccess: CameraAccessProtocol = CameraAccess(),
         cameraStream: PixelBufferStream = CameraPixelBufferStream(),
         cardReader: CardScannerProtocol = CardScanner(),
         noPermissionAction: @escaping () -> Void,
         successHandler: @escaping (CardScannerResponse) -> Void) {
        self.cameraAccess = cameraAccess
        self.cameraStream = cameraStream
        self.cardReader = cardReader
        self.noPermissionAction = noPermissionAction
        self.successHandler = successHandler
        cameraStream.output = cardReader.read(buffer:orientation:)
        cardReader.output = weakClosure(self, on: .main) {
            $0.state.response = $1
            guard $0.timerActive == false else { return }
            $0.timerActive = true

            Vibration.success.vibrate()
                       
            DispatchQueue.main.asyncWeakClosure($0, afterDeadline: .now() + .seconds(0)) {
                $0.isRunning = false

                $0.cameraStream.running = false
            }
            DispatchQueue.main.asyncWeakClosure($0, afterDeadline: .now() + .seconds(1)) {
                guard let response = $0.state.response else { return }
                
                // Odd bug will cause parentVC showing as half dismissed, well inspect when I have some time
                $0.successHandler(response)
                

//                DispatchQueue.main.asyncWeakClosure($0) { _ in
//                   // $0.viewServices?.dismiss()
//                    self.didDismiss?()
//
//                }
            }
        }
    }
    
//    func didTapClose(animated:Bool) {
//        cameraStream.running = false
//        self.didTapClose(animated: animated)
//    }
    
    func startCamera() {
        cameraAccess.request(weakClosure(self) { (self, success) in
            if success {
                if (self.cameraStream.running == false){
                    self.isRunning = true
                    self.cameraStream.running = true
                }
                else {
                }
            } else {
                self.noPermissionAction()
            }
        })
    }
    
    func stopCamera() {
        if (cameraStream.running == true){
            isRunning = false
            cameraStream.running = false
        }
        else {
        }
    }
    
    func cardCuttoutInPreview(frame: CGRect) {
        cardReader.regionOfInterest = cameraStream.cameraRegion(forPreviewRegion: frame)
    }
}
