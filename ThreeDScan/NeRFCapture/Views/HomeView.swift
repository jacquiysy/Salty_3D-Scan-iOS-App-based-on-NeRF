//
//  HomeView.swift
//  Image Gallery
//
//  Created by jacquiy on 7/12/23.
//

import SwiftUI

struct HomeView: View {
    @State private var showScanView = false
    @State private var showArView = false
    @State private var showDisplayView = false
    @State private var showGalleryView = false
    
    @StateObject var dataModel = DataModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 60.0)
                Button(action: { showScanView = true }) {
                    Text("Scan")
                        .font(.largeTitle)
                        .padding(.bottom)
                        
                }
                Button(action: { showArView = true }) {
                    Text("AR")
                        .font(.largeTitle)
                        .padding(.bottom)
                }
                Button(action: { showDisplayView = true }) {
                    Text("Display")
                        .font(.largeTitle)
                        .padding(.bottom)
                }
                Button(action: { showGalleryView = true }) {
                    Text("Gallery")
                        .font(.largeTitle)
                }
                NavigationLink("", destination: ScanView(), isActive: $showScanView)
                NavigationLink("", destination: ArView(), isActive: $showArView)
                NavigationLink("", destination: DisplayView(modelName: "Airpods_Gen2.usdz"), isActive: $showDisplayView)
                NavigationLink("", destination: GridView().environmentObject(dataModel), isActive: $showGalleryView)
            }
        }
    }
    
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
