//
//  Recognizer_sw.swift
//  cubic_asr_test
//
//  Created by Forsad Al Hossain on 5/27/16.
//  Copyright © 2016 cobaltspeech. All rights reserved.
//

import Foundation
import AudioToolbox

protocol  Recognizer : class
{
    func pushAudio(_ audioData:UnsafeMutableRawPointer, _ numSamples:Int32)->Bool
    func stop() -> [String]
}

class AsrRecognizer:Recognizer
{
    fileprivate var mRecognizerId:String!
    fileprivate var mPushBackLogEmpty:Bool
    
    init?(_ recognizerId:String,_ modelId:String,_ synchronus:Int32,_ blockStopRecording:Bool)
    {
        mRecognizerId=recognizerId
        mPushBackLogEmpty = blockStopRecording;
        let ret=Api_NewRecognizer(recognizerId, modelId, synchronus)
        if ret.error != 0
        {
            return nil
        }
    }
    
    func pushAudio(_ audioDataBytes:UnsafeMutableRawPointer, _ numSamples:Int32) -> Bool
    {
        if mRecognizerId == nil
        {
            return false
        }
        
        let event=UnsafeMutablePointer<RecognitionEvent>.allocate(capacity: 1)
        event.pointee.eventType = AUDIO_EVENT
        let audioEvent=UnsafeMutablePointer<AudioEvent>.allocate(capacity: 1)
        audioEvent.pointee.sizeInBytes = UInt(numSamples)
        audioEvent.pointee.audioBuffer = UnsafeMutablePointer<UInt8>(audioDataBytes.assumingMemoryBound(to: UInt8.self))
        event.pointee.bytes = audioEvent
        let ret=Recognizer_PushEvent(mRecognizerId!, event)
        audioEvent.deallocate(capacity: 1)
        event.deallocate(capacity: 1)
        return (ret.error == 0)
    }
    
    fileprivate func pushBackLogEmptyEvent()
    {
        let event=UnsafeMutablePointer<RecognitionEvent>.allocate(capacity: 1)
        event.pointee.eventType = BACKLOG_EMPTY
        let audioEvent=UnsafeMutablePointer<AudioEvent>.allocate(capacity: 1)
        audioEvent.pointee.sizeInBytes = 0
        event.pointee.bytes = audioEvent
        Recognizer_PushEvent(mRecognizerId!, event)
        audioEvent.deallocate(capacity: 1)
        event.deallocate(capacity: 1)
    }
    
    fileprivate func pushSessionEndEvent()
    {
        let event=UnsafeMutablePointer<RecognitionEvent>.allocate(capacity: 1)
        event.pointee.eventType = SESSION_END
        let audioEvent=UnsafeMutablePointer<AudioEvent>.allocate(capacity: 1)
        audioEvent.pointee.sizeInBytes = 0
        event.pointee.bytes = audioEvent
        Recognizer_PushEvent(mRecognizerId!, event)
        audioEvent.deallocate(capacity: 1)
        event.deallocate(capacity: 1)
    }
    
    func stop() -> [String]
    {
        if(mPushBackLogEmpty)
        {
            pushBackLogEmptyEvent();
        }
        pushSessionEndEvent()
        Api_DeleteRecognizer(mRecognizerId)
        return [""]
    }
}
