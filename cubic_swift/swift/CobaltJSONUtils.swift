//
//  CobaltJSONParser.swift
//  cubic_asr_test
//
//  Created by Forsad Al Hossain on 7/10/16.
//  Copyright © 2016 cobaltspeech. All rights reserved.
//

import Foundation


struct CobaltJSONFields
{
    static let MESSAGE = "message"
    static let NBEST = "nbest"
    static let RESULT = "results"
    static let STATUS = "status"
    static let PARTIAL = "partial"
    static let FINAL = "final"
    static let HYPOTHESIS = "hypothesis"
    static let VALUE = "value"
}

class CobaltJSONUtils
{
    static func createDataFromJSON(_ json:[String:AnyObject]) -> Data?
    {
        let jsonData:Data?
        do
        {
            jsonData = try JSONSerialization.data(withJSONObject: json, options:[])
        }
        catch
        {
            print("Creating Data from Json failed")
            jsonData = nil;
        }
        return jsonData
    }
    
    static func parseJSONDataForField(_ data:Data?,fieldName:String?) -> AnyObject?
    {
        let dataJson:[String:AnyObject]
        do
        {
            dataJson = try JSONSerialization.jsonObject(with: data!,options:[]) as! [String:AnyObject]
            print("\(dataJson)")
        }
        catch
        {
            print("Json parsing from Data failed")
            return nil
        }
        return dataJson[fieldName!]
    }
    
    static func parseResult(_ data:Data) -> [String]
    {
        var ans = [AnyObject]()
        do
        {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            ans = json[CobaltJSONFields.RESULT] as! [AnyObject]
        }
        catch
        {
            print("An Error Occured: Cannot Parse Json data returned from server")
        }
        var result = [String]()
        for obj in ans
        {
            let json = obj as! [String:AnyObject]
            print(json)
                
            let status = json[CobaltJSONFields.STATUS] as! String
            if status == CobaltJSONFields.PARTIAL
            {
                continue
            }
            result.append(CobaltJSONUtils.parseNbestFromJSON(json))
        }
        return result
    }
    static func parseNbestFromJSON(_ json:[String:AnyObject]) -> String
    {
        let nbest = json[CobaltJSONFields.NBEST] as! [AnyObject]
        
        let best = nbest.first
        var result = ""
        let hypothesis = best?[CobaltJSONFields.HYPOTHESIS] as? [AnyObject] ?? []
        for hypo in hypothesis
        {
            let value = hypo[CobaltJSONFields.VALUE] as! String
            if result == ""
            {
               result = value
            }
            else
            {
                result = result + " " + value
            }
        }
        return result
    }
}
