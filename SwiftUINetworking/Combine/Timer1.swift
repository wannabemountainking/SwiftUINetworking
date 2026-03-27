//
//  Timer1.swift
//  SwiftUINetworking
//
//  Created by yoonie on 3/27/26.
//

import SwiftUI
import Combine

struct Timer1: View {
    
    // MARK: - Property
    // Timer 에서 Combine을 Import 하지 않고 Publisher 사용
    /*
     every: 시간 Interval로 1.0은 1초를 가리킴
     on: Thread 설정 (UI업데이트이니까 .main)
     in: loop를 어떤 식으로 하는 지에 대한 설정
     .autoconnect() : Publisher Timer가 UI가 업데이트 될 때마다 시작할 수 있게 함 (매번 초기화해서 업데이트)
     */
    let Timer1 = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // 1. 현재 시간 변수
    @State private var currentDate: Date = Date()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    
    // MARK: - UI
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    // MARK: - Function
    
}

#Preview {
    Timer1()
}
