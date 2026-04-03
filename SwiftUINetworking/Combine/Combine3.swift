//
//  Combine3.swift
//  SwiftUINetworking
//
//  Created by yoonie on 3/30/26.
//

import SwiftUI
import Observation
import Combine


// MARK: - Data Service
final class Combine3DataService {
    //properties
//    @Published var basicPublisher: String = ""
    
    // 1. CurrentValuePublisher: 초기값이 있다는 것이 특징. 실제적으로 API통신 할 때 Never 대신 Error 처리를 위해 Error 사용
    let currentValuePublisher = CurrentValueSubject<Int, Error>(777)
    // 2. PassThroughPublisher: init value 가 없다는 게 차이점이라서 메모리 관리에 저장공간이 없어서 app 최적화에 passThroughPublisher 더 강점이 있음
    let passThroughPublisher = PassthroughSubject<Int, Error>()
    
    // initialization
    init() {
        publishFakeData()
    }
    // functions
    private func publishFakeData() {
//        let items: [String] = ["One", "Two", "Three"]
        
//        let items: [Int] = Array(0..<6)
        let items: [Int] = [0,1,2,2,0,3,4,7,5]
        for index in items.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) {
//                self.basicPublisher = items[index]
//                self.currentValuePublisher.send(items[index])
                self.passThroughPublisher.send(items[index])
                // passThroughPublisher에게 마지막 부분을 알려줘야 .last() 실행
                if index == items.indices.last {
                    self.passThroughPublisher.send(completion: .finished)
                }
            }
        }
    }
}

// MARK: - ViewModel
@Observable
final class Combine3ViewModel {
    // properties
    var data: [String] = []
    let dataService = Combine3DataService()
    var errorMessage: String = ""
    var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscribe()
    }
    
    private func addSubscribe() {
//        dataService.$basicPublisher
//        dataService.currentValuePublisher
        dataService.passThroughPublisher
        
        // MARK: - Sequence Operators
        /*
        // 1. First: 처음 값만 출력하고 종료
//            .first() // 0 출력
//            .first(where: { $0 > 3 }) // 3보다 큰 값 중에 처음값인 4 출력
//            .tryFirst(where: { int in // Try는 error가 발생 시 error를 던지고 .failure로 넘어감
//                if int == 3 {
//                    throw URLError(.badServerResponse)
//                }
//                return int > 3 // 4가 출력되지 않고 error 먼저 발생되서 error 처리됨
//                return int > 1 // 2가 출력 error 조건보다 앞서기 때문에 2출력
//            })
        // 2. Last: 마지막 값만 출력하고 종료
//            .last() // last는 publisher가 마지막이 언제 시점인지 알려줘야 실행됨
//            .last(where: { $0 < 4 }) // 3 출력
//            .tryLast(where: { int in
//                if int == 3 {
//                    throw URLError(.badServerResponse)
//                }
//                return int > 4
//            })
        // 3. DropFirst: Stream 에 맨 처음 value를 skip 하고 쭉 진행
//            .dropFirst() // 777을 생략하고 0부터 진행, 만약 currentValueSubject 일때 사용하면 초기값을 삭제할 수 있음
//            .dropFirst(2) // 0, 1 스킵하고 2,3,4,5 출력
//            .drop(while: { $0 < 3 }) // 3보다 작은 것들을 drop 큰 게 나오면 그냥 중단
//            .tryDrop(while: { int in
//                if int == 2 {
//                    throw URLError(.badServerResponse)
//                }
//                return int < 3
//            })
        // 4. prefix: 숫자 기준으로 앞에서부터 몇개의 value를 emit 할 것인지 정하기
//            .prefix(3) //앞에서 3개만 출력 0,1,2
//            .prefix(while: {  $0 < 4 })  // 4보다 작은 3까지 앞에서부터 쭉 출력
//            .tryPrefix(while: { int in  // int가 2일때 error 도 출력
//                if int == 2 {
//                    throw URLError(.badServerResponse)
//                }
//                return int < 3 // 0, 1 은 출력이 됨
//            })
        // 5. output: at (기준으로 정확하게 값(value)을 가리킴), in (value 범위를 설정함)
//            .output(at: 3) // 순번,index가 아니라 값이 출력됨
//            .output(in: 2..<5) // 2,3,4가 출력이 됨
        */
        
        // MARK: - Mathematic Operation
        /*
         // 1. Max: Stream line 중에서 숫자적으로 가장 큰 숫자 출력
 //            .max() // 5출력
 //            .max(by: { int1, int2 in // 7출력
 //                return int1 < int2
 //            })
 //            .tryMax(by: { int1, int2 in
 //                if int1 == 2 {
 //                    throw URLError(.badServerResponse)
 //                }
 //                return int1 < int2
 //            })
         // 2. Min: 숫자 면에서 가장 작은 숫자 출력
 //            .min() // 0 출력
 //            .min(by: { int1, int2 in
 //                return int1 > int2 // 0 출력
 //            })
 //            .tryMin(by: { int1, int2 in
 //                if int1 == 7 {
 //                    throw URLError(.badServerResponse)
 //                }
 //                return int1 < int2
 //            })
         
        // 3. Count: Stream line의 갯수
//            .count() // 7 출력
         */
        
        // MARK: - Filter Operations
        
        // 1. map: 각각의 element 들의 데이터 변환(타입 등)을 줄 때 사용
//            .map({ String($0) })
//            .tryMap({ int in
//                if int == 5 {
//                    throw URLError(.badServerResponse)
//                }
//                return String(int)
//            })
        // 2. compactMap: map에서 nil인 경우만 정제해서 stream 출력
        // map을 사용하게 되면 error도 같이 출력이 되는데 compactMap을 사용해서 정제된 data만 추출할 수 있음
//            .compactMap({ int -> String? in
//                if int == 7 {
//                    return nil // 7 값을 return nil로 설정함에 따라서 compactMap 7값이 제거됨
//                }
//                return String(int) // 7 빼고 다 출력
//            })
        // 3. filter: 특정 조건에 맞으면 출력되는 것. 타입변환, 데이터 변환 없음
//            .filter({ $0 > 3 }) // 3 이상인 것들만 출력 -> 4, 7, 5
//            .tryFilter({ int in
//                if int == 5 {
//                    throw URLError(.badServerResponse)
//                }
//                return int > 3 // 나머지 4, 7는 출력됨
//            })
        // 4. removeDuplicate: Stream line에서 이전 값과 동일한 값을 삭제시켜줌 (소요시간은 줄지 않음)
//            .removeDuplicates() // Array에서 나중에 나오는 0은 출력이 됨. 바로 이어지는 이전 element만 삭제한다는 것이 특징
//            .removeDuplicates(by: { int1, int2 in // 여기서 int1: prev, int2: current
//                return int1 >= int2
//            }) // 같은 조건이 아니라, 만약 이전 것과 비교해서 앞의 것이 큰 것만 return하는 코드
//            .tryRemoveDuplicates(by: { int1, int2 in
//                if int1 == 2 {
//                    throw URLError(.badServerResponse)
//                }
//                return int1 > int2
//            }) // 0, 1, 2, Error 출력
            .map({ String($0) })
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = "Error: \(error)"
                }
            } receiveValue: { [weak self] returnedValue in
                guard let self else {return}
                self.data.append(returnedValue)
            }
            .store(in: &cancellable)
    }
}


// MARK: - UI
struct Combine3: View {
    
    @State @State private var vm: Combine3ViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(vm.data, id: \.self) { item in
                    Text(String(item))
                        .font(.largeTitle)
                        .bold()
                } //:LOOP
                
                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                }
            } //:VSTACK
        } //:SCROLL
    }//: Body
}

#Preview {
    Combine3()
}
