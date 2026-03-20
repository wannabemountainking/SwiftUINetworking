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
    func handleResponse(data: Data?, response: HTTPURLResponse?) -> UIImage? {
        guard let data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else
        {return nil}
        return image
    }
    
    // MARK: - 이미지 가져오기
    // MARK: - @escaping
    func fetchImage() {
        
    }
    
    func downloadWithEscaping(completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        guard let url = URL(string: endPoint) else {return}
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, res, err in
            guard let self else {return}
            let image = handleResponse(data: data, response: res as! HTTPURLResponse)
        }
    }
    // MARK: - Combine
    
    // MARK: - Async
    
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
                    
                    Text("1. Combine")
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
                        
                    }, label: {
                        Text("Download Image with Combine")
                            .frame(maxWidth: .infinity)
                            .font(.title2)
                    })
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    Divider()
                    
                    Text("1. Async")
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
