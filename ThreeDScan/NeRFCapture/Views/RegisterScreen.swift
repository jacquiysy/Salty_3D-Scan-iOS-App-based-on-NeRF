
//
//  RegisterScreen.swift
//  ThreeDScan
//
//  Created by 薛冠华 on 8/2/23.
//

import Foundation
import SwiftUI

struct RegisterScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var baseURL = "http://10.0.6.82:8080/"
    @State var username=""
    @State var email = ""
    @State var password = ""
    var onCompletion: (Bool) -> Void
    
    var body: some View {

        VStack{

                Text("Register Screen").font(.title)
                UsernameInput()
                EmailInput()
                PasswordInput()
                RegisterButton()

        }.padding()

    }
    
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
    // func RegisterToServer(username: String, email: String, password: String) async {
    //                               let serverURL = URL(string: baseURL + "register")!
    //                               var request = URLRequest(url: serverURL)
    //                               request.httpMethod = "POST"
    //                               request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    //                               let parameters = [
    //                                   "username": username,
    //                                   "password": password,
    //                                   "email":email,
    //                               ]

    //                               let body = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    //                               request.httpBody = body.data(using: .utf8)

    //                               do {
    //                                   let (data, response) = try await URLSession.shared.data(for: request)

    //                                   if let httpResponse = response as? HTTPURLResponse {
    //                                       if httpResponse.statusCode == 200 {
    //                                           // Sign in successful
    //                                           print("Register in successful")

    //                                       } else {
    //                                           // Sign in failed
    //                                           print("Register in failed")
    //                                       }
    //                                   }
    //                               } catch {
    //                                   print("Error Register in: \(error)")
    //                               }
    //                           }
    

func RegisterToServer(username: String, email: String, password: String) async -> Bool 
    {
    let serverURL = URL(string: baseURL + "register")!
    var request = URLRequest(url: serverURL)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let parameters = [
        "username": username,
        "password": password,
        "email": email,
    ]

    let body = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    request.httpBody = body.data(using: .utf8)

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        if  let responseString = String(data: data, encoding: .utf8) {
            if responseString == "register success" {
                // Sign in successful
                print("Register successful")
                return true
            } else {
                // Sign in failed
                print("Register failed")
                return false
            }
        }
    } catch {
        print("Error register in: \(error)")
        return false
    }
        return true
}


    fileprivate func PasswordInput() -> some View {
        SecureField("Password", text: $password)
            .textFieldStyle(.roundedBorder)
    }

    fileprivate func RegisterButton() -> some View {
        
         Button(action: {Task{
             let success =  await RegisterToServer(username:username,
                                            email: email,
 password:password)
            
            if true {
                presentationMode.wrappedValue.dismiss()
            }
        onCompletion(success)
        }}
        ) {
            Text("Register")
        }
    }
               



}
               


               
