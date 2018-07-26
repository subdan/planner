//
//  GeocodingService.swift
//  planner
//
//  Created by Daniil Subbotin on 02/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation
import Alamofire

enum ServiceResult<Value> {
    case success(Value)
    case failure(Error)
}

class GeocodingService {
    
    private enum Constants {
        static let apiKey = ВСТАВЬТЕ_СВОЙ_КЛЮЧ_СЮДА
        static let baseURL = "https://maps.googleapis.com/maps/api"
        static let error = NSError(domain: "GeocodingService", code: 0, userInfo: nil)
    }
    
    private enum Methods {
        static let geocode = "/geocode"
    }
    
    private enum Formats {
        static let json = "/json"
    }
    
    private var request: DataRequest?
    
    func getAddress(lat: Double, lon: Double, completion: ((ServiceResult<GeocodingResult>) -> Void)?) {
        
        let parameters: Parameters = [
            "latlng": "\(lat),\(lon)",
            "language": "ru",
            "result_type": "street_address",
            "key": Constants.apiKey
        ]
        
        let url = URL.init(string: Constants.baseURL + Methods.geocode + Formats.json)!
        
        if request != nil {
            request?.cancel()
        }
        
        request = Alamofire.request(
            url,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: nil)
        
        request?.responseData { respone in
            switch respone.result {
            case .failure(let error):
                completion?(.failure(error))
            case .success(let data):
                do {
                    let payload = try JSONDecoder().decode(GeocodingResult.self, from: data)
                    completion?(.success(payload))
                } catch let error {
                    completion?(.failure(error))
                }
            }
        }
    }
    
}
