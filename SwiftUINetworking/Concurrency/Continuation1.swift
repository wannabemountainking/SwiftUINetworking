//
//  Continuation1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 5/6/26.
//

import SwiftUI
import Observation

// MARK: - ViewModel
@Observable
final class Continuation1ViewModel {
	/// 다운로드 된 텍스트 데이터를 저장
	var downloadedText: String = "Loading..."
	
	// MARK: - 기존 콜백 기반 API
	/// 기존 콜백 기반 API (네트워크 요청 시뮬레이션)
	func fetchDataWithCallBack(completion: @escaping (String) -> Void) {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) { // 2초 후 실행
			completion("콜백 기반으로 가져온 텍스트 데이터")
		}
	}
	
	// MARK: - Continuation을 활용한 변환
	/// 기존 콜백 기반 API를 Swift async/await 가 사용가능하게 만드는 메서드
	func fetchTextData() async {
		let result: String = await withCheckedContinuation { continuation in
			// 기존 콜백 기반 메서드를 호출하되, 결과를 Continuation에 연결
			fetchDataWithCallBack { text in
				continuation.resume(returning: text) // 데이터를 반환하여 비동기 함수 해결
			}
		}
		// UI 업데이트는 MainActor에서 실행
		await MainActor.run {
			self.downloadedText = result
		}
	}
	
	// 임의의 에러 타입 정의
	enum FetchError: Error {
		case networkFailure
	}
	
	// MARK: - 에러를 던질 수 있는 Continuation
	/// 기존 콜백 API 에서 에러를 처리할 수 있도록 변환한 메서드
	func fetchDataWithError() async {
		do {
			let result: String = try await withCheckedThrowingContinuation { continuation in
				DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) { // 2초 후 실횅
					// 50% 확률로 에러 발생
					if Bool.random() {
						continuation.resume(throwing: FetchError.networkFailure)
					} else {
						continuation.resume(returning: "데이터 로드 성공")
					}
				}
//				self.fetchDataWithCallBack { text in
//					if Bool.random() {
//						continuation.resume(throwing: FetchError.networkFailure)
//					} else {
//						continuation.resume(returning: text)
//					}
//				}
			}
			await MainActor.run {
				self.downloadedText = result
			}
		} catch {
			await MainActor.run {
				self.downloadedText = "에러 발생: \(error.localizedDescription)"
			}
		}
	}
}


// MARK: - View
struct Continuation1: View {
	@State private var vm: Continuation1ViewModel = .init()
	
    var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				Text(vm.downloadedText) // 다운로드 돤 택스트 표시
					.font(.title)
					.foregroundStyle(.blue)
					.padding()
				
				// 텍스트 데이터 가져오기 버튼
				Button(action: {
					Task {
						await vm.fetchTextData()
					}
				}, label: {
					Text("Fetch Text Data")
						.frame(maxWidth: .infinity)
				})
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				.tint(.blue)
				
				// 에러 발생 Continuation
				Button(action: {
					Task {
						await vm.fetchDataWithError()
					}
				}, label: {
					Text("Error")
						.frame(maxWidth: .infinity)
				})
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				
			} //:VSTACK
			.navigationTitle("Continuation 연습")
		} //:NAVSTACK
    }
}

#Preview {
    Continuation1()
}
