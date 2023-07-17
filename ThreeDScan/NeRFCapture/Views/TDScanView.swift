//
//  TDScanApp.swift
//  TDScan
//
//  Created by jacquiy on 7/16/23.
//

import SwiftUI

struct TDScanView: View {

    @StateObject var dataModel = DataModel()
       
    var body: some View {
       
        VStack {
            TabView{
                HomeView().tabItem(){
                    Text("Home")
                }
                ScanView().tabItem(){
                    Text("Scan")
                }
                ArView().tabItem(){
                    Text("AR")
                }
                DisplayView(modelName: "Airpods_Gen2.usdz").tabItem(){
                    Text("Display")
                }
                NavigationStack {
                    GridView()
                }
                .environmentObject(dataModel)
                .navigationViewStyle(.stack)
                .tabItem(){
                    Text("Gallery")
                }
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
