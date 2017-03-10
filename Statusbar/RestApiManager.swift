//
//  RestApiManager.swift
//  Pods
//
//  Created by Erik de Groot on 18/07/16.
//
//

import Cocoa
import SwiftyJSON

typealias ServiceResponse = (JSON, Error?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    let baseURL = Config.API_URL
    
    
    
    
    func getLocationVisitData(_ id:Int, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "\(id)/visits";
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    
    func getLocationData(_ id:Int, onCompletion: @escaping (JSON) -> Void) {
            let route = baseURL + "\(id)";
            makeHTTPGetRequest(route, onCompletion: { json, err in
                onCompletion(json as JSON)
            })
        }
        
        func makeHTTPGetRequest(_ path: String, onCompletion: @escaping ServiceResponse) {
            let request = NSMutableURLRequest(url: URL(string: path)!)

            let task = URLSession.shared.dataTask(with: request as URLRequest){data, response, error -> Void in
                if(data == nil)
                {
                    onCompletion(JSON.null, error)
                }else{
                    let json:JSON = JSON(data: data!);
                    onCompletion(json, error)
                }
            }
            task.resume()
        }
    }

