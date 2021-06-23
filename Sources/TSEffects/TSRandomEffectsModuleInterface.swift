//
//  File.swift
//  
//
//  Created by Alex Linkov on 6/23/21.
//

import Foundation
import AVFoundation

public protocol TSRandomEffectsModuleInterface {
    
    func applyRandomFX(slices: [AVAudioFile])
}


public protocol TSRandomEffectsModuleDelegate: AnyObject {
    
    func didApplyRandomFxToSlice(at index: Int, resultURL: URL)
    func didFinish()
}
