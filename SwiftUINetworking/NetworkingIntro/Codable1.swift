//
//  Codable1.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 3/18/26.
//

import SwiftUI

// MARK: - Model 만들기
struct CustomerModel: Identifiable, Codable {
    let id: String
    let name: String
    let points: Int
    let isPremium: Bool
}

// MARK: - ViewModel
@Observable
final class CodableViewModel {
    var customer: CustomerModel?
    
    init() {
        getData()
    }
    
    func getData() {
        guard let data = getJsonData() else { return }
        print("Json Data: \(data)")
        // Data를 String으로 가공
        print(String(data: data, encoding: .utf8) ?? "")
        
        /*
         // 그래서 Data -> Swift가 읽을 수 있는 Json 타입 (Swift Data) 형태로 변환
         // Swift가 읽을 수 있는 Json 타입 (Swift Data) -> Data: JSONSerialization.data(withJsonObject:options:)
         // Data -> Swift가 읽을 수 있는 Json 타입 (Swift Data) : JSONSerialization.jsonObject(with:options:)
         if let localData = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = localData as? [String: Any],
            // 그리고 각 localData의 값을 dictionary에서 추출해서 넣어줌
            let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let points = dictionary["points"] as? Int,
            let isPremium = dictionary["isPremium"] as? Bool
         {
             let newCustomer = CustomerModel(id: id, name: name, points: points, isPremium: isPremium)
             // 위의 변수를 변경
             customer = newCustomer
         }
         */
        // MARK: - Decodable
        let newCustomer = try? JSONDecoder().decode(CustomerModel.self, from: data)
        customer = newCustomer
    }
    
    // 임의로 Json 파일 가져오기
    func getJsonData() -> Data? {
        /*
         // Dictionary 형태로 가짜 json 파일 가져오기
         let fakeJson: [String : Any] = [
             "id": "123",
             "name": "Mike",
             "points": 5,
             "isPremium": true
         ]
         
         // MARK: - JSON Serialization
         /*
          - JSONSerialization: Json의 직렬화 - 어떤 환경의 데이터 구조를 다른 환경에 전송 및 저장하기 위해 나중에 재구성할 수 있는 바이트의 포맷으로 변환하는 과정
          - 필요한 이유: Reference Data는 병렬적으로 구성되어 있어 하나의 데이터로 전송하는 것이 불가능
          - 직렬화 (Serialization)하여 하나의 묶음 포장으로 전송함
          - 예) 인터넷 쇼핑에서 여러가지 물건을 장바구니에 담고 배송하면 1개의 박스로 여러 개의 물건이 묶어져서 들어오는 것과 같은 원리
          - fakeJson은 dictionary형태의 Swift Data를 -> JsonData로 형태 변환
          */
         // Swift가 읽을 수 있는 Json 타입 (Swift Data) -> Data로 변경
         let jsonData1 = try? JSONSerialization.data(withJSONObject: fakeJson, options: [])
         return jsonData1
         */
        // MARK: - Encodable
        
        let customerToJson = CustomerModel(id: "1234", name: "yoonie", points: 10, isPremium: false)
        let jsonData2 = try? JSONEncoder().encode(customerToJson)
        return jsonData2
    }
}

struct Codable1: View {
    @State var vm: CodableViewModel = .init()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let customer = vm.customer {
                    Text(customer.id)
                    Text(customer.name)
                    Text(String(describing: customer.points))
                    Text(customer.isPremium.description)
                }
            } //:VSTACK
            .font(.title)
            .bold()
            .navigationTitle("Codable Practice")
        } //:NAVSTACK
    }
}

#Preview {
    Codable1(vm: CodableViewModel())
}
