//
//  AudioInputCallBack.swift
//  cubic_asr_test
//
//  Created by Forsad Al Hossain on 6/1/16.
//  Copyright © 2016 cobaltspeech. All rights reserved.
//

import Foundation
import AudioToolbox


struct RecordState
{
    var queue:AudioQueueRef
    var buffersArray: Array<AudioQueueBufferRef?>
    var audioFile:AudioFileID!
    var currentPacket:Int64! = 0
    var recording:Bool! = false
    var recognizer:Recognizer! = nil
    let opQueue = OpQueue()
}

class AudioInputCallBackFunc
{
    typealias swiftAudioInputCallBackFunc = (@convention(c) (UnsafeMutableRawPointer,AudioQueueRef, AudioQueueBufferRef,UnsafePointer<AudioTimeStamp>,UInt32, UnsafePointer<AudioStreamPacketDescription>) -> Void)?
    
    static let AudioInputCallBackFunc:swiftAudioInputCallBackFunc =
    {
        (inUserData:UnsafeMutableRawPointer,
        inAQ:AudioQueueRef,
        inBuffer:AudioQueueBufferRef,
        inStartTime:UnsafePointer<AudioTimeStamp>,
        inNumberPacketDescriptions:UInt32,
        inPacketDescs:UnsafePointer<AudioStreamPacketDescription>) -> Void in
        
        let recordStatePtr = UnsafeMutablePointer<RecordState>(inUserData.assumingMemoryBound(to: RecordState.self))
        let memSize=Int(inBuffer.pointee.mAudioDataByteSize)
        let numSamples = memSize/MemoryLayout<Int16>.size
        let audioDataInBuffer = inBuffer.pointee.mAudioData
        let audioPtr = malloc(memSize)
        memcpy(audioPtr,audioDataInBuffer,memSize)
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
        
        recordStatePtr.pointee.opQueue.addOpBlock
        {
            recordStatePtr.pointee.recognizer.pushAudio(audioPtr!,Int32(numSamples))
            free(audioPtr)
        }
    }
}

