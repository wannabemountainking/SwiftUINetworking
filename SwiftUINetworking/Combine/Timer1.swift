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
    let timer1 = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // 1. 현재 시간 변수
    @State private var currentDate: Date = Date()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    
    // 2. 카운트다운 타이머
    @State private var count: Int = 10
    @State private var finishedText: String? = nil
    
    // MARK: - UI
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 1. 현재시간 타이머
                Text("1. 현재 시간 Timer")
                Text(dateFormatter.string(from: currentDate))
                    .foregroundStyle(.accent)
                
                // 2. 카운트 다운: 10, 9, ....0
                Text("2. 카운트 다운 Timer")
                Text(finishedText ?? "\(count)")
                    .foregroundStyle(.accent)
            } //:VSTACK
            .font(.largeTitle.bold())
            .navigationTitle("Timer")
            
            // .onReceive: Subscriber 역할이며 Publisher(여기서는 timer1)의 value 를 가져와서 UI에 실행 시켜줌
            // 1. 현재시간 .onReceive
            .onReceive(timer1) { output in
                self.currentDate = output
            }
            
            // 2. 카운트 다운 .onReceive
            .onReceive(timer1) { _ in
                if self.count <= 1 {
                    finishedText = "시작!"
                } else {
                    self.count -= 1
                }
            }
        } //:NAVIGATION
    }//:body
    
    // MARK: - Function
    
}

#Preview {
    Timer1()
}
