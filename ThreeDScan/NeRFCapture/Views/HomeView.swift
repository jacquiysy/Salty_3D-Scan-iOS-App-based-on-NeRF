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
    var body: some View {
        NavigationView {
            VStack (alignment: .center, spacing: 20){
//            VStack{
                Spacer()
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
                        //                       isLoggedIn=LoginScreen()
                        
                        
                    }) {
                        Text("Log in")
                            .font(.headline)
                    }
                    Button(action: {
                        //                       RegisterScreen()
                        
                    }) {
                        Text("Registration")
                            .font(.headline)
                    }
                }
                
                
                
                VStack {
                    Text("Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 60.0)
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
                    //                NavigationLink("", destination: ScanView(), isActive: $showScanView)
                    //                NavigationLink("", destination: ArView(), isActive: $showArView)
                    //                NavigationLink("", destination: DisplayView(), isActive: $showDisplayView)
                    //                NavigationLink("", destination: GridView().environmentObject(dataModel), isActive: $showGalleryView)
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
