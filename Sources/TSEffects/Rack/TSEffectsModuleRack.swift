//
//  TSEffectsModuleRack.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/9/21.
//

import Foundation
import AVFAudio
import AVFoundation
import AudioKit
import TSUtils
import SoundpipeAudioKit

public typealias TSFXProcessCallback = (URL?) -> Void

extension TSEffectsModuleRack: TSEffectsModuleRackInterface {
   
    func toggleLoop() {
        player.isLooping = !player.isLooping
    }
    
    var isLooping: Bool {
        
        get {
           return player.isLooping
        }
    }
    
   
    
    func changeParameterValue(effectType: TSEffectType, param: TSEffectParameter, newValue: AUValue) {
    

        switch effectType {
        case .Delay:
            changeDelayParameterValue(param: param, newValue:  newValue)
        case .Distortion:
            changeDistortionParameterValue(param: param, newValue: newValue)
        case .Resonator:
            changeResonatorParameterValue(param: param, newValue: newValue)
        case .BitCrusher:
            changeBitCrusherParameterValue(param: param, newValue: newValue)
        case .BandPass:
            changeBandPassParameterValue(param: param, newValue: newValue)
        }
    }
   
    var activeEffectsCount: Int {
        get {
            
            return dryWetMixers.map{ $0.mixer.balance }.filter{ $0 > 0 }.count
        }
    }
    
    var isPlaying: Bool {
        get {
            return player.isPlaying
        }
    }
    
   
    func startRender() {
        
        delegate?.effectsRackDidStartProcessing()
        
        stop()
        processFileWithFX1(currentSegment: source!) { resultURL in

            self.delegate?.effectsRackDidFinishProcessing()
            
            if (resultURL != nil) {
               
                self.delegate?.effectsRackDidRender(resultURL: resultURL!)
                
            } else {
                self.delegate?.effectsRackDidFail()
                TSLog.sI.log(.error, "Failed render")
            }
            
        }
    }
    

    var fileName: String {
        
        get {
            fName
        }
    }
    
    var effectMixers: [TSDryWetMixer] {
        get {
            return dryWetMixers
        }
    }
    
    func start(file: AVAudioFile) {
        setup()
        fName = file.url.lastPathComponent
        _start(url: file.url, fileName: fName)
     //   onLoadFile(file: file)
    }
    
    func play() {
        
        if (!engine.avEngine.isRunning) {
           try! engine.start()
        }
      
        self.player.start()
        self.playbackTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updatePlaybackProgress), userInfo: nil, repeats: true)

    }
    
    func stop() {
        
        player.stop()
    }
    
    func stopEffects() {
        
        mainMixer.removeAllInputs()
        dryWetMixers = []
        
            engine.stop()
            bitcrusherDryWetMixer?.stop()
            bitcrusher?.stop()
            delayDryWetMixer?.stop()
            delay?.stop()
            pitchshifterDryWetMixer?.stop()
            pitchshifter?.stop()
            resonatorDryWetMixer?.stop()
            resonator?.stop()
            distortion?.stop()
            bandPass?.stop()
            bandpassDryWetMixer!.stop()
            distortionDryWetMixer?.stop()
            mainMixer.stop()
            
       
        
        
        delay = nil
        resonator = nil
        bitcrusher = nil
        pitchshifter = nil
        distortion = nil
        bandPass = nil
        
        source = nil
     
        
        delayDryWetMixer = nil
        bitcrusherDryWetMixer = nil
        pitchshifterDryWetMixer = nil
        bandpassDryWetMixer = nil
        distortionDryWetMixer = nil
        resonatorDryWetMixer = nil
        
    }
    
}

class TSEffectsModuleRack: NSObject {

    var playbackTimer: Timer!
    var source: AVAudioFile?
    var target: AVAudioFile?
    var fName: String!
    
    weak var delegate: TSEffectsModuleRackDelegate?
    
    var dryWetMixers: [TSDryWetMixer] = []
    let player = AudioPlayer()
    
    let engine = AudioEngine()
    
    var pitchshifter: PitchShifter?
    var bitcrusher: BitCrusher?
    
    
    var bandPass: BandPassButterworthFilter?
    var bandpassDryWetMixer: DryWetMixer?
    
    var resonator: ModalResonanceFilter?
    
    
    var bitcrusherDryWetMixer: DryWetMixer?
    var pitchshifterDryWetMixer: DryWetMixer?
    var resonatorDryWetMixer: DryWetMixer?
    
    var delay: Delay?
    var delayDryWetMixer: DryWetMixer?
    
    var distortion: TanhDistortion?
    var distortionDryWetMixer: DryWetMixer?
    
    var mainMixer = Mixer()
    var playerMixer = Mixer()
    
    var buffer: AVAudioPCMBuffer?
    
    
    required init(delegate: TSEffectsModuleRackDelegate) {
        self.delegate = delegate
        TSLog.sI.logCall()
    }
    
    
    
    deinit {
        TSLog.sI.logCall()
    }
    
    func setup() {
        
        delay = Delay(player)
        resonator = ModalResonanceFilter(player)
        bitcrusher = BitCrusher(player)
        pitchshifter = PitchShifter(player)
        distortion = TanhDistortion(player)
        
        
        
        bandPass = BandPassButterworthFilter(player)

        bandpassDryWetMixer = DryWetMixer(player, bandPass!)

        
        distortionDryWetMixer = DryWetMixer(bandpassDryWetMixer!, distortion!)
        bitcrusherDryWetMixer  = DryWetMixer(distortionDryWetMixer!, bitcrusher!)
        pitchshifterDryWetMixer = DryWetMixer(bitcrusherDryWetMixer!, pitchshifter!)
        resonatorDryWetMixer = DryWetMixer(pitchshifterDryWetMixer!, resonator!)
        delayDryWetMixer = DryWetMixer(resonatorDryWetMixer!, delay!)
        bitcrusherDryWetMixer?.balance = 0.0
        pitchshifterDryWetMixer!.balance = 0.0
        delayDryWetMixer!.balance = 0.0
        distortionDryWetMixer!.balance = 0.0
        resonatorDryWetMixer!.balance = 0.0
        bandpassDryWetMixer!.balance = 0.0
        
        
        mainMixer.addInput(delayDryWetMixer!)
        engine.output = mainMixer
        
        dryWetMixers = [
            TSDryWetMixer(name: "Distortion", mixer: distortionDryWetMixer!, effect: .Distortion),
            TSDryWetMixer(name: "BitCrusher", mixer: bitcrusherDryWetMixer!, effect: .BitCrusher),
            TSDryWetMixer(name:"Resonator", mixer: resonatorDryWetMixer!, effect: .Resonator),
            TSDryWetMixer(name:"Delay", mixer: delayDryWetMixer!, effect: .Delay),
            TSDryWetMixer(name:"BandPass", mixer: bandpassDryWetMixer!, effect: .BandPass)
        ]
        
        startEffects()
    }
    

    func startEffects() {

        do {
            try engine.start()
            bitcrusherDryWetMixer?.start()
            bitcrusher?.start()
            delayDryWetMixer?.start()
            delay?.start()
            pitchshifterDryWetMixer?.start()
            pitchshifter?.start()
            resonatorDryWetMixer?.start()
            resonator?.start()
            distortion?.start()
            bandPass?.start()
            bandpassDryWetMixer!.start()
            distortionDryWetMixer?.start()
            mainMixer.start()
            
        } catch let err {
            TSLog.sI.log(.error, err.localizedDescription)
        }
    }
    
    func _start(url: URL, fileName: String) {
      
        player.reset()
        fName = fileName
       // let tempDirectory = FileManager.default.temporaryDirectory
       // let tempPath = tempDirectory.appendingPathComponent("\(url.lastPathComponent)")
        source = try! AVAudioFile(forReading: url)
        player.file = source
        
       // player.file = source
        
    }
    func changeDelayParameterValue(param: TSEffectParameter, newValue: AUValue) {
        
        switch param.identifier {
        case "time":
            delay?.$time.ramp(to: newValue, duration: 0.02)
        case "feedback":
            delay?.$feedback.ramp(to: newValue, duration: 0.02)
        case "lowPassCutoff":
            delay?.$lowPassCutoff.ramp(to: newValue, duration: 0.02)
            
        default: break
            
        }
        
        
    }
    
    func changeBitCrusherParameterValue(param: TSEffectParameter, newValue: AUValue) {
        
        switch param.identifier {
        case "bitDepth":
            bitcrusher?.$bitDepth.ramp(to: newValue, duration: 0.02)
        case "sampleRate":
            bitcrusher?.$sampleRate.ramp(to: newValue, duration: 0.02)

            
        default: break
            
        }
        
        
    }
    
    func changeResonatorParameterValue(param: TSEffectParameter, newValue: AUValue) {
        
        switch param.identifier {
        case "frequency":
            resonator?.$frequency.ramp(to: newValue, duration: 0.02)
        case "qualityFactor":
            resonator?.$qualityFactor.ramp(to: newValue, duration: 0.02)

            
        default: break
            
        }
        
        
    }
    
    func changeBandPassParameterValue(param: TSEffectParameter, newValue: AUValue) {
        
        switch param.identifier {
        case "centerFrequency":
            bandPass?.$centerFrequency.ramp(to: newValue, duration: 0.02)
        case "bandwidth":
            bandPass?.$bandwidth.ramp(to: newValue, duration: 0.02)

            
        default: break
            
        }
        
        
    }
    
    func changeDistortionParameterValue(param: TSEffectParameter, newValue: AUValue) {
        
        switch param.identifier {
        case "pregain":
            distortion?.$pregain.ramp(to: newValue, duration: 0.02)
        case "postgain":
            distortion?.$postgain.ramp(to: newValue, duration: 0.02)
            
        case "positiveShapeParameter":
            distortion?.$positiveShapeParameter.ramp(to: newValue, duration: 0.02)
            
        case "negativeShapeParameter":
            distortion?.$negativeShapeParameter.ramp(to: newValue, duration: 0.02)
            
        default: break
            
        }
        
        
    }
    
    func onLoadFile(file: AVAudioFile) {

        TSAudioFile.cleanTempDirectory()

        delegate?.effectsRackDidStartProcessing()

        var output: URL = URL(string: "https://fvnction.net")!
        var fileNameString: String = ""
        var errorString: String = ""

        DispatchQueue.global(qos: .background).async {

            do {
                let file = try TSAudioFile(forReading:file.url)
                self.fName = file.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: " ", with: "").lowercased(with: .current).appending(".wav")

                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentsDirectory = paths[0]
                let trimmed =  "working_copy" //file.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: " ", with: "").lowercased(with: .current)
                let filePath = documentsDirectory.appendingPathComponent(trimmed + ".wav")

                if FileManager.default.fileExists(atPath: filePath.path) {
                       // Delete file
                    try! FileManager.default.removeItem(atPath: filePath.path)
                   }

                TSConverter.convertToWav(filePath: filePath, channelCount: 1, inputFile: file) {  (outputURL, error) in


                    if (error != nil) {

                        errorString = "Can not convert file \(file.url.lastPathComponent )"




                     } else {


                        fileNameString =  file.url.lastPathComponent
                        output = outputURL!





                     }



                }

            } catch {
                errorString = "Can not load file \(file.url.lastPathComponent)"


            }




          DispatchQueue.main.async {

//            if (errorString.count > 0) {
//                TSQOSManager.sharedInstance.reportIssue(severity: .error, className: "ViewController", methodName: "didSelectDocuments", errorString: errorString)
//                return
//            }


            self.delegate?.effectsRackDidFinishProcessing()
            self._start(url: output, fileName: fileNameString)

          }

        }








    }
    
    func processFileWithFX1(currentSegment: AVAudioFile, completion : @escaping  TSFXProcessCallback) {
        
        let path1 = "r1-\(currentSegment.url.lastPathComponent)"
        let path = "r-\(currentSegment.url.lastPathComponent)" //"recordedMIDIAudio.caf"
       let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat64, sampleRate: 44100, channels: 1, interleaved: true)!
        
        do {
            
            var fileForWriting:AVAudioFile? = try AVAudioFile(forWriting: url, settings: (format.settings))
            
            
            do {
                
                
                
                
                try engine.renderToFile(fileForWriting!, maximumFrameCount: AVAudioFrameCount(currentSegment.length), duration: currentSegment.duration, prerender: {
                    
                    self.player.play()
                       
                        
                    }, progress: {  (progress) in
                        
                    
                        if (progress == 1) {
                            
                            
//                            let newF = fileForWriting!.extract(to: url1, from: 0, to: fileForWriting!.duration)
                            let url = fileForWriting!.url
                            
                            fileForWriting = nil
                            completion(url)
                            //completion(self.currentSegment!)
//                            TSDeviceCommManager.sharedInstance.sendFile(fl: self.currentFile! , name: self!.fileName! ,folder: folderPath)

                            self.setup()
                        }
                    })
                
                
              
                
            } catch let renderError {
                
                TSLog.sI.log(.error, renderError.localizedDescription)
                
                completion(nil)
            }
          
            
            
            
            
            
        } catch let fileForWritingError {
         
            TSLog.sI.log(.error, fileForWritingError.localizedDescription)
            
        }
    }
        
    
    
    
    @objc func updatePlaybackProgress() {
        
        let nodeTime = player.playerNode.lastRenderTime
        if (nodeTime == nil) {
            return
        }
        let playerTime = player.playerNode.playerTime(forNodeTime: nodeTime!)
        
        if (playerTime == nil) {
            return
        }
        
        let secs = (Double(playerTime!.sampleTime) / playerTime!.sampleRate)


        if (secs >= player.duration || secs >= (player.duration))  {


            stop()
            playbackTimer.invalidate()
            
            
            if (player.isLooping) {
                play()
            } else {
                delegate?.effectsRackDidFinishPlaying()
            }
        }


    }


}
