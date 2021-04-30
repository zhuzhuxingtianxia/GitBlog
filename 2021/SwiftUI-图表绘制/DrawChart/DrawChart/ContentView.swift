//
//  ContentView.swift
//  DrawChart
//
//  Created by ZZJ on 2021/4/30.
//

import SwiftUI
extension View {
    func printLog(_ value:Any) -> some View {
        #if DEBUG
        print(value)
        #endif
        return self
    }
}

struct ContentView: View {
    var body: some View {
        ActivityHistoryView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
