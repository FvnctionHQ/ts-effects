//
//  TSEffectsModuleUIInterface.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/9/21.
//

import Foundation
import AVFAudio
import UIKit

protocol TSEffectsModuleUIInterface: AnyObject {
    
    func reloadData()
    func showPlaybackStoppedUI()
}


protocol TSEffectsModuleUIDelegate: AnyObject {
    
    func UIdidLoadView()
        
    func UIdidChangeMixerSlider(newValue: Float, forMixerAtIndex: Int)
    func UIdidRequestParams(forMixerAtIndex: Int, in view: UIView)
 
    func UIdidTouchPlay()
    func UIdidTouchLoop()
    
    
    func UIdidTouchCancel()
    func UIdidTouchDone()
}


protocol TSEffectsModuleUIDataSource: AnyObject {
    
    func isLooping() -> Bool
    func isPlaying() -> Bool
    func effectsCount() -> Int
    func activeEffectsCount() -> Int
    func effectMixer(atIndex: Int) -> TSDryWetMixer
    
}


protocol TSEffectsModuleEffectParametersUIDataSource: AnyObject {
    

    func parametersCountFor(effect: TSEffectType) -> Int
    func effectParameter(effect: TSEffectType, atIndex: Int) -> TSEffectParameter
    
}

protocol TSEffectsModuleEffectParametersUIDelegate: AnyObject {
    
    func didChange(parameter: TSEffectParameter, newValue: AUValue, for effect: TSEffectType)
}
