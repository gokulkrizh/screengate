//
//  DateComponents+Extensions.swift
//  DeviceActivityMonitorDemo
//
//  Created by Gokul on 2025/11/05.
//

import Foundation

extension DateComponents {
    var withCalendarTimeZone: DateComponents {
        var new = self
        new.timeZone = .current
        new.calendar = .current
        return new
    }
}
