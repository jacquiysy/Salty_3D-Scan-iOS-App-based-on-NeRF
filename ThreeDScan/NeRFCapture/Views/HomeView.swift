//
//  HomeView.swift
//  Image Gallery
//
//  Created by jacquiy on 7/12/23.
//

import SwiftUI

struct HomeView: View {
//    @State private var showScanView = false
//    @State private var showArView = false
//    @State private var showDisplayView = false
//    @State private var showGalleryView = false
    @Binding var tabSelection: Int
    
    @StateObject var dataModel = DataModel()
    @State private var isLoggedIn = false
    @State private var username = "User"
    @State private var showingLoginScreen=false
    @State private var showingRegisterScreen=false
    var body: some View {
        NavigationView {
                
            VStack {
                
                HStack (alignment: .top, spacing: 10){
                    if isLoggedIn {
                        Text(username)
                            .font(.headline)
                            .padding()
                        Button(action: { isLoggedIn = false }) {
                            Text("Log out")
                                .font(.headline)
                        }
                    } else {
                        Button(action: {
                            showingLoginScreen=true
                            //                                               LoginScreen()
                            isLoggedIn = true
                        }) {
                            Text("Log in")
                                .font(.headline)
                        }.sheet(isPresented: $showingLoginScreen){LoginScreen() }.padding(.leading, 20)
                        Spacer()
                        Button(action: {
                            showingRegisterScreen=true
                            //                                               RegisterScreen()
                            isLoggedIn = true
                        }) {
                            Text("Register")
                                .font(.headline)
                        }.sheet(isPresented: $showingRegisterScreen){RegisterScreen()   }
                            .padding(.trailing, 20)
                    }
                }.padding(.bottom, 70).padding(.top, -60)
                
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40.0)
                Button(action: { self.tabSelection = 2 }) {
                    Text("Scan")
                        .font(.largeTitle)
                        .padding(.bottom)
                    
                }
                Button(action: { self.tabSelection = 3 }) {
                    Text("AR")
                        .font(.largeTitle)
                        .padding(.bottom)
                }
                Button(action: { self.tabSelection = 4 }) {
                    Text("Display")
                        .font(.largeTitle)
                        .padding(.bottom)
                }
                Button(action: { self.tabSelection = 5 }) {
                    Text("Gallery")
                        .font(.largeTitle)
                }
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        TDScanView()
    }
}
