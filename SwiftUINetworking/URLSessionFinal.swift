//
//  URLSessionFinal.swift
//  SwiftUINetworking
//
//  Created by yoonie on 3/20/26.
//

// endPoint: https://picsum.photos/200

import SwiftUI
import Combine


@Observable
final class URLSessionFinalViewModel {
    var imageFromEscaping: UIImage? = nil
    var imageFromCombine: UIImage? = nil
    var imageFromAsync: UIImage? = nil
    
    let endPoint: String = "https://picsum.photos/200"
    var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // Error 처리 위한 함수
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {return nil}
        return image
    }
    
    // MARK: - 이미지 가져오기
    // MARK: - @escaping
    func fetchImage() {
        downloadWithEscaping {[weak self] image, error in
            if let image = image {
                guard let self else {return}
                self.imageFromEscaping = image
            }
        }
    }
    func downloadWithEscaping(completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        guard let url = URL(string: self.endPoint) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, res, err in
            guard let self else {return}
            let image = self.handleResponse(data: data, response: res)
            completion(image, err)
        }
        task.resume()
    }
    
    // MARK: - Combine
    func downloadWithCombine() {
        // 단순히 이미지만 받는 것이라 .subscribe, .receive생략 => 근데 나는 연습용으로 쓸것임
        guard let url = URL(string: self.endPoint) else {return}
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .map(handleResponse)
            .mapError( { $0 } )
            .sink { completion in
            } receiveValue: { [weak self] image in
                guard let self else {return}
                self.imageFromCombine = image
            }
            .store(in: &cancellable)
    }
    
    // MARK: - Async
    func downloadWithAsync() async throws {
        guard let url = URL(string: self.endPoint) else {return}
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let image = handleResponse(data: data, response: response)
            self.imageFromAsync = image
        } catch {
            throw error
        }
        
    }
}

struct URLSessionFinal: View {
    @State private var vm: URLSessionFinalViewModel = .init()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("1. @escaping")
                        .font(.title)
                    
                    if let image = vm.imageFromEscaping {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        vm.fetchImage()
                    }, label: {
                        Text("Download Image with @escaping")
                            .frame(maxWidth: .infinity)
                            .font(.title2)
                    })
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    Divider()
                    
                    Text("2. Combine")
                        .font(.title)
                    
                    if let image = vm.imageFromCombine {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        vm.downloadWithCombine()
                    }, label: {
                        Text("Download Image with Combine")
                            .frame(maxWidth: .infinity)
                            .font(.title2)
                    })
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    Divider()
                    
                    Text("3. Async")
                        .font(.title)
                    
                    if let image = vm.imageFromAsync {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                try await vm.downloadWithAsync()
                            } catch {
                                print(error)
                            }
                        }
                    }, label: {
                        Text("Download Image with Async")
                            .frame(maxWidth: .infinity)
                            .font(.title2)
                    })
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    Divider()
                    
                } //: VSTACK
            } //:SCROLL
            .navigationTitle("@escaping vs Combine vs Async")
            .navigationBarTitleDisplayMode(.inline)
        }//: NAVIGATIONSTACK
    }//: body
}

#Preview {
    URLSessionFinal()
}
