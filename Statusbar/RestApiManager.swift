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

class RestApiManager {
    static let sharedInstance = RestApiManager()
    let baseURL = Config.API_URL

    func getLocationVisitData(_ id: Int, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "\(id)/visits"
        makeHTTPGetRequest(route, onCompletion: { json, _ in
            onCompletion(json as JSON)
        })
    }

    func getLocationData(_ id: Int, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "\(id)"
        makeHTTPGetRequest(route, onCompletion: { json, _ in
            onCompletion(json as JSON)
        })
    }

    func getLocationsData(onCompletion: @escaping (JSON) -> Array<LocationModel>) {
        let route = baseURL
        makeHTTPGetRequest(route, onCompletion: { json, _ in
            onCompletion(json as JSON)
        })
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
                    onCompletion(JSON.null, error)
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
