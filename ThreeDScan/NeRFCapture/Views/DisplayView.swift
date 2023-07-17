//
//  DisplayView.swift
//  
//
//  Created by jacquiy on 7/12/23.
//

import SwiftUI
import SceneKit
import Foundation
import UIKit

struct DestinationView: View {
    let modelName: String
    var body: some View {
        VStack{
            ThreeDViewer(product:modelName).frame(width: UIScreen.main.bounds.width)
        }
    }
}


struct DisplayView: View {
    
    let folderName = "TD_Object"
    let fileManager = FileManager.default
    
    
    @State private var fileNames: [String] = []
    @State private var isPresentingDestinationView = false
    
    var body: some View {
        GeometryReader {geometry in
            NavigationView {
                VStack {
                    Text("Select a model")
                        .font(.title)
                        .padding()
                    
                    if fileNames.isEmpty {
                        Text("No files found.")
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(fileNames, id: \.self) { fileName in
                                    let displayName = fileName
                                    NavigationLink(destination: DestinationView(modelName: displayName)) {
                                        Text(displayName)
                                            .font(.headline)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height - 110) // Subtract 20 from height to create a distance from the bottom
                    }
                }
            }
            .onAppear {
                loadFileNames()
            }
        }
    }


    

    
    func loadFileNames() {
        guard let bundlePath = Bundle.main.path(forResource: folderName, ofType: nil) else {
            print("Bundle folder '\(folderName)' not found.")
            return
        }
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: bundlePath)
            var names: [String] = []
            
            for item in items {
                let fullPath = URL(fileURLWithPath: bundlePath).appendingPathComponent(item).path
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
                    if !isDirectory.boolValue {
                        
                        names.append(item)
                    }
                }
            }
            
            fileNames = names
            
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
        }
    }
    
    func navigateToDetailView(with fileName: String) {
        let destinationView = DestinationView(modelName: fileName)
        let destinationViewWrappedInNavigationView = NavigationView { // Wrap the destination view in a NavigationView
            destinationView
        }
        // Use the navigation link or other navigation techniques to navigate to the destination view
        // For example, if you're using NavigationLink:
        // present a NavigationLink to navigate to the destination view
        // and set isActive to trigger the navigation
        self.isPresentingDestinationView = true
    }

}



struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
    }
}
