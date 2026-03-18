//
//  URLSession2.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 3/18/26.
//

import SwiftUI
import Observation

/*
 1. Post ViewModel 만들기 (네트워크 연결) https://dummyjson.com/posts/1
 2. Model 만들기
 3. UI 업데이트
 4. Posts 가져오기
 
 EndPoint: https://dummyjson.com/posts
 */
// MARK: - Model
struct URLSession2Model: Codable {
    var posts: [URLSession2Model2]
    let total: Int
    let limit: Int
}

struct URLSession2Model2: Identifiable, Codable {
    let id: Int
    let title: String
    let body: String
    let tags: [String]
}

// MARK: - ViewModel
@Observable
final class URLSession2ViewModel {
    // MARK: - Property
    var downloadedPosts: [URLSession2Model2] = []
    var total: Int = 0
    var limit: Int = 0
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        let endPoint = "https://dummyjson.com/posts"
        guard let url = URL(string: endPoint) else {return}
        
        downloadData(url) { downloadedData in
            /*
            if let data = downloadedData {
                 print("Success Downloaded Data")
                 print(data)
                 guard let jsonString = String(data: data, encoding: .utf8) else {return}
                 print(jsonString)
            }
             */
            
            // Data Decode 과정
            guard let data = downloadedData,
                  let newPosts = try? JSONDecoder().decode(URLSession2Model.self, from: data) else {return}
            // DataTask는 앱을 업데이트 하지 않고 background Thread에서 다운로드하지만,
            // UI 상으로 업데이트를 하기 위해서는 Main Thread에서 해줘야 함 (약한 참조 유지 해야 함)
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
//                self.downloadedPosts.append(newPosts)
                self.downloadedPosts = newPosts.posts
                self.limit = newPosts.limit
                self.total = newPosts.total
            }
        }
    }
    
    // 비동기 적으로 함수 종료 후에도 데이터가 return 될 수 있도록 @escaping 사용
    func downloadData(_ url: URL, completionHandler: @escaping (_ data: Data?) -> ()) {
        // URLSession DataTask 사용
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300,
                  error == nil else {
                print("Download Data Failed")
                completionHandler(nil)
                return
            }
            completionHandler(data)
        }
        // dataTask 는 기본적으로 일시정지 suspended 상태로 시작하기 때문에 마지막에 .resume() 을 호출하면 dataTask 작업이 재개(실행)되는 것임
        .resume()
    }
}

// MARK: - UI
struct URLSession2: View {
    
    @State private var vm: URLSession2ViewModel = .init()
    
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
    }//:body
}

#Preview {
    URLSession2()
}
