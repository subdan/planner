//
//  GeocodingResult.swift
//  planner
//
//  Created by Daniil Subbotin on 02/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation

struct GeocodingResult: Decodable {
    
    let results: [GeocodingResultItem]
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case results
        case status
    }
}

struct GeocodingResultItem: Decodable {
    
    let formattedAddress: String
    
    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
    }
}
