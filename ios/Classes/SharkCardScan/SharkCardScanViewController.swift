//
//  SharkCardScanViewController.swift
//  SharkCardScan
//
//  Created by Gymshark on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit
import TitaniumKit

public class SharkCardScanViewController: UIViewController {

    public var viewModel: CardScanViewModel
    private var styling: CardScanStyling
    public var overlayContainerView:TiUIViewProxy?
    public var showInstructionView:Bool
    public var instructionText:String?
    private var module:TiCardscannerModule?

    private lazy var closeButtonContainer = UIView().with { $0.backgroundColor = .clear}
    
    public let rootStackView = UIStackView().with { $0.axis = .vertical }
    private let cameraAreaView = UIView().withAspectRatio(3 / 4, priority: .defaultHigh)
    private let overlayView = LayerContentView(contentLayer: CAShapeLayer()).with {
        $0.contentLayer.fillRule = .evenOdd
    }
    private lazy var cardView = ScannedCardView(styling: styling)
    private lazy var instructionsLabel = UILabel().withFixed(width: 288).with {
        $0.text = viewModel.insturctionText
        $0.font = styling.instructionLabelStyling.font
        $0.textColor = styling.instructionLabelStyling.color
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    public init(instructionText:String?, showInstructionView: Bool, overlayContainerView: TiUIViewProxy, viewModel: CardScanViewModel, styling: CardScanStyling = DefaultStyling()) {
        self.viewModel = viewModel
        self.showInstructionView = showInstructionView
        self.overlayContainerView = overlayContainerView
        self.styling = styling
        self.instructionText = instructionText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModule(module:TiCardscannerModule) {
        self.module = module
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.presentationController?.delegate = self

        view.backgroundColor = .black
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        closeButtonContainer.frame = frame
  
        if (self.instructionText != nil){
            instructionsLabel.text = self.instructionText
        }
        
        viewModel.update = weakClosure(self) { (self, state) in
            UIView.animate(withDuration: 0.2) {
                self.overlayView.contentLayer.fillColor = UIColor.black.withAlphaComponent(state.overlayMaskAlpha).cgColor
                self.cardView.backgroundColor = UIColor.black.withAlphaComponent(state.cuttoutBackgroundAlpha)
            }
            self.cardView.numberLabel.text = state.response?.number
            self.cardView.expiryLabel.text = state.response?.expiry
            self.cardView.holderLabel.text = state.response?.holder
        }
       

        if (self.showInstructionView == true){
            view.withEdgePinnedContent {[
                rootStackView.withArrangedViews {[
                    cameraAreaView.withEdgePinnedContent {[
                        viewModel.previewView,
                        overlayView.withVerticallyCenteredContent(safeArea: true, horizontalEdgePin: 20) {[
                            cardView
                        ]}
                    ]},
                    UIView().with { $0.backgroundColor = .white }.withCenteredContent {[
                        instructionsLabel
                    ]}
                ]}
            ]}
        }
        else {
            view.withEdgePinnedContent {[
                rootStackView.withArrangedViews {[
                    cameraAreaView.withEdgePinnedContent {[
                        viewModel.previewView,
                        overlayView.withVerticallyCenteredContent(safeArea: true, horizontalEdgePin: 20) {[
                            cardView
                        ]}
                    ]}
                ]}
            ]}
        }
        
        if (self.overlayContainerView != nil) {
            view.addSubview(closeButtonContainer)
            self.overlayContainerView?.windowWillOpen()
            closeButtonContainer.addSubview((self.overlayContainerView?.view)!)
            self.overlayContainerView?.reposition()
            self.overlayContainerView?.layoutChildrenIfNeeded()
            self.overlayContainerView?.windowDidOpen()
            
            var closeButtonFrame = self.overlayContainerView?.view.frame
            closeButtonFrame?.origin.x = 0
            closeButtonFrame?.origin.y = 0
            self.overlayContainerView?.view.frame = closeButtonContainer.frame
            
            closeButtonContainer.isUserInteractionEnabled = true
            view.bringSubviewToFront(closeButtonContainer)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Give time for everthing to layout. Will maybe come back to but it will work fine
        DispatchQueue.main.async {
            let path = UIBezierPath(rect: self.overlayView.bounds)
            path.append(
                UIBezierPath(
                    roundedRect: self.overlayView.convert(self.cardView.bounds, from: self.cardView),
                    cornerRadius: self.cardView.layer.cornerRadius
                )
            )
            self.overlayView.contentLayer.path = path.cgPath
            
            self.viewModel.cardCuttoutInPreview(frame: self.viewModel.previewView.convert(self.cardView.bounds, from: self.cardView))
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCamera()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (self.module != nil){
            self.module?.cleanupmanual()
        }
    }
}

extension SharkCardScanViewController : UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ pc: UIPresentationController) {
    }
    public func presentationControllerShouldDismiss(_ pc: UIPresentationController) -> Bool {
        return true
    }
    public func presentationControllerWillDismiss(_ pc: UIPresentationController) {
        
    }
    public func presentationControllerDidDismiss(_ pc: UIPresentationController) {
        if (self.module != nil){
            self.module?.cleanup()
        }
    }
}
