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

enum clientError: Error {
    case validationError(String)
}

class RestApiManager {
    static let sharedInstance = RestApiManager()
    let baseURL = Config.API_URL

    func getLocationVisitData(_ id: Int, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "\(id)/visits"
        makeHTTPGetRequest(route, onCompletion: { json, _ in
            do {
                let data = try self.verifyResponse(json)
                onCompletion(data)
            }catch{
                return
            }
        })
    }

    func getLocationData(_ id: Int, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "\(id)"
        makeHTTPGetRequest(route, onCompletion: { json, _ in
            do {
                let data = try self.verifyResponse(json)
                onCompletion(data)
            }catch{
                return
            }
            
        })
    }

    func getLocationsData(onCompletion: @escaping (JSON) -> Array<LocationModel>) {
        let route = baseURL
        makeHTTPGetRequest(route, onCompletion: { json, _ in
            do {
                let data = try self.verifyResponse(json)
                onCompletion(data)
            }catch{
                return
            }
        })
    }
    
    func verifyResponse(_ result: JSON)throws -> JSON {
        
        if(result == JSON.null || result.rawString() == "") {
            print("empty response")
            throw clientError.validationError("empty response")
        }

        if let error = result["error"].string {
            print("error recieved")
            print(error)
            throw clientError.validationError("invalid response")
        }

        if let error = result["error"].dictionary {
            //Now you got your value
            print(error)
            throw clientError.validationError("invalid response")
        }
        
        return result;
    }

    func makeHTTPGetRequest(_ path: String, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: URL(string: path)!)

        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in

            if(data == nil) {
                onCompletion(JSON.null, error)
            }

            guard let data = data else {
                onCompletion(JSON.null, error)
                return
            }

            do {
                guard let json: JSON = try JSON(data: data) else {
                    print("empty response");
                }
                onCompletion(json, error)
            } catch {
                // ehhhhhh
                print("error occurred")
            }

        }

        task.resume()
    }
}
