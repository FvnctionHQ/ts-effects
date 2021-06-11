//
//  TSConverter.swift
//  Transfer
//
//  Created by Alex Linkov on 8/15/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import Foundation
import AudioKit
import AVFoundation

public typealias TSConverterCallback = (URL?, Error?) -> Void

class TSConverter: NSObject {
    
    
    static func printAudioDescriptionForFile(path: URL) {
        let file = try! TSAudioFile(forReading: path)
        let asbd: AudioStreamBasicDescription =  file.fileFormat.streamDescription.pointee
        
        print("  Filename:            \(file.fileName)")
        print("  Filepath:            \(file.url.lastPathComponent)")
        print("  Sample Rate:         \(asbd.mSampleRate)")
        print("  Channels:            \(file.channelCount)")
        print("  Duration:            \(file.duration)")
        print("  MimeType:            \(file.mimeType ?? "ERR")")
        print("  Common Format:       \(file.commonFormatString )")
        
        
    }
    
    static func toNSData(PCMBuffer: AVAudioPCMBuffer) -> NSData {
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        let ch0Data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameCapacity * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
    }

    static func toPCMBuffer(data: NSData) -> AVAudioPCMBuffer {
        let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 48000, channels: 1, interleaved: false)  // given NSData audio format
        let PCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity:  UInt32(data.length) / audioFormat!.streamDescription.pointee.mBytesPerFrame)
        PCMBuffer!.frameLength = PCMBuffer!.frameCapacity
        let channels = UnsafeBufferPointer(start: PCMBuffer!.int16ChannelData, count: Int(PCMBuffer!.format.channelCount))
        data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
        return PCMBuffer!
    }
    
    
    static func fileForAudioData(data: NSData) -> TSAudioFile {
        
        let PCMFromData = TSConverter.toPCMBuffer(data: data)
        let fileFromData = try! TSAudioFile(fromAVAudioPCMBuffer: PCMFromData, baseDir: .temp, name: "result")
        
        return fileFromData

    }

    
    static func audioDataForFile(path: URL) -> NSData? {
        
        if let file = try? TSAudioFile(forReading: path) {
            
            let asbd: AudioStreamBasicDescription =  file.fileFormat.streamDescription.pointee
            let bytesPerSample = asbd.mBytesPerFrame;
            let numFrames = file.samplesCount
            let audioByteSize = Int(Int64(bytesPerSample) * numFrames)
            var fileRef: ExtAudioFileRef? = nil
            
            var err: OSStatus = ExtAudioFileOpenURL(file.url as CFURL, &fileRef)
            
            print(err)
            
            
            let rawAudioBytes = UnsafeMutableRawPointer.allocate(byteCount: audioByteSize, alignment: MemoryLayout<CUnsignedChar>.alignment)

            
            let audioBuffer = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(audioByteSize), mData: rawAudioBytes)
            
            var audioBufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: audioBuffer)
            
            var ioFrames:UInt32 = UInt32(file.samplesCount)
            
            err = ExtAudioFileRead(fileRef!, &ioFrames, &audioBufferList)
            print(err)
            
            
            err = ExtAudioFileDispose(fileRef!)
            print(err)
            
            if (err != 0) {
                return nil
            }
            
            let data = NSData(bytesNoCopy: rawAudioBytes, length: audioByteSize, freeWhenDone: true)
            
            return data
            
        } else {
            
            return nil
            
        }
        
       

        
        
        
    }
    
    
    static func convertToWav(filePath: URL, channelCount: Int, inputFile: AVAudioFile, completionHandler:  @escaping TSConverterCallback )  {
        
  
        
        var options = FormatConverter.Options()
        options.format = "wav"
        options.sampleRate = 48000
        options.bitDepth = 16
        options.channels = UInt32(channelCount)
        
        
        
        let converter = FormatConverter(inputURL: inputFile.url, outputURL: filePath, options: options)
        converter.start { (error) in
            
            if (error != nil) {
                completionHandler(nil, error)
                
            } else {
                
                completionHandler(filePath, nil)
            }
            
        }
        
    }
   
    
    static func convertToWav(channelCount: Int, inputFile: AVAudioFile, completionHandler:  @escaping TSConverterCallback )  {
        
        // let paths = FileManager.default.temporaryDirectory
        let tempDirectory = FileManager.default.temporaryDirectory
        let trimmed = inputFile.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: " ", with: "").lowercased(with: .current)
        let filePath = tempDirectory.appendingPathComponent(trimmed + ".wav")
        
        
        
        var options = FormatConverter.Options()
        options.format = "wav"
        options.sampleRate = 48000
        options.bitDepth = 16
        options.channels = UInt32(channelCount)
        
        
        
        let converter = FormatConverter(inputURL: inputFile.url, outputURL: filePath, options: options)
        converter.start { (error) in
            
            if (error != nil) {
                completionHandler(nil, error)
                
            } else {
                
                completionHandler(filePath, nil)
            }
            
        }
        
    }
    

}
extension Data {
    init(buffer: AVAudioPCMBuffer) {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        self.init(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }

    func makePCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let streamDesc = format.streamDescription.pointee
        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }

        buffer.frameLength = buffer.frameCapacity
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers

        withUnsafeBytes { (bufferPointer) in
            guard let addr = bufferPointer.baseAddress else { return }
            audioBuffer.mData?.copyMemory(from: addr, byteCount: Int(audioBuffer.mDataByteSize))
        }

        return buffer
    }
}
