//
//  TaskGroup1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 5/6/26.
//
// API: https://jsonplaceholder.typicode.com/posts/1

import SwiftUI
import Observation



// MARK: - ViewModel

/// async let 과 TaskGroup을 사용하여 병렬 작업을 실행하고, 결과를 비교하는 뷰모델
@Observable
final class TaskGroup1ViewModel {
	/// async let을 사용한 작업 결과를 저장하는 배열
	var asyncLetResults: [String] = []
	/// TaskGroup을 사용한 작업 결과를 저장하는 배열
	var taskGroupResults: [String] = []
	/// Async let 작업 로딩 상태를 나타내는 변수
	var isAsyncLetLoading: Bool = false
	/// TaskGroup 작업 로딩 상태를 나타내는 변수
	var isTaskGroupLoading: Bool = false
	var timeInAsyncLet: String = ""
	var timeInTaskGroup: String = ""
	
	// MARK: - Async let 방식 (병렬 실행)
	
	/// async let을 사용하여 고정된 URL 데이터를 병렬로 가져오는 메서드
	func fetchWithAsyncLet() async {
		let startTime = Date()
		self.isAsyncLetLoading = true // 작업 시작 상태 설정
		self.asyncLetResults = [] // 기존 결과 초기화
		
		// 네트워크 요청을 실행할 URL 목록
		let urls = [
			"https://jsonplaceholder.typicode.com/posts/1",
			"https://jsonplaceholder.typicode.com/posts/2",
			"https://jsonplaceholder.typicode.com/posts/3",
			"https://jsonplaceholder.typicode.com/posts/4",
			"https://jsonplaceholder.typicode.com/posts/5"
		]
		
		// async let을 사용해서 개별 작업을 병렬 실행 (즉시 실행됨)
		async let result1 = fetchData(urlString: urls[0])
		async let result2 = fetchData(urlString: urls[1])
		async let result3 = fetchData(urlString: urls[2])
		async let result4 = fetchData(urlString: urls[3])
		async let result5 = fetchData(urlString: urls[4])
		
		// 모든 작업이 완료될때 까지 대기 await
//		if let r1 = await result1 { self.asyncLetResults.append(r1) }
//		if let r2 = await result2 { self.asyncLetResults.append(r2) }
//		if let r3 = await result3 { self.asyncLetResults.append(r3) }
//		if let r4 = await result4 { self.asyncLetResults.append(r4) }
//		if let r5 = await result5 { self.asyncLetResults.append(r5) }
		
		let results = await [result1, result2, result3, result4, result5]
		self.asyncLetResults = results.compactMap { $0 }
		
		self.isAsyncLetLoading = false
		let elapsedTime = Date().timeIntervalSince(startTime)
		self.timeInAsyncLet = String(format: "%.2f", elapsedTime)
		
	}
	
	// MARK: - TaskGroup 방식 (대량 작업 병렬 실행)
	/// TaskGroup 을 사용하여 여러 URL 데이터를 병렬로 가져오는 메서드
	func fetchWithTaskGroup() async {
		
		let startTime = Date()
		self.isTaskGroupLoading = true // 작업 시작 상태 섫정
		self.taskGroupResults = [] // 기존 결과 초기화
		
		// 네트워크 요청을 실행할 URL 목록
		let urls = [
			"https://jsonplaceholder.typicode.com/posts/1",
			"https://jsonplaceholder.typicode.com/posts/2",
			"https://jsonplaceholder.typicode.com/posts/3",
			"https://jsonplaceholder.typicode.com/posts/4",
			"https://jsonplaceholder.typicode.com/posts/5"
		]
		
		// withTaskGroup 을 사용하여 여러 작업을 group으로 실행
		await withTaskGroup(of: String?.self) { taskGroup in
			// URL 배열을 반복문을 돌면서 개별 작업 그룹에 추가
			for url in urls {
				taskGroup.addTask {
					// fetch Data 메서드를 호출하여 URL 데이터 가져오기
					await self.fetchData(urlString: url)
				}
			}
			// TaskGroup 내 모든 작업이 완료될 때까지 기다리며 결과를 처리
			for await result in taskGroup {
				guard let result else {return}
				self.taskGroupResults.append(result) // 결과를 배열에 추가
			}
		}
		self.isTaskGroupLoading = false // 작업 종료 상태 설정
		let elapsedTime = Date().timeIntervalSince(startTime)
		self.timeInTaskGroup = String(format: "%.2f", elapsedTime)
	}
	
	/// 비동기적으로 데이터 가져오는 메서드
	private func fetchData(urlString: String) async -> String? {
		guard let url = URL(string: urlString) else { return nil }
		
		do {
			try await Task.sleep(for: .seconds(1))
			// 네트워크 요청 실행 (비동기 데이터 가져오기)
			let (data, _) = try await URLSession.shared.data(from: url)
			return String(data: data, encoding: .utf8) // 데이터를 문자열로 변환하여 반환
		} catch {
			print("Error: \(error.localizedDescription)")
			return nil
		}
	}
}


// MARK: - View
struct TaskGroup1: View {
	@State private var vm: TaskGroup1ViewModel = .init()
	
    var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				// MARK: - Async let 결과 섹션
				Section {
					//content
					if vm.isAsyncLetLoading {
						ProgressView("Loading Async Let...") // 로딩 중일때 ProgressView
					} else {
						List(vm.asyncLetResults, id: \.self) { result in
							Text(result) // 결과를 리스트로 표시
						}
					}
				} header: {
					Text("Async Let Results - 소요 시간: \(vm.timeInAsyncLet)초")
						.font(.headline)
				}
				
				// MARK: - TaskGroup 결과 섹션
				Section {
					// content
					if vm.isTaskGroupLoading {
						ProgressView("Loading TaskGroup...") // 로딩 중일 때 ProgressView
					} else {
						List(vm.taskGroupResults, id: \.self) { result in
							Text(result)
						}
					}
				} header: {
					Text("TaskGroup Results - 소요시간: \(vm.timeInTaskGroup)초")
						.font(.headline)
				}

				
				Divider()
				
				// MARK: - 실행 버튼
				HStack(spacing: 10) {
					/// Async Let 실행 버튼
					Button(action: {
						Task {
							await vm.fetchWithAsyncLet()
						}
					}, label: {
						Text("Run Async Let")
							.frame(maxWidth: .infinity)
					})
					.buttonStyle(.borderedProminent)
					.padding(.horizontal)
					
					/// TaskGroup 실행 버튼
					Button(action: {
						Task {
							await vm.fetchWithTaskGroup()
						}
					}, label: {
						Text("Run TaskGroup")
							.frame(maxWidth: .infinity)
					})
					.buttonStyle(.borderedProminent)
					.padding(.horizontal)
					.tint(.blue)
				} //:HSTACK
			} //:VSTACK
			.navigationTitle("TaskGroup VS Async Let")
			.padding()
		} //:NAVSTACK
    }
}

#Preview {
    TaskGroup1()
}
