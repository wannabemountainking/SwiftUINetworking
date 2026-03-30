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
    @Published var basicPublisher: String = ""
    
    // initialization
    init() {
        publishFakeData()
    }
    // functions
    private func publishFakeData() {
        let items: [String] = ["One", "Two", "Three"]
        for index in items.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) {
                self.basicPublisher = items[index]
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
        dataService.$basicPublisher
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
                    Text(item)
                        .font(.largeTitle)
                        .bold()
                } //:LOOP    
            } //:VSTACK
        } //:SCROLL
    }//: Body
}

#Preview {
    Combine3()
}
