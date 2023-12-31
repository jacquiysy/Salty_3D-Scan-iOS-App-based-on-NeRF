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
    
    @State private var isShowingPopup = false
    @State private var pressedDownload = false
    @State private var gifData: Data?
    
    var body: some View {
        if !pressedDownload {
            VStack{
                ThreeDViewer(product:modelName).frame(width: UIScreen.main.bounds.width)
                HStack(alignment: .center, spacing: 50) {
                    Button("Download gif") {
                        pressedDownload = true
                        downloadGIF()
                    }
                    //                .sheet(isPresented: $isShowingPopup) {
                    //                    if let gifData = gifData {
                    //                        GifPopupView(gifData: gifData)
                    //                    }
                    //                }
                    Button("Share model") {
                        shareButton()
                    }
                }
            }
        } else {
            if !isShowingPopup {
                Text("Downloading Gif")
            } else {
                if let gifData = gifData {
                    GifPopupView(gifData: gifData, modelName: modelName)
                }
            }
        }
    }
    
    func downloadGIF(){
        guard let gifURL = URL(string: "http://10.0.6.82:8080/download/" + (modelName as NSString).deletingPathExtension + ".gif") else {
                    print("Invalid URL")
                    return
                }

                URLSession.shared.dataTask(with: gifURL) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error downloading GIF:", error?.localizedDescription ?? "")
                        return
                    }

                    DispatchQueue.main.async {
                        print("Finishing Download gif file.")
                        gifData = data
                        isShowingPopup = true
                    }
                }.resume()
    }
    
    func shareButton() {
        let url = URL(string: modelName)
        let activityController = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        _ = windowScene?.windows.first
        
        windowScene?.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
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
        
        guard let currentDirectoryURL = getDocumentsDirectory() else {
            print("Failed to access the current directory")
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
        
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: currentDirectoryURL, includingPropertiesForKeys: nil)
            
            let Names = fileURLs.map { $0.lastPathComponent }
            
            for fileName in Names {
                if fileName.hasSuffix("obj") {
                    fileNames.append(fileName)
                }
            }
        } catch {
            print("Error while listing file names in the current directory: \(error.localizedDescription)")
        }
    }


    
    // Helper function to get the documents directory URL
    func getDocumentsDirectory() -> URL? {
        let fileManager = FileManager.default
        
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
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
