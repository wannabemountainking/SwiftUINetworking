//
//  Combine1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 3/20/26.
//

// endPoint: https://dummyjson.com/posts

import SwiftUI
import Combine
import Observation


// MARK: - Model
struct Combine1Model: Codable {
    var posts: [Combine1Model2]
    let total: Int
    let limit: Int
}

struct Combine1Model2: Identifiable, Codable {
    let id: Int
    let title: String
    let body: String
    let tags: [String]
}

// MARK: - ViewModel
@Observable
final class Combine1ViewModel {
    var downloadedPosts: [Combine1Model2] = []
    var total: Int = 0
    var limit: Int = 0
    
    var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init() {
        self.getPosts()
    }
    
    func getPosts() {
        let endPoint = "https://dummyjson.com/posts"
        guard let url = URL(string: endPoint) else {return}
        
        // MARK: - Combine 시작
        // 1. Publisher 생성 (쿠팡 맴버쉽 가입)
        // 2. .subscribe: Publisher 를 background로 옮김 (쿠팡에서 상품 준비)
        // 3. .receive: Main Thread에서 UI 업데이트 (고객이 상품을 받음)
        // 4. .tryMap: Data와 Error 를 처리 (고객이 포장상태 및 상품 갯수 확인)
        // 5. .decode: Json -> Swift 타입으로 변환 (고객은 박스를 열어서 상품 확인)
        // 6. .sink: 받은 데이터를 업데이트 (고객은 상품 사용함)
        // 7. .store: .sink를 종료하기 위한 구독 취소 Set<AnyCancellable>() (고객이 로캣와우 구독 취소)
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
            .decode(type: Combine1Model.self, decoder: JSONDecoder())
            .sink { completion in
                print("status: \(completion)")
            } receiveValue: { [weak self] fetchePosts in
                guard let self else {return}
                self.downloadedPosts = fetchePosts.posts
                self.limit = fetchePosts.limit
                self.total = fetchePosts.total
            }
            .store(in: &cancellable)
    }
    // 4-1. .tryMap의 data와 error를 처리하기 위한 함수
    func handleOutput(_ output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return output.data
    }
}



struct Combine1: View {
    
    @State private var vm: Combine1ViewModel = .init()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Total Posts: \(vm.total) / \(vm.limit)")
                    .font(.largeTitle)
                ForEach(vm.downloadedPosts) { post in
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            Text(String(post.id))
                                .font(.largeTitle.bold())
                            Text(post.title)
                                .font(.title.bold())
                        } //:HSTACK
                        
                        Text(post.body)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 20) {
                            ForEach(post.tags, id: \.self) { tag in
                                Button("#\(tag)") {
                                    //action
                                    
                                }
                                .buttonStyle(.borderedProminent)
                            } //:LOOP
                        } //:HSTACK
                    } //:VSTACK
                    .padding()
                } //:LOOP
            } //:SCROLL
            .navigationTitle("Downloaded Json with @escaping")
            .navigationBarTitleDisplayMode(.inline)
        } //:NAVIGATION
    }
}

#Preview {
    Combine1()
}
