//
//  ActivityHistoryText.swift
//  DrawChart
//
//  Created by ZZJ on 2021/4/30.
//

import SwiftUI

struct ActivityHistoryText: View {
    
    var logs: [ActivityLog]
    var mileMax: Int
    
    @Binding var selectedIndex: Int
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }
    
    init(logs: [ActivityLog], selectedIndex: Binding<Int>) {
        self._selectedIndex = selectedIndex
        
        let curr = Date() // 当前日期
        let sortedLogs = logs.sorted { (log1, log2) -> Bool in
            log1.date > log2.date
        } // 按时间顺序对日志进行排序
        
        var mergedLogs: [ActivityLog] = []

        for i in 0..<12 {

            var weekLog: ActivityLog = ActivityLog(distance: 0, duration: 0, elevation: 0, date: Date().addingTimeInterval(TimeInterval(-604800 * i)))

            for (indx,log) in sortedLogs.enumerated() {
                if log.date.distance(to: curr.addingTimeInterval(TimeInterval(-604800 * i))) < 604800 && log.date < curr.addingTimeInterval(TimeInterval(-604800 * i)) {
                    weekLog.distance += log.distance
                    weekLog.duration += log.duration
                    weekLog.elevation += log.elevation
                    if indx == 0 {
                        
                    }
                }
            }

            mergedLogs.insert(weekLog, at: 0)
        }

        self.logs = mergedLogs
        self.mileMax = Int(mergedLogs.max(by: { $0.distance < $1.distance })?.distance ?? 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("日期：\(dateFormatter.string(from: logs[selectedIndex].date.addingTimeInterval(-604800))) - \(dateFormatter.string(from: logs[selectedIndex].date))".uppercased())
                .font(Font.body.weight(.heavy))
                .printLog("打印日志修饰符")
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("距离")
                        .font(.caption)
                        .foregroundColor(Color.black.opacity(0.5))
                    Text(String(format: "%.2f mi", logs[selectedIndex].distance))
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                }
                
                Color.gray
                    .opacity(0.5)
                    .frame(width: 1, height: 30, alignment: .center)
                    
                VStack(alignment: .leading, spacing: 4) {
                    Text("时间")
                        .font(.caption)
                        .foregroundColor(Color.black.opacity(0.5))
                    Text(String(format: "%.0fh", logs[selectedIndex].duration / 3600) + String(format: " %.0fm", logs[selectedIndex].duration.truncatingRemainder(dividingBy: 3600) / 60))
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                }
                
                Color.gray
                    .opacity(0.5)
                    .frame(width: 1, height: 30, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("海拔")
                        .font(.caption)
                        .foregroundColor(Color.black.opacity(0.5))
                    Text(String(format: "%.0f ft", logs[selectedIndex].elevation))
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("最近 12 周")
                    .font(Font.caption.weight(.heavy))
                    .foregroundColor(Color.black.opacity(0.7))
                Text("\(mileMax) mi")
                    .font(Font.caption)
                    .foregroundColor(Color.black.opacity(0.5))
            }.padding(.top, 10)
            
            
        }
    }
}

struct ActivityHistoryText_Previews: PreviewProvider {
    static var previews: some View {
        ActivityHistoryText(logs: [], selectedIndex: .constant(0))
    }
}
