//
//  ActivityGraph.swift
//  DrawChart
//
//  Created by ZZJ on 2021/4/30.
//

import SwiftUI

struct ActivityGraph: View {
    var logs: [ActivityLog]
    @Binding var selectedIndex: Int
        
    @State var lineOffset: CGFloat = 8 // 垂直线的偏移量
    @State var selectedXPos: CGFloat = 8 // 手势位置X点
    @State var selectedYPos: CGFloat = 0 // 手势位置Y点
    @State var isSelected: Bool = false // 用户是否触摸图形
    
    init(logs: [ActivityLog], selectedIndex: Binding<Int>) {
        self._selectedIndex = selectedIndex
        
        let curr = Date() // 今天的日期
        // 按时间顺序对日志进行排序
        let sortedLogs = logs.sorted { (log1, log2) -> Bool in
            log1.date > log2.date
        }
        
        var mergedLogs: [ActivityLog] = []
        
         // 回顾过去12周的情况
        for i in 0..<12 {

            var weekLog: ActivityLog = ActivityLog(distance: 0, duration: 0, elevation: 0, date: Date())

            for log in sortedLogs {
                // 如果日志在特定的星期内，那么添加到每周总数
                if log.date.distance(to: curr.addingTimeInterval(TimeInterval(-604800 * i))) < 604800 && log.date < curr.addingTimeInterval(TimeInterval(-604800 * i)) {
                    weekLog.distance += log.distance
                    weekLog.duration += log.duration
                    weekLog.elevation += log.elevation
                }
            }

            mergedLogs.insert(weekLog, at: 0)
        }

        self.logs = mergedLogs
    }
        
    var body: some View {
        drawGrid()
            .opacity(0.2)
            .overlay(drawActivityGradient(logs: logs))
            .overlay(drawActivityLine(logs: logs))
            .overlay(drawLogPoints(logs: logs))
            .overlay(addUserInteraction(logs: logs))
    }
}


extension ActivityGraph {
    //绘制网格
    func drawGrid() -> some View {
        VStack(spacing: 0) {
            Color.black.frame(height: 1, alignment: .center)
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: 8, height: 100)
                ForEach(0..<11) { i in
                    Color.black.frame(width: 1, height: 100, alignment: .center)
                    Spacer()

                }
                Color.black.frame(width: 1, height: 100, alignment: .center)
                Color.clear
                    .frame(width: 8, height: 100)
            }
            Color.black.frame(height: 1, alignment: .center)
        }
    }
}

extension ActivityGraph {
    func drawActivityGradient(logs: [ActivityLog]) -> some View {
        LinearGradient(gradient: Gradient(colors: [Color(red: 251/255, green: 82/255, blue: 0), .white]), startPoint: .top, endPoint: .bottom)
            .padding(.horizontal, 8)
            .padding(.bottom, 1)
            .opacity(0.8)
            .mask(
                GeometryReader { geo in
                    Path { p in
                        // 用于视图缩放的数据
                        let maxNum = logs.reduce(0) { (res, log) -> Double in
                            return max(res, log.distance)
                        }

                        let scale = geo.size.height / CGFloat(maxNum)

                        //每个周的绘制索引 (0-11)
                        var index: CGFloat = 0

                        // 添加绘制的起始的x,y点坐标
                        p.move(to: CGPoint(x: 8, y: geo.size.height - (CGFloat(logs[Int(index)].distance) * scale)))

                        // 绘制添加线
                        for _ in logs {
                            if index != 0 {
                                p.addLine(to: CGPoint(x: 8 + ((geo.size.width - 16) / 11) * index, y: geo.size.height - (CGFloat(logs[Int(index)].distance) * scale)))
                            }
                            index += 1
                        }

                        // 形成闭环路径
                        p.addLine(to: CGPoint(x: 8 + ((geo.size.width - 16) / 11) * (index - 1), y: geo.size.height))
                        p.addLine(to: CGPoint(x: 8, y: geo.size.height))
                        p.closeSubpath()
                    }
                }
            )
    }
}

extension ActivityGraph {
    func drawActivityLine(logs: [ActivityLog]) -> some View {
        GeometryReader { geo in
            Path { p in
                let maxNum = logs.reduce(0) { (res, log) -> Double in
                    return max(res, log.distance)
                }

                let scale = geo.size.height / CGFloat(maxNum)
                var index: CGFloat = 0

                p.move(to: CGPoint(x: 8, y: geo.size.height - (CGFloat(logs[0].distance) * scale)))

                for _ in logs {
                    if index != 0 {
                        p.addLine(to: CGPoint(x: 8 + ((geo.size.width - 16) / 11) * index, y: geo.size.height - (CGFloat(logs[Int(index)].distance) * scale)))
                    }
                    index += 1
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 80, dash: [], dashPhase: 0))
            .foregroundColor(Color(red: 251/255, green: 82/255, blue: 0))
        }
    }
}

extension ActivityGraph {
    
    func drawLogPoints(logs: [ActivityLog]) -> some View {
        GeometryReader { geo in

            let maxNum = logs.reduce(0) { (res, log) -> Double in
                return max(res, log.distance)
            }

            let scale = geo.size.height / CGFloat(maxNum)

            ForEach(logs.indices) { i in
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, miterLimit: 80, dash: [], dashPhase: 0))
                    .frame(width: 10, height: 10, alignment: .center)
                    .foregroundColor(Color(red: 251/255, green: 82/255, blue: 0))
                    .background(Color.white)
                    .cornerRadius(5)
                    .offset(x: 8 + ((geo.size.width - 16) / 11) * CGFloat(i) - 5, y: (geo.size.height - (CGFloat(logs[i].distance) * scale)) - 5)
            }
        }
    }
    
}

extension ActivityGraph {
    func addUserInteraction(logs: [ActivityLog]) -> some View {
        GeometryReader { geo in

            let maxNum = logs.reduce(0) { (res, log) -> Double in
                return max(res, log.distance)
            }

            let scale = geo.size.height / CGFloat(maxNum)

            ZStack(alignment: .leading) {
                // 线和点叠加
                Color(red: 251/255, green: 82/255, blue: 0)
                    .frame(width: 2)
                    .overlay(
                        Circle()
                            .frame(width: 24, height: 24, alignment: .center)
                            .foregroundColor(Color(red: 251/255, green: 82/255, blue: 0))
                            .opacity(0.2)
                            .overlay(
                                Circle()
                                    .fill()
                                    .frame(width: 12, height: 12, alignment: .center)
                                    .foregroundColor(Color(red: 251/255, green: 82/255, blue: 0))
                            )
                            .offset(x: 0, y: isSelected ? 12 - (selectedYPos * scale) : 12 - (CGFloat(logs[selectedIndex].distance) * scale))
                        , alignment: .bottom)

                    .offset(x: isSelected ? lineOffset : 8 + ((geo.size.width - 16) / 11) * CGFloat(selectedIndex), y: 0)
                    .animation(Animation.spring().speed(4))

                // 添加拖动手势代码
                Color.white.opacity(0.1)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { touch in
                                let xPos = touch.location.x
                                self.isSelected = true
                                let index = (xPos - 8) / (((geo.size.width - 16) / 11))

                                if index > 0 && index < 11 {
                                    let m = (logs[Int(index) + 1].distance - logs[Int(index)].distance)
                                    self.selectedYPos = CGFloat(m) * index.truncatingRemainder(dividingBy: 1) + CGFloat(logs[Int(index)].distance)
                                }


                                if index.truncatingRemainder(dividingBy: 1) >= 0.5 && index < 11 {
                                    self.selectedIndex = Int(index) + 1
                                } else {
                                    self.selectedIndex = Int(index)
                                }
                                self.selectedXPos = min(max(8, xPos), geo.size.width - 8)
                                self.lineOffset = min(max(8, xPos), geo.size.width - 8)
                            }
                            .onEnded { touch in
                                let xPos = touch.location.x
                                self.isSelected = false
                                let index = (xPos - 8) / (((geo.size.width - 16) / 11))

                                if index.truncatingRemainder(dividingBy: 1) >= 0.5 && index < 11 {
                                    self.selectedIndex = Int(index) + 1
                                } else {
                                    self.selectedIndex = Int(index)
                                }
                            }
                    )
            }
        }
    }

    
}

struct ActivityGraph_Previews: PreviewProvider {
    static var previews: some View {
        ActivityGraph(logs:ActivityTestData.testData, selectedIndex: .constant(0))
    }
}
