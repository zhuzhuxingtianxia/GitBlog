//
//  ActivityHistoryView.swift
//  DrawChart
//
//  Created by ZZJ on 2021/4/30.
//

import SwiftUI

struct ActivityHistoryView: View {
    @State var selectedIndex: Int = 0
        
        var body: some View {
            VStack(spacing: 16) {
                // 统计数据文本视图
                ActivityHistoryText(logs: ActivityTestData.testData, selectedIndex: $selectedIndex)
                
                // 图表
                ActivityGraph(logs: ActivityTestData.testData, selectedIndex: $selectedIndex)
                
            }.padding()
        }
}

struct ActivityHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityHistoryView()
    }
}
