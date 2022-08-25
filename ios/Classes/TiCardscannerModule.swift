//
//  TiCardscannerModule.swift
//  ti.cardscanner
//
//  Created by Marc Bender
//  Copyright (c) 2022 Your Company. All rights reserved.
//

import UIKit
import TitaniumKit

/**
 
 Titanium Swift Module Requirements
 ---
 
 1. Use the @objc annotation to expose your class to Objective-C (used by the Titanium core)
 2. Use the @objc annotation to expose your method to Objective-C as well.
 3. Method arguments always have the "[Any]" type, specifying a various number of arguments.
 Unwrap them like you would do in Swift, e.g. "guard let arguments = arguments, let message = arguments.first"
 4. You can use any public Titanium API like before, e.g. TiUtils. Remember the type safety of Swift, like Int vs Int32
 and NSString vs. String.
 
 */

@objc(TiCardscannerModule)
class TiCardscannerModule: TiModule {

   public var scannerVC:SharkCardScanViewController!
    
   func moduleGUID() -> String {
     return "29c40796-46c0-41e2-9691-9286ae0d9d30"
   }
  
   override func moduleId() -> String! {
     return "ti.cardscanner"
   }

   override func startup() {
     super.startup()
     debugPrint("[DEBUG] \(self) loaded")
   }

    
    @objc(torch:)
    func torch(arguments: Array<Any>?) {
        let enabled = self.scannerVC.viewModel.cameraStream.toggleTorch
       
        self.scannerVC.viewModel.cameraStream.toggleTorch = !enabled
    }

    
    
    @objc(close:)
    func close(arguments: Array<Any>?) {
        guard let arguments = arguments, let options = arguments[0] as? [String: Any] else { return }
        let animated = options["animated"] as? Bool ?? false
       
        self.scannerVC.dismiss(animated: animated) {
            self.scannerVC = nil
        }
        self.scannerVC.viewModel.stopCamera()
    }
    
    func cleanupmanual() {
        self.fireEvent("close")
    }

    func cleanup() {
        self.scannerVC.viewModel.stopCamera()
        self.scannerVC = nil
    }
    
    @objc(scan:)
    func scan(arguments: Array<Any>?) {
      guard let arguments = arguments, let options = arguments[0] as? [String: Any] else { return }
        
      guard let callback: KrollCallback = options["callback"] as? KrollCallback else { return }
      let modal = options["modal"] as? Bool ?? false

      let animated = options["animated"] as? Bool ?? false
      let showInstructionView = options["showInstructionsView"] as? Bool ?? false
      let instructionText = options["instructionsText"] as? String ?? nil

      var overlayView:TiViewProxy?

      if options["overlayView"] != nil {
          overlayView = options["overlayView"] as? TiViewProxy
      }
        
      scannerVC = SharkCardScanViewController(instructionText:instructionText,showInstructionView:showInstructionView, overlayContainerView:overlayView as! TiUIViewProxy, viewModel: CardScanViewModel(noPermissionAction: { [weak self] in
            
            self?.showNoPermissionAlert()
            
        }, successHandler: { (response) in
            
            callback.call([["cardnumber": response.number, "holdername": response.holder, "expiry": response.expiry]], thisObject: self)

            self.scannerVC.dismiss(animated: animated) {
                self.scannerVC = nil
            }
           
        }))
        
        scannerVC.setModule(module: self)
        
        guard let controller = TiApp.controller(), let topPresentedController = controller.topPresentedController() else {
            return
        }
        if (modal == true){
            scannerVC.modalPresentationStyle = .pageSheet
        }
        else {
            scannerVC.modalPresentationStyle = .overCurrentContext
        }
        
        topPresentedController.present(scannerVC, animated: animated, completion: nil)
    }
    
    func showNoPermissionAlert() {
        showAlert(style: .alert, title: "Oopps, No access", message: "Check settings and ensure the app has permission to use the camera.", actions: [UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })])
    }
    
    func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction]) {
               
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.view.tintColor = UIColor.black
        actions.forEach {
            alertController.addAction($0)
        }
        if style == .actionSheet && actions.contains(where: { $0.style == .cancel }) == false {
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        }
        TiApp.controller().topPresentedController().present(alertController, animated: true, completion: nil)
    }
}
