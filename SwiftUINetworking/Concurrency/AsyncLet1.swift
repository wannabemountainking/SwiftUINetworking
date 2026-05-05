//
//  AsyncLet1.swift
//  SwiftUINetworking
//
//  Created by yoonie on 4/30/26.
//

import SwiftUI
import Observation


@Observable
final class AsyncLet1ViewModel {
	
	/// Task 방식으로 가져온 데이터 저장 변수
	var taskResult: String = ""
	/// async let 방식으로 가져온 데이터 저장 변수
	var asyncLetResult: String = ""
	
	// MARK: - Task 방식 (순차 실행)
	/// Task를 사용하여 데이터를 순차적으로 가져오는 메서드
	func fetchDataWithTask() async {
		let startTime = Date() // 시작 시간 기록
		
		// 데이터를 순차적으로 가져옴 (각 작업이 끝날 때까지 기다림)
	}
	
	// MARK: - <#분류 기준 작업 설명#>
}

struct AsyncLet1: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AsyncLet1()
}
