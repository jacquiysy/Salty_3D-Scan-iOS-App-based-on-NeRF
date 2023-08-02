//
//  RegisterScreen.swift
//  ThreeDScan
//
//  Created by 薛冠华 on 8/2/23.
//

import Foundation
import SwiftUI

struct RegisterScreen: View {
    @Published var baseURL = "http://10.0.6.82:8080/"
    @State var username=""
    @State var email = ""
    @State var password = ""
    fileprivate func UsernameInput() -> some View {
        TextField("Username", text: $username)
            .textFieldStyle(.roundedBorder)
    }
    
    
    fileprivate func EmailInput() -> some View {
        TextField("Email", text: $email)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func PasswordInput() -> some View {
        SecureField("Password", text: $password)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func RegisterButton() -> some View {
        Button(action: {
            Task {
                await RegisterToServer(username:username,
                                     email: email,
                                     password:password)
        }) {
            Text("Sign In")
        }
    }
    
    var body: some View {
        
        VStack{
            {
                Text("Register Screen").font(.title)
                UsernameInput()
                EmailInput()
                PasswordInput()
                RegisterButton()
            }
        }.padding()
        
    }
               
               
    func RegisterToServer(username: String, email: String, password: String) async {
                                  let serverURL = URL(string: baseURL + "register")!
                                  var request = URLRequest(url: serverURL)
                                  request.httpMethod = "POST"
                                  request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                                  
                                  let parameters = [
                                      "username": username,
                                      "password": password,
                                      "email":email,
                                  ]
                                  
                                  let body = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                                  request.httpBody = body.data(using: .utf8)
                                  
                                  do {
                                      let (data, response) = try await URLSession.shared.data(for: request)
                                      
                                      if let httpResponse = response as? HTTPURLResponse {
                                          if httpResponse.statusCode == 200 {
                                              // Sign in successful
                                              print("Sign in successful")
                                          } else {
                                              // Sign in failed
                                              print("Sign in failed")
                                          }
                                      }
                                  } catch {
                                      print("Error signing in: \(error)")
                                  }
                              }
}


