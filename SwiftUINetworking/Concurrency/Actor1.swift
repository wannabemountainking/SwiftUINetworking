//
//  Actor1.swift
//  SwiftUINetworking
//
//  Created by yoonie on 4/28/26.
//

import SwiftUI
import Observation


// MARK: - 기존 GCD(Grand Central Dispatch) 기반의 Thread-Safe 데이터 관리
class GCDCounter {
    
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
actor ActorCounter {
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

// MARK: - ViewModel
@Observable
final class Actor1ViewModel {
	
	/// UI에 사용할 카운트 값
	var gcdCount: Int = 0
	var actorCount: Int = 0
	var staticInfo: String = ""
	
	/// GCDCounter 인스턴스
	private let gcdCounter = GCDCounter()
	/// Actor Counter 인스턴스
	private let actorCounter = ActorCounter()
	
	/// GCD 기반 카운트 증가
	func increaseGCDCounter() {
		gcdCounter.increment()
		gcdCounter.getCount { count in // Completion Handler를 사용해서 비동기 적으로 실행 -> 여긴 백그라운드
			DispatchQueue.main.async { // UI 업데이트는 메인 쓰레드에서 실행
				self.gcdCount = count // -> 여긴 메인
			}
		}
	}
	
	/// Actor 방식의 카운트 증가
	func increaseActorCounter() async {
		await actorCounter.increment() // Actor 내부 메서드 호출 시 await 필요(줄을 서야하니까 대기)
		let newValue = await actorCounter.getCount() // 최신 카운트 값 가져오기
		await MainActor.run { // UI 업데이트는 반드시 Main Thread 에서 실행
			self.actorCount = newValue
		}
	}
	
	/// nonisolated 프로퍼티 값 가져오기
	func fetchStaticInfo() {
		self.staticInfo = actorCounter.staticInfo // 여긴 await 필요 없음. 변경될 리가 없으니 nonisolated를 보고 그냥 가져옴.
	}
}


struct Actor1: View {
	
	@State private var vm: Actor1ViewModel = .init()
	
    var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				
				// MARK: - GCD 방식으로 카운트 증가
				Text("GCD Counter: \(vm.gcdCount)")
					.font(.title3)
					.padding()
				Button(action: {
					vm.increaseGCDCounter()
				}, label: {
					Text("GCD 방식 카운트 증가")
						.frame(maxWidth: .infinity)
				})
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				.tint(.blue)
				
				Divider()
				
				// MARK: - Actor 방식으로 카운트 증가
				Text("Actor Counter: \(vm.actorCount)")
					.font(.title3)
					.padding()
				Button(action: {
					Task{
						await vm.increaseActorCounter()
					}
				}, label: {
					Text("Actor 방식 카운트 증가")
						.frame(maxWidth: .infinity)
				})
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				
				Divider()
				
				// MARK: - nonisolated 사용 예제
				Text("Static Info: \(vm.staticInfo)")
					.font(.title3)
					.padding()
				Button(action: {
					vm.fetchStaticInfo()
				}, label: {
					Text("nonisolated 데이터 가져오기")
						.frame(maxWidth: .infinity)
				})
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				.tint(.orange)
			} //:VSTACK
		} //:NAVIGATION
		.navigationTitle("Actor VS GCD")
    }//:body
}

#Preview {
	NavigationStack {
		Actor1()
	}
}
