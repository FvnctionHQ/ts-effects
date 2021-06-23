//
//  TSEffectsModuleInterface.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/9/21.
//

import Foundation
import UIKit
import AVFAudio

public protocol TSEffectsModuleInterface {
 
    func close()
    func present(in controller: UIViewController, animated: Bool)
    
}

public protocol TSEffectsModuleDelegate: AnyObject {
    
    func TSEffectsModuleDidProvideRender(module:TSEffects, resultURL: URL)
    func TSEffectsModuleDidRequstShowLoadingDismiss(module: TSEffects)
    func TSEffectsModuleDidRequstShowLoading(module: TSEffects)
    
}

