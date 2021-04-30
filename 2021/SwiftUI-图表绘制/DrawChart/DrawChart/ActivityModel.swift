//
//  ActivityModel.swift
//  DrawChart
//
//  Created by ZZJ on 2021/4/30.
//

import Foundation

struct ActivityLog {
    var distance: Double // Miles
    var duration: Double // Seconds
    var elevation: Double // Feet
    var date: Date
}

class ActivityTestData {
    
    static let testData: [ActivityLog] = [
            ActivityLog(distance: 1.77, duration: 2100, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 )),
            ActivityLog(distance: 3.01, duration: 2800, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 1468800)),
            ActivityLog(distance: 8.12, duration: 3400, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 1900800)),
            ActivityLog(distance: 2.22, duration: 3400, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 2678400)),
            ActivityLog(distance: 3.12, duration: 3400, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 2678400)),
            ActivityLog(distance: 9.01, duration: 3200, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 3628800)),
            ActivityLog(distance: 7.20, duration: 3400, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 3628800)),
            ActivityLog(distance: 4.76, duration: 3200, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 4406400)),
            ActivityLog(distance: 12.12, duration: 2100, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 4406400)),
            ActivityLog(distance: 6.01, duration: 3400, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 5097600)),
            ActivityLog(distance: 8.20, duration: 3400, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 6048000)),
            ActivityLog(distance: 4.76, duration: 2100, elevation: 156, date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 6048000))
    ]
 
}
