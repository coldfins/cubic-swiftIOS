//
//  AudioGetter.swift
//  cubic_asr_test
//
//  Created by Forsad Al Hossain on 5/27/16.
//  Copyright © 2016 cobaltspeech. All rights reserved.

import Foundation
import AudioToolbox

class CobaltCurrentRecogResults
{
    static var fullRecognitionResult = [String]()
    static var currentRecognitionResult = ""
    {
        didSet
        {
            fullRecognitionResult.append(currentRecognitionResult)
        }
    }
    static func initiateNewRecognition()
    {
        fullRecognitionResult = []
        currentRecognitionResult = ""
        setupCallBack()
    }
    
    static func setupCallBack()
    {
        
        setupCallbacks { (resultC:CubicString!) in
            
            let resultsMessage = String(cString:resultC)
            let data = resultsMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                CobaltCurrentRecogResults.currentRecognitionResult = CobaltJSONUtils.parseNbestFromJSON(json)
            }
            catch let error as NSError
            {
                print("Could not set up display; Error: "+error.localizedDescription)
            }
        }
    }
}


struct RecorderSettings
{
    static let sampleRate = 16000.0
    static let formatID = kAudioFormatLinearPCM
    static let formatFlags = (kLinearPCMFormatFlagIsSignedInteger|kLinearPCMFormatFlagIsPacked)
    static let bytesPerPacket = UInt32(MemoryLayout<Int16>.size)
    static let framesPerPacket:UInt32 = 1
    static let bytesPerFrame = UInt32(MemoryLayout<Int16>.size)
    static let channelsPerFrame:UInt32 = 1
    static let bitsPerChannel = UInt32(MemoryLayout<Int16>.size*8)
    static let reserved:UInt32 = 0
}

@objc(AudioRecorder)
open class AudioRecorder:NSObject
{
    
    
    fileprivate var mRecordState:RecordState!
    
    fileprivate var mAudioDataFormat=AudioStreamBasicDescription(
            mSampleRate: RecorderSettings.sampleRate,
            mFormatID: RecorderSettings.formatID,
            mFormatFlags: RecorderSettings.formatFlags,
            mBytesPerPacket: RecorderSettings.bytesPerPacket,
            mFramesPerPacket: RecorderSettings.framesPerPacket,
            mBytesPerFrame: RecorderSettings.bytesPerFrame,
            mChannelsPerFrame: RecorderSettings.channelsPerFrame,
            mBitsPerChannel: RecorderSettings.bitsPerChannel,
            mReserved: RecorderSettings.reserved)
    
    
    fileprivate let mNumBuffer = 3
    
    fileprivate let mBufferSize:UInt32 = 8192
    
    fileprivate let mRecognizerName = "The_recognizer"
    
    fileprivate let mSynchronous:Int32 = 0
    
    fileprivate typealias swiftAudioInputCallBackFunc = AudioInputCallBackFunc.swiftAudioInputCallBackFunc
    
    fileprivate var audioInputCallBackFunc:swiftAudioInputCallBackFunc = AudioInputCallBackFunc.AudioInputCallBackFunc
    
    fileprivate var mBlock = false;
    
    fileprivate var mRecording = false;
    
    @objc open func startRecording(_ modelId:String, block:Bool) //block will push backlog_empty event
    {
        objc_sync_enter(self)
        
        if mRecording  //If not in recording state; returning with releasing the lock
        {
            objc_sync_exit(self);
            return
        }
        print("inside startRecording");
        CobaltCurrentRecogResults.initiateNewRecognition()
        
        mBlock = block;
        
        mRecordState.recognizer = AsrRecognizer(mRecognizerName,modelId,mSynchronous,mBlock)
        
        if mRecordState.recognizer == nil //If we fail to create the recognizer we return with releasing the lock
        {
            objc_sync_exit(self)
            return;
        }
        
        mRecordState.currentPacket = 0;
        
        let audioQueueRefRef = UnsafeMutablePointer<AudioQueueRef?>.allocate(capacity: 1)
        
        let status = AudioQueueNewInput(&mAudioDataFormat, audioInputCallBackFunc! as! AudioQueueInputCallback, &mRecordState, nil, (CFRunLoopMode.commonModes as! CFString), 0, audioQueueRefRef)
        
        mRecordState.queue = audioQueueRefRef.pointee!
        
        audioQueueRefRef.deallocate(capacity: 1)
        
        if status == 0 && mRecordState.recognizer != nil
        {
            mRecordState.buffersArray = Array(repeating: nil, count: mNumBuffer)
            
            for var buffer in mRecordState.buffersArray
            {
                AudioQueueAllocateBuffer(mRecordState.queue, mBufferSize, &buffer)
                AudioQueueEnqueueBuffer(mRecordState.queue, buffer!, 0,nil)
            }
            mRecordState.opQueue.startQueue()
            mRecordState.recording=true
            AudioQueueStart(mRecordState.queue,nil)
            mRecording = true;
            print("Started recording audio")
        }
        else //If we fail to start audio recording we stop the recognizer
        {
            mRecordState.recognizer.stop()
            print("Cannot start recording!")
        }
        objc_sync_exit(self)
    }
    
    
    @objc open func stop() -> [String]
    {
        objc_sync_enter(self);
        if !mRecording //If not in recording state; release the lock and exit
        {
            objc_sync_exit(self)
            return []
        }
        mRecording = false;
        if mBlock
        {
            AudioQueueFlush(mRecordState.queue);
        }
        AudioQueueStop(mRecordState.queue, true)
        AudioQueueDispose(mRecordState.queue,true)
        mRecordState.opQueue.finish()
        let result = mRecordState.recognizer.stop()
        mRecordState.recording = false
        print("Stopped recording audio")
        objc_sync_exit(self)
        return result
    }
}
