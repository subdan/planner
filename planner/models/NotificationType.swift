//
//  NotificationRepeatType.swift
//  planner
//
//  Created by Daniil Subbotin on 08/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation

enum NotificationType: Int {
    
    case none = -1
    case on_time = 0
    case time_5_min_before = 5
    case time_15_min_before = 15
    case time_30_min_before = 30
    case time_1_hour_before = 60
    case time_2_hour_before = 120
    case time_1_day_before = 86400
    case time_2_day_before = 172800
    case time_1_week_before = 604800
    
    static let allValues = [
        none,
        on_time,
        time_5_min_before,
        time_15_min_before,
        time_30_min_before,
        time_1_hour_before,
        time_2_hour_before,
        time_1_day_before,
        time_2_day_before,
        time_1_week_before
    ]
    
    func dateComponent() -> Calendar.Component {
        switch self {
        case .none, .on_time, .time_5_min_before, .time_15_min_before, .time_30_min_before:
            return .minute
        case .time_1_hour_before, .time_2_hour_before:
            return .hour
        case .time_1_day_before, .time_2_day_before:
            return .day
        case .time_1_week_before:
            return .day
        }
    }
    
    func dateValue() -> Int {
        switch self {
        case .none, .on_time:
            return 0
        case .time_5_min_before:
            return 5
        case .time_15_min_before:
            return 15
        case .time_30_min_before:
            return 30
        case .time_1_hour_before:
            return 1
        case .time_2_hour_before:
            return 2
        case .time_1_day_before:
            return 1
        case .time_2_day_before:
            return 2
        case .time_1_week_before:
            return 7
        }
    }
    
    func toString() -> String {
        switch self {
        case .none:
            return "Нет"
        case .on_time:
            return "В момент события"
        case .time_5_min_before:
            return "За 5 мин"
        case .time_15_min_before:
            return "За 15 мин"
        case .time_30_min_before:
            return "За 30 мин"
        case .time_1_hour_before:
            return "За 1 ч"
        case .time_2_hour_before:
            return "За 2 ч"
        case .time_1_day_before:
            return "За 1 день"
        case .time_2_day_before:
            return "За 2 дня"
        case .time_1_week_before:
            return "За 1 нед"
        }
    }
    
    func toTitleString() -> String {
        switch self {
        case .none:
            return "Нет"
        case .on_time:
            return "Сейчас"
        case .time_5_min_before:
            return "Через 5 мин"
        case .time_15_min_before:
            return "Через 15 мин"
        case .time_30_min_before:
            return "Через 30 мин"
        case .time_1_hour_before:
            return "Через 1 час"
        case .time_2_hour_before:
            return "Через 2 чача"
        case .time_1_day_before:
            return "Через 1 день"
        case .time_2_day_before:
            return "Через 2 дня"
        case .time_1_week_before:
            return "Через неделю"
        }
    }
}
