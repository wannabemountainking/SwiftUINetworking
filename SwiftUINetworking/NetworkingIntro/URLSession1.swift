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

// MARK: - UI
struct URLSession1: View {
    var body: some View {
        VStack(spacing: 20) {
            // image
            Circle()
                .foregroundStyle(.secondary)
                .frame(width: 200, height: 200)
            // username age
            HStack(spacing: 20) {
                Text("User Name")
                    .font(.title.bold())
                Text("30")
                    .font(.title.bold())
            }
            // email
            Text("google@gmail.com")
                .font(.title2)
                .padding()
            
            // refresh button
            Button(action: {
                
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
}

#Preview {
    URLSession1()
}
