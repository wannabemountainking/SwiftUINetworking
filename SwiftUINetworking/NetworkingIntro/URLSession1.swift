//
//  URLSession1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 3/16/26.
//

/*
 1. 기본 UI 만들기
 2. Model 만들기
 3. Network Code
 4. 연결하기
 
 API: https://dummyjson.com/
 EndPoint: https://dummyjson.com/users/랜덤숫자(1~100)까지
 */

import SwiftUI


// MARK: - Model(받을 구조체는 키가 받아오는 서버의 파라미터 키와 동일해야 함)_
struct RandomUser: Codable {
    let username: String
    let image: String
    let email: String
    let age: Int
}

// MARK: - Error Type
enum RandomError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

// MARK: - UI
struct URLSession1: View {
    
    @State private var user: RandomUser?
    @State private var userImage: UIImage = UIImage(systemName: "person")!
    
    var body: some View {
        VStack(spacing: 20) {
            
            //TODO: AsyncImage 사용하기
            AsyncImage(url: URL(string: user?.image ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                // image
                Circle()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 200, height: 200)
            
            // username age
            HStack(spacing: 20) {
                Text(user?.username ?? "User name")
                    .font(.title.bold())
                Text("\(user?.age ?? 0)")
                    .font(.title.bold())
            }
            // email
            Text(user?.email ?? "google@gmail.com")
                .font(.title2)
                .padding()
            
            // refresh button
            Button(action: {
                Task {
                    do {
                        user = try await getUser()
                    } catch RandomError.invalidURL {
                        print("invalid URL")
                    } catch RandomError.invalidResponse {
                        print("invalid Response")
                    } catch RandomError.invalidData {
                        print("invalid Data")
                    } catch {
                        print("I don't know: \(error)")
                    }
                }
            }, label: {
                Text("Get Random User")
                    .font(.title)
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            Spacer()
        } //:VSTACK
        .padding()
    }
    
    // MARK: - Function
    private func getUser() async throws -> RandomUser {
        let randomNum = Int.random(in: 1...100)
        let endPoint = "https://dummyjson.com/users/\(randomNum)"
        // url이 옵셔널 값이기 때문에 error 처리 안하고 강제로 ! 붙여서 하기
        //        let url = URL(string: endPoint)!
        
        // 정공법
        guard let url = URL(string: endPoint) else { throw RandomError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RandomError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(RandomUser.self, from: data)
        } catch {
            throw RandomError.invalidData
        }
    }
}

#Preview {
    URLSession1()
}
