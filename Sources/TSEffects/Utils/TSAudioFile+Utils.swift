//
//  TSAudioFile+Utils.swift
//  Transfer
//
//  Created by Alex Linkov on 8/17/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import Foundation
//
//  AKAudioFile+Processing.swift
//  AudioKit
//
//  Created by Laurent Veliscek, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
//
//  IMPORTANT: Any AKAudioFile process will output a .caf AKAudioFile
//  set with a PCM Linear Encoding (no compression)
//  But it can be applied to any readable file (.wav, .m4a, .mp3...)
//
extension TSAudioFile {

    /// Normalize an AKAudioFile to have a peak of newMaxLevel dB.
    ///
    /// - Parameters:
    ///   - baseDir: where the file will be located, can be set to .resources,  .documents or .temp
    ///   - name: the name of the file without its extension (String).  If none is given, a unique random name is used.
    ///   - newMaxLevel: max level targeted as a Float value (default if 0 dB)
    ///
    /// - returns: An AKAudioFile, or nil if init failed.
    ///
    public func normalized(baseDir: BaseDirectory = .temp,
                           name: String = UUID().uuidString,
                           newMaxLevel: Float = 0.0 ) throws -> TSAudioFile {

        let level = self.maxLevel
        
        
        var path = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        //var outputFile = try AKAudioFile (writeIn: baseDir, name: name)
        var outputFile = try TSAudioFile(forWriting: path, settings: [:])

        if self.samplesCount == 0 {
            return try TSAudioFile(forReading: outputFile.url)
        }

        if level == Float.leastNormalMagnitude {
            return try TSAudioFile(forReading: outputFile.url)
        }

        let gainFactor = Float( pow(10.0, newMaxLevel / 20.0) / pow(10.0, level / 20.0))

        let arrays = self.floatChannelData ?? [[]]

        var newArrays: [[Float]] = []
        for array in arrays {
            let newArray = array.map { $0 * gainFactor }
            newArrays.append(newArray)
        }

        outputFile = try TSAudioFile(createFileFromFloats: newArrays,
                                     baseDir: baseDir,
                                     name: name)
        return try TSAudioFile(forReading: outputFile.url)
    }

    /// Returns an AKAudioFile with audio reversed (will playback in reverse from end to beginning).
    ///
    /// - Parameters:
    ///   - baseDir: where the file will be located, can be set to .resources,  .documents or .temp
    ///   - name: the name of the file without its extension (String).  If none is given, a unique random name is used.
    ///
    /// - Returns: An AKAudioFile, or nil if init failed.
    ///
    public func reversed(baseDir: BaseDirectory = .temp,
                         name: String = UUID().uuidString ) throws -> TSAudioFile {

        var outputFile = try TSAudioFile (writeIn: baseDir, name: name)

        if self.samplesCount == 0 {
            return try TSAudioFile(forReading: outputFile.url)
        }

        let arrays = self.floatChannelData ?? [[]]

        var newArrays: [[Float]] = []
        for array in arrays {
            newArrays.append(Array(array.reversed()))
        }
        outputFile = try TSAudioFile(createFileFromFloats: newArrays,
                                     baseDir: baseDir,
                                     name: name)
        return try TSAudioFile(forReading: outputFile.url)
    }

    /// Returns an AKAudioFile with appended audio data from another AKAudioFile.
    ///
    /// Notice that Source file and appended file formats must match.
    ///
    /// - Parameters:
    ///   - file: an AKAudioFile that will be used to append audio from.
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp
    ///   - name: the name of the file without its extension (String).  If none is given, a unique random name is used.
    ///
    /// - Returns: An AKAudioFile, or nil if init failed.
    ///
    public func appendedBy(file: TSAudioFile,
                           baseDir: BaseDirectory = .temp,
                           name: String = UUID().uuidString) throws -> TSAudioFile {

        var sourceBuffer = self.pcmBuffer
        var appendedBuffer = file.pcmBuffer

        if self.fileFormat != file.fileFormat {

            // We use extract method to get a .CAF file with the right format for appending
            // So sourceFile and appended File formats should match
            do {
                // First, we convert the source file to .CAF using extract()
                let convertedFile = try self.extracted()
                sourceBuffer = convertedFile.pcmBuffer

                if convertedFile.fileFormat != file.fileFormat {
                    do {
                        // If still don't match we convert the appended file to .CAF using extract()
                        let convertedAppendFile = try file.extracted()
                        appendedBuffer = convertedAppendFile.pcmBuffer
                    } catch let error as NSError {
                        throw error
                    }
                }
            } catch let error as NSError {
                throw error
            }
        }

        // We check that both pcm buffers share the same format
        if appendedBuffer.format != sourceBuffer.format {
            let userInfo: [AnyHashable: Any] = [
                NSLocalizedDescriptionKey: NSLocalizedString(
                    "AKAudioFile append process Error",
                    value: "Couldn't match source file format with appended file format",
                    comment: ""),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                    "AKAudioFile append process Error",
                    value: "Couldn't match source file format with appended file format",
                    comment: "")
            ]
            throw NSError(domain: "AKAudioFile ASync Process Unknown Error", code: 0, userInfo: userInfo as? [String: Any])
        }

        let outputFile = try TSAudioFile (writeIn: baseDir, name: name)

        // Write the buffer in file
        do {
            try outputFile.write(from: sourceBuffer)
        } catch let error as NSError {
            throw error
        }

        do {
            try outputFile.write(from: appendedBuffer)
        } catch let error as NSError {
            throw error
        }

        return try TSAudioFile(forReading: outputFile.url)
    }

    /// Returns an AKAudioFile that will contain a range of samples from the current AKAudioFile
    ///
    /// - Parameters:
    ///   - fromSample: the starting sampleFrame for extraction.
    ///   - toSample: the ending sampleFrame for extraction
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp
    ///   - name: the name of the file without its extension (String).  If none is given, a unique random name is used.
    ///
    /// - Returns: An AKAudioFile, or nil if init failed.
    ///
    public func extracted(fromSample: Int64 = 0,
                          toSample: Int64 = 0,
                          baseDir: BaseDirectory = .temp,
                          name: String = UUID().uuidString) throws -> TSAudioFile {

        let fixedFrom = abs(fromSample)
        let fixedTo: Int64 = toSample == 0 ? Int64(self.samplesCount) : min(toSample, Int64(self.samplesCount))
        if fixedTo <= fixedFrom {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }

        let arrays = self.floatChannelData ?? [[]]

        var newArrays: [[Float]] = []

        for array in arrays {
            let extract = Array(array[Int(fixedFrom)..<Int(fixedTo)])
            newArrays.append(extract)
        }

        let newFile = try TSAudioFile(createFileFromFloats: newArrays, baseDir: baseDir, name: name)
        return try TSAudioFile(forReading: newFile.url)
    }
}
