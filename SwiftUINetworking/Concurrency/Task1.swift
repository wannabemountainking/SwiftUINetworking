//
//  Task1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 4/28/26.
//

import SwiftUI
import Observation


// MARK: - ViewModel
@Observable
final class Task1ViewModel {
	/// High Priority Task 결과 저장
	var highPriorityData: String = ""
	/// Low Priority Task 결과 저장
	var lowPriorityData: String = ""
	/// .task Modifier 작업 결과 저장
	var dotTaskData: String = ""
	
	// MARK: - High Priority Task (우선순위 높은 작업)
	/// 높은 우선순위에서 실행되는 Task
	func fetchHighPriorityData() async {
		await Task(priority: .high) {
			do {
				// 1초 간격으로 3번 작업 진행 (비동기 대기)
				for i in 1...3 {
					try await Task.sleep(for: .seconds(1))
					print("High Priority Task 진행 중 ... (\(i))")
				}
				// 작업 완료 후에 UI 업데이트 (메인 쓰레드에서 실행)
				await MainActor.run {
					self.highPriorityData = "High Priority Task 완료"
					print("High Priority Task 완료")
				}
			} catch {
				print("High Priority Task 에러 발생: \(error.localizedDescription)")
			}
		}
		.value
		/*
		 .value:
			- Task의 결과를 반환할 때 사용
			- Task는 비동기 작업으로 동작하므로, 작업 완료 후 결과를 기다리기 위해서 .value 호출
			- .value 는 작업 완료를 보장하고, 작업의 반환값 제공
		 */
	}
	
	// MARK: - Low Priority Task (우선순위 낮은 작업)
	/// 낮은 우선순위에서 실행되는 Task
	func fetchLowPriorityData() async {
		await Task(priority: .low) {
			do {
				// 1초 간격으로 5번 작업 진행 (비동기 대기)
				for i in 1...5 {
					try await Task.sleep(for: .seconds(1))
					print("Low Priority Task 진행 중 ... (\(i))")
				}
				// 작업 완료 후에 UI 업데이트 (메인 쓰레드에서 실행)
				await MainActor.run {
					self.lowPriorityData = "Low Priority Task 완료"
					print("Low Priority Task 완료")
				}
			} catch {
				print("Low Priority Task 에러 발생: \(error.localizedDescription)")
			}
		}
		.value
		/*
		 .value:
			- Task의 결과를 반환할 때 사용
			- Task는 비동기 작업으로 동작하므로, 작업 완료 후 결과를 기다리기 위해서 .value 호출
			- .value 는 작업 완료를 보장하고, 작업의 반환값 제공
		 */
	}
	
	// MARK: - .task Modifier example
	/// .task Modifier를 사용하여 작업을 실행하는 메서드
	func fetchDataWithDotTask() {
		dotTaskData = "Fetching data using .task ... Loading ..."
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			self.dotTaskData = ".task: Data Fetched 2초 걸림"
			print(".task Modifier 작업 완료")
		}
	}
}

// MARK: - View
struct Task1: View {
	
	@State private var vm: Task1ViewModel = .init()
	
    var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				// MARK: - Data Display 실행 결과 표시
				Group {
					Text(vm.highPriorityData.isEmpty ? "High Priority Task: Loading..." : vm.highPriorityData)
						.foregroundStyle(.accent)
						.multilineTextAlignment(.center)
					
					Text(vm.lowPriorityData.isEmpty ? "Low Priority Task: Loading..." : vm.lowPriorityData)
						.foregroundStyle(.blue)
						.multilineTextAlignment(.center)
					
					Text(vm.dotTaskData.isEmpty ? ".task Modifier: Loading..." : vm.dotTaskData)
						.foregroundStyle(.orange)
						.multilineTextAlignment(.center)
				} //:GROUP
				Divider()
				
				// MARK: - Buttons (작업 실행 버튼)
				HStack(spacing: 20) {
					// High & Low Priority Task 실행 버튼
					Button(action: {
						Task {
							await vm.fetchHighPriorityData()
						}
						Task {
							await vm.fetchLowPriorityData()
						}
					}, label: {
						Text("Start Priority Tasks")
							.frame(maxWidth: .infinity)
					})
					.buttonStyle(.borderedProminent)
					.padding(.horizontal)
					
					// .task 실행버튼
					Button(action: {
						vm.fetchDataWithDotTask()
					}, label: {
						Text("Run .task Modifier")
							.frame(maxWidth: .infinity)
					})
					.buttonStyle(.borderedProminent)
					.tint(.orange)
					.padding(.horizontal)
					
				} //:HSTACK
			} //:VSTACK
			.navigationTitle("Task 연습")
			.task {
				vm.fetchDataWithDotTask()
			}
		} //:NAVIGATION
    }//:body
}

#Preview {
    Task1()
}
