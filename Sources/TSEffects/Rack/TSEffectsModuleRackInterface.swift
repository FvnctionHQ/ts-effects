//
//  TSEffectsModuleRackInterface.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/9/21.
//

import Foundation
import AVFAudio

protocol TSEffectsModuleRackInterface {
    
    func randomize()
    func start(file: AVAudioFile)
    func play()
    func toggleLoop()
    func stop()
    func startRender()
    func stopEffects()
    func changeParameterValue(effectType: TSEffectType, param: TSEffectParameter, newValue: AUValue)
    func reset()
    
    var isLooping: Bool { get }
    var isPlaying: Bool { get }
    var fileName: String { get }
    var effectMixers: [TSDryWetMixer] { get }
    var activeEffectsCount: Int { get }
}


protocol TSEffectsModuleRackDelegate: AnyObject {
    
    func effectsRackDidFinishResettingFX()
    
    func effectsRackDidFinishPlaying()
    func effectsRackDidRender(resultURL: URL)
    func effectsRackDidFail()
    
    func effectsRackDidStartProcessing()
    func effectsRackDidFinishProcessing()
}
