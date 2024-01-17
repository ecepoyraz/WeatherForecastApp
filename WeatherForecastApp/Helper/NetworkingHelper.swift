//
//  NetworkingHelper.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 14.01.2024.
//

import Foundation
import Alamofire
import UIKit


class NetworkingHelper {
    
    static let shared = NetworkingHelper()
    
    typealias Callback<T:Codable> = (Result<T,Error>)->Void
    
    public func getDataFromRemote<T:Codable>(url:String,method:HTTPMethod, params: Parameters,encoding:ParameterEncoding = URLEncoding.default, callback:@escaping Callback<T>){
        
        AF.request(url, method: method, parameters: params, encoding: encoding).validate().responseJSON(completionHandler: { response in
            
            switch response.result {
            case .success(let object):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: object)
                    let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
                    
                    callback(.success(decodedData))
                } catch {
                    callback(.failure(error))
                }
                
            case .failure(let err):
                callback(.failure(err))
            }
        })
    }
}
