//
//  RestApiManager.swift
//  Pods
//
//  Created by Erik de Groot on 18/07/16.
//
//

import Cocoa
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    let baseURL = Config.API_URL
    
    
    
        
        
        
    func getLocationData(id:Int, onCompletion: (JSON) -> Void) {
            let route = baseURL + "\(id)";
            makeHTTPGetRequest(route, onCompletion: { json, err in
                onCompletion(json as JSON)
            })
        }
        
        func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
            let request = NSMutableURLRequest(URL: NSURL(string: path)!)
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let json:JSON = JSON(data: data!)
                onCompletion(json, error)
            })
            task.resume()
        }
    }

