//
//  Combine2.swift
//  SwiftUINetworking
//
//  Created by YoonieMac on 3/28/26.
//

import SwiftUI
import Observation
import Combine


/*
Observation @Observable 이전의 방법
final class Combine1ViewModel2: ObservableObject {
 @Published var text: String = ""
}
 */


// MARK: - ViewModel
@Observable
final class Combine2ViewModel {
    // timer property
    var count: Int = 0
//    var cancellable = Set<AnyCancellable>()
    var cancellable: Set<AnyCancellable> = []
    
    // ID TextField Property
    @ObservationIgnored @Published var textFieldID: String = ""
    var idValid: Bool = false
    
    //PASSWORD TextField Property
    @ObservationIgnored @Published var textFieldPassword: String = ""
    var passwordValid: Bool = false
    
    // Button Property
    var showButton: Bool = false
    
    /*
     // Published를 manually 사용해보기
     var textFieldID2: String = "" {
         didSet {
             self.textFieldID2Publisher.send(textFieldID2)
         }
     }
     private var textFieldID2Publisher: CurrentValueSubject<String, Never> = .init("")
     
     */
    
    init() {
//        setTimer()
        addIDSubscription()
        addPasswordSubscription()
    }
    
    //Function
    func setTimer() {
        Timer
            // 1초마다 변하는 Timer Publisher 생성
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            // .onReceive() 는 UI 부분에서 한 Subscriber이고 Combine에서는 .sink 사용
            .sink { [weak self] _ in
                //self unwrapping
                guard let self else {return}
                // 1초 당 1씩 증가
                self.count += 1
                // 5가 되면 cancel되서 publisher 종료
                if self.count >= 5 {
                    for item in self.cancellable {
                        item.cancel()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.count = 0
                    }
                }
            }
            .store(in: &cancellable)

    }
    
    // ID Subscription
    func addIDSubscription() {
        //textFieldID2Publisher도 사용 가능
        $textFieldID
        // debounce -> 딜레이 발생 후 진행(반영)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .map { text in
                return text.count > 3
            }
//            .assign(to: \.idValid, on: self) // 이건 직접 할당하는 것이어서 .sink 추천
            .sink { [weak self] isValid in
                guard let self else {return}
                self.idValid = isValid
            }
            .store(in: &cancellable)
    }
    
    // PASSWORD Subscription
    func addPasswordSubscription() {
        $textFieldPassword
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .map { password in
                return self.isPasswordValid(password)
            }
            .sink { [weak self] isValid in
                guard let self else {return}
                self.passwordValid = isValid
            }
            .store(in: &cancellable)
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        let hasUpperCase: Bool = password.contains { $0.isUppercase }
        let hasNumber: Bool = password.contains { $0.isNumber }
        let isLengthValid: Bool = password.count >= 8
        return hasUpperCase && hasNumber && isLengthValid
    }
}

// MARK: - UI
struct Combine2: View {
    
    @State private var vm: Combine2ViewModel = .init()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("1. Timer Combine 만들기")
                    .font(.title.bold())
                Text("\(vm.count)")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.accent)
                
                Divider()
                
                Text("2. ID, Password 입력 만들기")
                    .font(.title.bold())
                VStack(spacing: 20) {
                    Text("ID: \(vm.textFieldID)")
                    Text("PASS: \(vm.textFieldPassword)")
                } //:VSTACK
                .font(.title2.bold())
                .foregroundStyle(.accent)
                
                //ID TextField
                VStack(alignment: .leading, spacing: 5) {
                    TextField("ID를 입력하세요", text: $vm.textFieldID)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .overlay(alignment: .trailing) {
                            ZStack {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.red)
                                    .opacity(vm.textFieldID.count < 1 ? 0 : vm.idValid ? 0 : 1)
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                                    .opacity(vm.idValid ? 1 : 0)
                            }
                            .font(.title)
                            .padding(.trailing)
                        }
                    
                    Text("* ID는 최소. 4글자 이상이어야 합니다")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                // PASSWORD SecureField
                VStack(alignment: .leading, spacing: 5) {
                    SecureField("PASSWORD를 입력하세요", text: $vm.textFieldPassword)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .overlay(alignment: .trailing) {
                            ZStack {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.red)
                                    .opacity(vm.textFieldPassword.count < 1 ? 0 : vm.passwordValid ? 0 : 1)
                                
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                                    .opacity(vm.passwordValid ? 1 : 0)
                            }
                            .font(.title)
                            .padding(.trailing)
                        }

                    Text("* PASSWORD는 대문자, 숫자 포함 8글자 이상이어야 합니다")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                // Login Button
                Button {
                    //action
                } label: {
                    Text("Login")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(!vm.idValid || !vm.passwordValid)
                
                Spacer()

            } //:VSTACK
            .navigationTitle("Publisher and Subscribe 실습")
            .navigationBarTitleDisplayMode(.inline)
        } //:NAVSTACK
    }
}

#Preview {
    Combine2()
}
