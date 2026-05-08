//
//  AsyncStream1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 5/8/26.
//

import SwiftUI
import Observation
import Combine

// MARK: - ViewModel
@Observable
final class AsyncStream1ViewModel {
	
	// MARK: - Properties
	/// 데이터를 저장하는 배열 (UI 업데이트 용)
	var combineData: [Int] = [] // Combine 결과 저장
	var asyncStreamData: [Int] = []
	/// Combine에서 계약서 저장소와 같은 (금고의 계약서) Cancellable 객체 (메모리 관리. publisher의 흐름이 끊기면 해지 -> 메모리 누수 없음)
	var cancellables = Set<AnyCancellable>()
	
	// MARK: - Combine 사용
	/// Combine 을 활용한 데이터 스트림 처리
	func startCombine() {
		// Publisher 생성 , 타입 및 값 변환
		let publisher = Timer.publish(every: 1, on: .main, in: .common) // 1초마다 실행되는 Timer
			.autoconnect() // 자동 구독 시작
			.map { _ in Int.random(in: 1...100) } // 1~100 사이의 랜덤 값을 생성
			.prefix(5) // 최대 5개 값만 방출
		
		// 실행
		publisher
			.sink { [weak self] value in // 구독 시작
				guard let self else {return}
				self.combineData.append(value) // 새로운 값이 들어올 때마다 CombineData에 추가
			}
			.store(in: &cancellables) // cancellables에 저장하여 메모리 관리
	}
	
	// MARK: - AsyncStream 사용
	/// AsyncStream을 활용하여 비동기 데이터 스트림 사용
	func startAsyncStream() {
		Task {
			for await value in fetchAsyncStreamData() {
				await MainActor.run {
					self.asyncStreamData.append(value)
				}
			}
		}
	}
	
	private func fetchAsyncStreamData() -> AsyncStream<Int> {
		return AsyncStream { continuation in
			Task {
				for _ in 1...5 {
					try? await Task.sleep(for: .seconds(1)) // 1초 간격으로 데이터 생성
					continuation.yield(Int.random(in: 1...100)) // 1~100 사이의 랜덤값 전달
				}
				continuation.finish() // 스트림 종료
			}
		}
	}
	
}


struct AsyncStream1: View {
	
	@State private var vm: AsyncStream1ViewModel = .init()
	
    var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				VStack(spacing: 10) {
					// MARK: - Combine 데이터
					Text("Combine")
						.font(.headline)
					
					Text(vm.combineData.map { "\($0)" }.joined(separator: ", "))
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.orange.opacity(0.2))
						.clipShape(RoundedRectangle(cornerRadius: 8))
					
					Button(action: {
						vm.startCombine()
					}, label: {
						Text("Start Combine")
							.frame(maxWidth: .infinity)
							.font(.headline)
							.padding(.vertical, 7)
					})
					.buttonStyle(.borderedProminent)
					.tint(.orange)
					
					Divider()
					// MARK: - AsyncStream 데이터
					VStack(spacing: 10) {
						Text("AsyncStream")
							.font(.headline)
						
						Text(vm.asyncStreamData.map { "\($0)"}.joined(separator: ". ") )
							.frame(maxWidth: .infinity)
							.padding()
							.background(Color.accent.opacity(0.2))
							.clipShape(RoundedRectangle(cornerRadius: 8))
						
						Button(action: {
							vm.startAsyncStream()
						}, label: {
							Text("Start AsyncStream")
								.font(.headline)
								.frame(maxWidth: .infinity)
								.padding(.vertical, 7)
						})
						.buttonStyle(.borderedProminent)
						
					} //:VSTACK
				} //:VSTACK
			} //:VSTACK
			.navigationTitle("Combine VS AsyncStream")
			.navigationBarTitleDisplayMode(.inline)
			.padding()
		} //:NAVSTACK
    }
}

#Preview {
    AsyncStream1()
}
