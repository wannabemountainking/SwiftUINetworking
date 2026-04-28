//
//  Async1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 4/28/26.
//

import SwiftUI
import Observation

// MARK: - ViewModel
/// 비동기 작업과 데이터를 관리하는 클래스
@Observable
class Async1ViewModel {
	/// UI에 표시할 데이터를 저장하는 배열
	var dataArray: [String] = []
	
	// MARK: - Swift Concurrency 도입 이전에 비동기 스레드 간의 처리방식 -> DispatchQueue.main.async
	/// 메인 스레드에서 2초 딜레이 후에 데이터를 추가하는 메서드
	func addTitle1() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2초 후에 실행
			self.dataArray.append("Title 1: 메인 쓰레드에 2초 딜레이. 현재 쓰레드:  \(Thread.current)")  // 현재 쓰레드 정보 추가
		}
	}
	/// 백그라운드에서 작업을 수행한 뒤, UI 업데이트를 위한 메인쓰레드 복귀
	func addTitle2() {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) { // 백그라운드 쓰레드에서 2초 후 실행
			let title2 = "Title2: 백그라운드 쓰레드에 2초 딜레이. 현재 쓰레드: \(Thread.current)" // 현재 쓰레드 정보 추가
			DispatchQueue.main.async { // 메인쓰레드로 복귀하여 UI 업데이트
				self.dataArray.append(title2) // UI엡데이트
				
				let title3 = "Title3: UI 업데이트 메인쓰레드에서 함. 현재 쓰레드: \(Thread.current)"// 메인 쓰레드 정보 추가
				self.dataArray.append(title3)
			}
		}
	}
	
	// MARK: - Swift Concurrency
	
	/// async/await 를 사용하여 데이터를 추가하는 메서드
	/// - Swift Concurrency를 활용해 메인 쓰레드와 비동기 작업 간의 전환을 단순화.
	
	func addTitle4() async {
		
		await MainActor.run {
			//MainActor를 사용해 메인 쓰레드에서 실행
			let title4  = "Title4 - Async 비동기 쓰레드(기본값: 백그라운드) : \(Thread.isMainThread ? "Main" : "Background")"
			// 기본적으로 비동기 작업은 백그라운드 쓰레드에서 실행됨
			self.dataArray.append(title4)
			
			let title5 = "Title5 - Async 메인쓰레드에서 동작 보장: \(Thread.isMainThread ? "Main" : "Background")"
			self.dataArray.append(title5)
		}
		
		/// Task.sleep 을 사용해서 3초 대기
		try? await Task.sleep(for: .seconds(3))
		
		// Task.sleep 이후 메인 쓰레드에서 작업 추가
		await MainActor.run {
			let title6 = "Title 6 - Task.sleep 으로 3초 딜레이 추가: \(Thread.current)"
			self.dataArray.append(title6)
		}
		
	}
}


// MARK: - View
struct Async1: View {
	
	@State private var vm: Async1ViewModel = .init()
	
    var body: some View {
		NavigationStack {
			List {
				ForEach(vm.dataArray, id: \.self) { data in
					Text(data) // 배열의 각 데이터를 텍스트로 표시
				}
			}
			.onAppear {
				// 메인쓰레드와 백그라운드 쓰레드에서 실행되는 작업 호출
				vm.addTitle1()
				vm.addTitle2()
				
				// Task로 async 함수 호출
				Task {
					await vm.addTitle4()
				}
			}
		}
		.navigationTitle("Async 연습")
    }
}

#Preview {
	NavigationStack {
		Async1()
	}
}
