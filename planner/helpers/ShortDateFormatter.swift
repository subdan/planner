//
//  DateHelper.swift
//  planner
//
//  Created by Daniil Subbotin on 08/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation

class ShortDateFormat {
    
    static var formatter: DateFormatter?
    
    static func formatDate(_ date: Date) -> String {
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.locale = Locale(identifier: "ru")
            formatter!.dateStyle = .medium
            formatter!.timeStyle = .short
        }
        return formatter!.string(from: date)
    }
    
}
