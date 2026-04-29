//
//  MainActor1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 4/29/26.
//

import SwiftUI
import Observation

// MARK: - ViewModel (@MainActor 적용)

/// @MainActor는 Swift의 Main Thread에서 실행되도록 보장하는 속성
@MainActor
@Observable
class MainActor1ViewModel {
	
	/// 화면에 표시할 메시지
	var message: String = "Loading..."
	
	/// @MainActor가 적용된 상태이므로, 비동기 작업을 실행해도 자동으로 MainThread에서 실행됨 (백그라운드로 작업을 보내기도 하지만 어쨌든 자동으로 돌아옴)
	func updateMessage() async {
		try? await Task.sleep(for: .seconds(1)) // 1초 대기
		message = "@MainActor: UI 업데이트 완료"
	}
}

// MARK: - ViewModel (await MainActor.run 사용)
@Observable
class MainActorRunViewModel {
	/// 화면에 표시할 메시지
	var message: String = "Loading..."
	
	/// 백그라운드 작업 후, 자동으로 메인쓰레드로 올 수 없어서 MainActor.run으로 메인스레드에서 UI 업데이트를 강제함
	func updateMessage() async {
		try? await Task.sleep(for: .seconds(1)) // 1초 대기
		await MainActor.run {
			self.message = "MainActor.run: 백그라운드 작업 데이터"
		}
	}
}

struct MainActor1: View {
	
	@State private var mainActorVM: MainActorRunViewModel = .init()
	@State private var mainActorRunVM: MainActorRunViewModel = .init()
	
    var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				
				// MARK: - @MainActor 적용 예시
				Text(mainActorVM.message)
					.font(.title3)
					.padding()
				Button(action: {
					Task {
						await mainActorVM.updateMessage()
					}
				}, label: {
					Text("@MainActor 실행")
						.frame(maxWidth: .infinity)
				})
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				.tint(.blue)
				
				// MARK: - MainActor.run 사용 예제
				Text(mainActorRunVM.message)
					.font(.title3)
					.padding()
				Button(action: {
					Task {
						await mainActorRunVM.updateMessage()
					}
				}, label: {
					Text("MainActor.run 실행")
						.frame(maxWidth: .infinity)
				})
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				
			} //:VSTACK
			.navigationTitle("@MainActor VS MainActor.run")
			.navigationBarTitleDisplayMode(.inline)
		} //:NAVIGATION
    }
}

#Preview {
    MainActor1()
}
