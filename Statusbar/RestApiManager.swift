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

enum httpError: Error {
    case validationError(String)
    case clientError(String)
}

class RestApiManager {
    static let sharedInstance = RestApiManager()
    let baseURL = Config.API_URL

    func getData(_ path: String, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + path
        makeHTTPGetRequest(route, onCompletion: { json, _ in
            do {
                let data = try self.verifyResponse(json)
                onCompletion(data)
            } catch {
                return
            }
        })
    }

    func verifyResponse(_ result: JSON)throws -> JSON {

        if(result == JSON.null || result.rawString() == "") {
            throw httpError.validationError("empty response")
        }

        if let error = result["error"].string {
            throw httpError.clientError(error)
        }

        if let error = result["error"].dictionary {
            throw httpError.clientError("invalid request: \(error)")
        }

        return result
    }

    func makeHTTPGetRequest(_ path: String, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(
            url: URL(string: path)!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 5)

        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
            guard data != nil else {
                onCompletion(JSON.null, error)
                return
            }

            do {
                let json: JSON = try JSON(data: data!)
                onCompletion(json, error)
            } catch {
                // ehhhhhh
                print("error occurred")
            }

        }

        task.resume()
    }
}
