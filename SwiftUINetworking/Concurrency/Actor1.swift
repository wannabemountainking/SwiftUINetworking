//
//  Actor1.swift
//  SwiftUINetworking
//
//  Created by yoonie on 4/28/26.
//

import SwiftUI
import Observation


// MARK: - 기존 GCD(Grand Central Dispatch) 기반의 Thread-Safe 데이터 관리
class GCDCount {
    
    /// 비동기 접근 시 data racing 방지를 위한 DispatchQueue(직렬큐 설정)
    private var queue = DispatchQueue(
        label: "GCD Counter Example",
        attributes: .concurrent
    )
    
    /// 카운트 변수
    private var count = 0
    
    /// GCD 기반으로 Thread-Safe 한 방식으로 카운트 증가
    func increment() {
        queue.async(flags: .barrier) {
            self.count += 1
        }
    }
    
    /// GCD 기반으로 Thread-Safe한 방식으로 카운트 값을 반환 -> Completion Handler
    func getCount(completion: @escaping (Int) -> Void) {
        queue.async {
            completion(self.count)
        }
    }
}

// MARK: - Actor 기반의 Thread-Safe 데이터 관리
actor ActorCount {
    /// Actor 내부 카운트 값
    private var count = 0
    /// 카운트 증가 시키는 메서드
    func increment() async {
        count += 1
    }
    
    func getCount() async -> Int {
        return count
    }
    
    nonisolated var staticInfo: String {
        return "Actor 내의 thread-safe 필요 없는 정적인 데이터 시 nonisolated 사용"
    }
}


struct Actor1: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    Actor1()
}
