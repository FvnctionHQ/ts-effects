//
//  File.swift
//  
//
//  Created by Alex Linkov on 6/23/21.
//

import Foundation
import AVFoundation


public typealias TSRandomEffectsModule = TSRandomEffectsModuleCoordinator

extension TSRandomEffectsModuleCoordinator: TSEffectsModuleRackDelegate {
    func effectsRackDidFinishResettingFX() {

        
    }
    
  
    func effectsRackDidFinishPlaying() {
        
    }
    
    func effectsRackDidRender(resultURL: URL) {
      
        _ = slices.popLast()
        
        delegate.didApplyRandomFxToSlice(at: currentIndex, resultURL: resultURL)
        
        effectsLogic?.stopEffects()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.applyFXToNextFile()
        }
        
       
    }
    
    func effectsRackDidFail() {
        
    }
    
    func effectsRackDidStartProcessing() {
        
    }
    
    func effectsRackDidFinishProcessing() {
        
    }
    
    
}

extension TSRandomEffectsModuleCoordinator: TSRandomEffectsModuleInterface {
  
   public func applyRandomFX(slices: [AVAudioFile]) {
    
    self.slices = slices
    
    applyFXToNextFile()
    
   }
    
    
}

public class TSRandomEffectsModuleCoordinator: NSObject {

    var currentIndex: Int = 0
    var slices: [AVAudioFile] = []
    unowned let delegate: TSRandomEffectsModuleDelegate
    var effectsLogic: TSEffectsModuleRack?
    
   public required init(delegate: TSRandomEffectsModuleDelegate) {
        self.delegate = delegate
        super.init()
        
        afterInit()
    }
    
    func afterInit() {
        
    }
    
    func applyFXToNextFile() {
        
        if (slices.count == 0) {
            
            delegate.didFinish()
            return
        }
        
        
        let slice = slices.last!
        currentIndex = slices.count - 1
        effectsLogic = TSEffectsModuleRack(delegate: self)
        effectsLogic!.start(file: slice)
        
        effectsLogic!.randomize()

        
        
        
        
        
    }
}
