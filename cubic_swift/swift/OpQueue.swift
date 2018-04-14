//
//  OpQueue.swift
//  cubic_asr_test
//
//  Created by Forsad Al Hossain on 6/20/16.
//  Copyright © 2016 cobaltspeech. All rights reserved.
//

import Foundation

class OpQueue
{
    fileprivate var mOpQueue:OperationQueue!
    func startQueue() -> Bool
    {
        mOpQueue = OperationQueue()
        return true
    }
    
    func addOpBlock(_ block: @escaping ()-> Void)
    {
        mOpQueue.addOperation(block)
    }
    
    func finish()
    {
        mOpQueue.waitUntilAllOperationsAreFinished()
        mOpQueue = nil
    }
    
    func terminate()
    {
        mOpQueue.isSuspended = true
        mOpQueue.cancelAllOperations()
        mOpQueue.isSuspended = false;
        mOpQueue = nil
    }
}
