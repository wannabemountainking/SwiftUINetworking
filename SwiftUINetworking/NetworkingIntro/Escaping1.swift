//
//  Escaping1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 3/17/26.
//

import SwiftUI

enum FetchError: Error {
    case DelayError
}

@Observable
class Escaping1ViewModel {
    var text: String = "Default Text"
    
    func getData() {
        text = fetchData1()
        fetchData2 { [weak self] returnedData in
            guard let self else {return}
            self.text = returnedData
        }
        fetchData3 { [weak self] result in
            guard let self else {return}
            self.text = result.data
        }
        fetchData4 { [weak self] result in
            guard let self else {return}
            self.text = result.data
        }
    }
    
    // 1. Synchronous Code: 동기적으로 function이 시작되면 순차적으로 실행되는 것
    private func fetchData1() -> String {
        return "Fetched Data 1"
    }
    
    // 2. Asyncronous 상황: 만약 인터넷에서 text 파일을 서버로 부터 받을 경우에는 delay가 발생해서 Error 발생
    // _ 언더스코어는 외부 변수에서 받는 이름이 없는 경우 _ 사용
    // Void 또는 (): 함수가 아무것도 반환하지 않을 때 사용
    private func fetchData2(completionHandler: @escaping (_ data: String) ->()) {
        // 인위적으로 1초 딜레이 발생하고 코드 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler("Fetched Data 2")
        }
    }
    
    // 3. 데이터 모델로 만들어서 코드 간소화하기
    private func fetchData3(completionHandler: @escaping (DownloadResult) ->()) {
        // 인위적으로 2초 딜레이 발생하고 코드 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let result = DownloadResult(data: "Fetched Data 3")
            completionHandler(result)
        }
    }
    
    // 4. typealias 만들어서 더 간소화하기
    private func fetchData4(completionHandler: @escaping DownloadCompletion) {
        // 인위적으로 2초 딜레이 발생하고 코드 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let result = DownloadResult(data: "Fetched Data 3")
            completionHandler(result)
        }
    }
}

// Data Model: (_ data: String) -> () 를 Model로 만들기
struct DownloadResult {
    let data: String
}

typealias DownloadCompletion = (DownloadResult) -> ()

struct Escaping1: View {
    
    @State private var vm: Escaping1ViewModel = .init()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(vm.text)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                
                Button(action: {
                    vm.getData()
                }, label: {
                    Text("Get Data")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            } //:VSTACK
            .navigationTitle("@escaping 연습")
        } //:NAVSTACK
    }
}

#Preview {
    Escaping1()
}
