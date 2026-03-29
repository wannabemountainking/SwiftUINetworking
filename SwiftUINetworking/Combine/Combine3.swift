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


// MARK: - UI
struct Combine3: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    Combine3()
}
