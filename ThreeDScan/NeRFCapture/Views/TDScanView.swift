//
//  TDScanApp.swift
//  TDScan
//
//  Created by jacquiy on 7/16/23.
//

import SwiftUI

struct TDScanView: View {
    @State private var tabSelection = 1
    @StateObject var dataModel = DataModel()
    // @State private var isLoggedIn = false
    // @State private var username = "User"
    var body: some View {
        // NavigationView {

        //         HStack {
        //             Spacer()
        //             if isLoggedIn {
                        
        //                 Text(username)
        //                     .font(.headline)
        //                     .padding()
        //                 Button(action: { isLoggedIn = false }) {
        //                     Text("Log out")
        //                         .font(.headline)
        //                 }
        //             } else {
        //                 Button(action: { isLoggedIn=LoginScreen() }) {
        //                     Text("Log in")
        //                         .font(.headline)
        //                 }
        //                 Button(action: { RegisterScreen()}) {
        //                     Text("Registration")
        //                         .font(.headline)
        //                 }
        //             }
        //         }

        // }
       
        VStack {
            TabView(selection:$tabSelection){
                HomeView(tabSelection: $tabSelection).tabItem(){
                    Text("Home")
                }.tag(1)
                NavigationStack {ScanView().navigationBarItems(leading: Button("Back") {action: do { self.tabSelection = 1 }})
                }.tabItem(){
                    Text("Scan")
                }.tag(2)
                NavigationStack {ArView().navigationBarItems(leading: Button("Back") {action: do { self.tabSelection = 1 }})
                }.tabItem(){
                    Text("AR")
                }.tag(3)
//                ArView().tabItem(){
//                    Text("AR")
//                }.tag(3)

                NavigationStack {DisplayView().navigationBarItems(leading: Button("Back") {action: do { self.tabSelection = 1 }})
                }.tabItem(){
                    Text("Display")
                }.tag(4)
                NavigationStack {
                    GridView().navigationBarItems(leading: Button("Back") {action: do { self.tabSelection = 1 }})
                }
                .environmentObject(dataModel)
                .navigationViewStyle(.stack)
                .tabItem(){
                    Text("Gallery")
                }.tag(5)
            }
//            NavigationStack {
//                GridView()
//            }
//            .environmentObject(dataModel)
//            .navigationViewStyle(.stack)
        }
    }
}

struct TDScanView_Previews: PreviewProvider {
    static var previews: some View {
        TDScanView()
    }
}
