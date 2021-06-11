//
//  TSEffectsModuleModel.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/9/21.
//

import Foundation
import AVFoundation
import AudioKit
import SoundpipeAudioKit

struct TSDryWetMixer {
    var name: String
    var mixer: DryWetMixer
    var effect: TSEffectType
}


struct TSEffectParameter {
    let identifier: String
    let label: String
    let defaultValue: AUValue
    let range: ClosedRange<AUValue>

}

enum TSEffectType: String {

    case Delay
    case Distortion
    case Resonator
    case BitCrusher
    case BandPass
    

    var parameters: [TSEffectParameter] {
        switch self {
        case .Distortion:
            return [
                TSEffectParameter(identifier:SoundpipeAudioKit.TanhDistortion.pregainDef.identifier, label: SoundpipeAudioKit.TanhDistortion.pregainDef.name, defaultValue:
                                    SoundpipeAudioKit.TanhDistortion.pregainDef.defaultValue, range: SoundpipeAudioKit.TanhDistortion.pregainDef.range),
                TSEffectParameter(identifier:SoundpipeAudioKit.TanhDistortion.postgainDef.identifier, label: SoundpipeAudioKit.TanhDistortion.postgainDef.name, defaultValue: SoundpipeAudioKit.TanhDistortion.postgainDef.defaultValue, range: SoundpipeAudioKit.TanhDistortion.postgainDef.range),
                TSEffectParameter(identifier:SoundpipeAudioKit.TanhDistortion.positiveShapeParameterDef.identifier, label: SoundpipeAudioKit.TanhDistortion.positiveShapeParameterDef.name, defaultValue: SoundpipeAudioKit.TanhDistortion.positiveShapeParameterDef.defaultValue, range: SoundpipeAudioKit.TanhDistortion.positiveShapeParameterDef.range),
                TSEffectParameter(identifier:SoundpipeAudioKit.TanhDistortion.negativeShapeParameterDef.identifier, label: SoundpipeAudioKit.TanhDistortion.negativeShapeParameterDef.name, defaultValue: SoundpipeAudioKit.TanhDistortion.negativeShapeParameterDef.defaultValue, range: SoundpipeAudioKit.TanhDistortion.negativeShapeParameterDef.range)
            ]
        case .Delay:
            return [
                TSEffectParameter(identifier:AudioKit.Delay.timeDef.identifier, label: AudioKit.Delay.timeDef.name, defaultValue: AudioKit.Delay.timeDef.defaultValue, range: AudioKit.Delay.timeDef.range),
                TSEffectParameter(identifier:AudioKit.Delay.feedbackDef.identifier, label: AudioKit.Delay.feedbackDef.name, defaultValue: AudioKit.Delay.feedbackDef.defaultValue, range: AudioKit.Delay.feedbackDef.range),
                TSEffectParameter(identifier:AudioKit.Delay.lowPassCutoffDef.identifier, label: AudioKit.Delay.lowPassCutoffDef.name, defaultValue: AudioKit.Delay.lowPassCutoffDef.defaultValue, range: AudioKit.Delay.lowPassCutoffDef.range)
            ]

        case .Resonator:
            return [
                TSEffectParameter(identifier:SoundpipeAudioKit.ModalResonanceFilter.frequencyDef.identifier, label: SoundpipeAudioKit.ModalResonanceFilter.frequencyDef.name, defaultValue: SoundpipeAudioKit.ModalResonanceFilter.frequencyDef.defaultValue, range: SoundpipeAudioKit.ModalResonanceFilter.frequencyDef.range),
                TSEffectParameter(identifier:SoundpipeAudioKit.ModalResonanceFilter.qualityFactorDef.identifier, label: SoundpipeAudioKit.ModalResonanceFilter.qualityFactorDef.name, defaultValue: SoundpipeAudioKit.ModalResonanceFilter.qualityFactorDef.defaultValue, range: SoundpipeAudioKit.ModalResonanceFilter.qualityFactorDef.range),
            ]
        case .BitCrusher:
            return [
                TSEffectParameter(identifier:SoundpipeAudioKit.BitCrusher.bitDepthDef.identifier, label: SoundpipeAudioKit.BitCrusher.bitDepthDef.name, defaultValue: SoundpipeAudioKit.BitCrusher.bitDepthDef.defaultValue, range: SoundpipeAudioKit.BitCrusher.bitDepthDef.range),
                TSEffectParameter(identifier:SoundpipeAudioKit.BitCrusher.sampleRateDef.identifier, label: SoundpipeAudioKit.BitCrusher.sampleRateDef.name, defaultValue: SoundpipeAudioKit.BitCrusher.sampleRateDef.defaultValue, range: SoundpipeAudioKit.BitCrusher.sampleRateDef.range)
            ]
        case .BandPass:
            return [
                TSEffectParameter(identifier:SoundpipeAudioKit.BandPassButterworthFilter.centerFrequencyDef.identifier, label: SoundpipeAudioKit.BandPassButterworthFilter.centerFrequencyDef.name, defaultValue: SoundpipeAudioKit.BandPassButterworthFilter.centerFrequencyDef.defaultValue, range: SoundpipeAudioKit.BandPassButterworthFilter.centerFrequencyDef.range),
                TSEffectParameter(identifier:SoundpipeAudioKit.BandPassButterworthFilter.bandwidthDef.identifier, label: SoundpipeAudioKit.BandPassButterworthFilter.bandwidthDef.name, defaultValue: SoundpipeAudioKit.BandPassButterworthFilter.bandwidthDef.defaultValue, range: SoundpipeAudioKit.BandPassButterworthFilter.bandwidthDef.range)
            ]
        }

    }
}
