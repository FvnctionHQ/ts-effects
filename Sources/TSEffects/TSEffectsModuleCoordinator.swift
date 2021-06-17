//
//  TSEffectsModuleCoordinator.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/9/21.
//

import Foundation
import UIKit
import AVFoundation
import TSUtils
import TSLog

public typealias TSEffects = TSEffectsModuleCoordinator


extension TSEffectsModuleCoordinator: TSEffectsModuleRackDelegate {
    func effectsRackDidStartProcessing() {
        delegate?.TSEffectsModuleDidRequstShowLoading(module: self)
    }
    
    func effectsRackDidFinishProcessing() {
        delegate?.TSEffectsModuleDidRequstShowLoadingDismiss(module: self)
    }
    
    
    func effectsRackDidFinishPlaying() {
        
        viewController.showPlaybackStoppedUI()
    }
    
    
    func effectsRackDidRender(resultURL: URL) {
        self.delegate?.TSEffectsModuleDidProvideRender(module: self, resultURL: resultURL)
    }
    
   
    func effectsRackDidFail() {
        delegate?.TSEffectsModuleDidRequstShowLoadingDismiss(module: self)
    }
    
    
}

extension TSEffectsModuleCoordinator: TSEffectsModuleUIDelegate {
    
    func UIdidTouchLoop() {
        effectsLogic.toggleLoop()
    }
    
  
    
    func UIdidRequestParams(forMixerAtIndex: Int, in view: UIView) {
        
        let fx = effectsLogic.effectMixers[forMixerAtIndex]
        
        let vc = TSEffectParamsTableViewController(parameterDataSource: self, parameterDelegate: self, effectType: fx.effect)
        vc.modalPresentationStyle = .popover
        let popover = vc.popoverPresentationController
        popover?.sourceView = view
        popover?.permittedArrowDirections = [.right]
        popover?.sourceRect = CGRect(x: 0, y: 10, width: 164, height: 0)
        
        (viewController as! UIViewController).present(vc, animated: true, completion: nil)
        
    }
    
    
    func UIdidTouchPlay() {
        
        if (effectsLogic.isPlaying) {
            effectsLogic.stop()
        } else {
            effectsLogic.play()
        }
        
    }
    
    func UIdidLoadView() {
        
        viewController.reloadData()
    }
    
    func UIdidChangeMixerSlider(newValue: Float, forMixerAtIndex: Int) {
        
    }

    
    func UIdidTouchCancel() {
        close()
    }
    
    func UIdidTouchDone() {
        effectsLogic.startRender()
    }
    
    
}

extension TSEffectsModuleCoordinator: TSEffectsModuleUIDataSource {
   
    func isLooping() -> Bool {
        effectsLogic.isLooping
    }
    
   
    func activeEffectsCount() -> Int {
        effectsLogic.activeEffectsCount
    }
    
    
    func isPlaying() -> Bool {
        effectsLogic.isPlaying
    }
    

    
    func effectsCount() -> Int {
        effectsLogic.effectMixers.count
    }
    
    func effectMixer(atIndex: Int) -> TSDryWetMixer {
        
        return effectsLogic.effectMixers[atIndex]
    }
    
    
}

extension TSEffectsModuleCoordinator: TSEffectsModuleEffectParametersUIDelegate {
   
    func didChange(parameter: TSEffectParameter, newValue: AUValue, for effect: TSEffectType) {
        
        effectsLogic.changeParameterValue(effectType: effect, param: parameter, newValue: newValue)
        
    }
    
    
}

extension TSEffectsModuleCoordinator: TSEffectsModuleEffectParametersUIDataSource {
    func parametersCountFor(effect: TSEffectType) -> Int {
        let effect = effectsLogic.effectMixers.first { mixer in
            return mixer.effect == effect
        }
        
        return effect!.effect.parameters.count
    }
    
    func effectParameter(effect: TSEffectType, atIndex: Int) -> TSEffectParameter {
        
        let effect = effectsLogic.effectMixers.first { mixer in
            return mixer.effect == effect
        }
        return effect!.effect.parameters[atIndex]
    }
    
    
}


extension TSEffectsModuleCoordinator: TSEffectsModuleInterface {
   
    
    public func close() {
        effectsLogic.stopEffects()
         presentingController?.dismiss(animated: isAnimatedPresentation, completion: nil)
     }
     
     public func present(in controller: UIViewController, animated: Bool) {
         presentingController = controller
         isAnimatedPresentation = animated
         
        let vc = TSMixerTableViewController(effectDataSource: self, delegate: self, fileName: effectsLogic.fileName)
            
         viewController = vc
         presentingController?.present(viewController as! UIViewController, animated: animated, completion: nil)
     
     }
     
    
    
}

public class TSEffectsModuleCoordinator: NSObject {
    
    weak var delegate: TSEffectsModuleDelegate?
    unowned var viewController: TSEffectsModuleUIInterface!
    unowned var presentingController: UIViewController?
    var isAnimatedPresentation = false
    var effectsLogic: TSEffectsModuleRackInterface!
    
    public required init(file:AVAudioFile, delegate: TSEffectsModuleDelegate) {
        TSLog.sI.logCall()
        
        self.delegate = delegate
        super.init()

        effectsLogic = TSEffectsModuleRack(delegate: self)
        effectsLogic.start(file: file)
        
    }

    
    deinit {
        TSLog.sI.logCall()
    }

}
