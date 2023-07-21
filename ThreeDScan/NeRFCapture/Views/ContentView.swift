//
//  ContentView.swift
//  NeRFCapture
//
//  Created by Jad Abou-Chakra on 13/7/2022.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView : View {
    @StateObject private var viewModel: ARViewModel
    @State private var showSheet: Bool = false
    @State private var showNameEntry = false
    @State private var showGenerateModel = false
    @State private var showDownloadModel = false
    @State private var showFinish = false
    @State private var enteredName = ""
    
    init(viewModel vm: ARViewModel) {
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack{
            if showNameEntry {
                NameEntryView(enteredName: $enteredName, showNameEntry: $showNameEntry, showGenerateModel: $showGenerateModel, viewModel: viewModel)
            } else if showGenerateModel {
                GenerateModelView(viewModel: viewModel, modelName: $enteredName, showGenerateModel: $showGenerateModel, showDownloadModel: $showDownloadModel)
            } else if showDownloadModel{
                DownloadModelView(viewModel: viewModel, modelName: $enteredName, showGenerateModel: $showGenerateModel, showDownloadModel: $showDownloadModel)
            } else {
                ZStack(alignment: .topTrailing) {
                    ARViewContainer(viewModel).edgesIgnoringSafeArea(.all)
                    VStack() {
                        ZStack() {
                            HStack() {
                                //                            Button() {
                                //                                showSheet.toggle()
                                //                            } label: {
                                //                                Image(systemName: "gearshape.fill")
                                //                                    .imageScale(.large)
                                //                            }
                                //                            .padding(.leading, 16)
                                //                            .buttonStyle(.borderless)
                                //                            .sheet(isPresented: $showSheet) {
                                //                                VStack() {
                                //                                    Text("Settings")
                                //                                    Spacer()
                                //                                }
                                //                                .presentationDetents([.medium])
                                //                            }
                                //                            Spacer()
                            }
                            HStack() {
                                Spacer()
                                Picker("Mode", selection: $viewModel.appState.appMode) {
                                    Text("Online").tag(AppMode.Online)
                                    Text("Offline").tag(AppMode.Offline)
                                }
                                .frame(maxWidth: 200)
                                .padding(0)
                                .pickerStyle(.segmented)
                                .disabled(viewModel.appState.writerState
                                          != .SessionNotStarted)
                                
                                Spacer()
                            }
                        }.padding(8)
                        HStack() {
                            Spacer()
                            
                            VStack(alignment:.leading) {
                                Text("\(viewModel.appState.trackingState)")
                                if case .Online = viewModel.appState.appMode {
                                    Text("\(viewModel.appState.ddsPeers) Connection(s)")
                                }
                                if case .Offline = viewModel.appState.appMode {
                                    if case .SessionStarted = viewModel.appState.writerState {
                                        if viewModel.datasetWriter.currentState == .noMatch {
                                            Text("\(viewModel.datasetWriter.currentFrameCounter) Frames")
                                            Text("Gradually turn around and take several images")
                                        } else if viewModel.datasetWriter.currentState == .firstMatch {
                                            Text("\(viewModel.datasetWriter.currentFrameCounter) Frames")
                                            Text("Turn back from the other direction and take images")
                                        } else if viewModel.datasetWriter.currentState == .secondMatch {
                                            Text("\(viewModel.datasetWriter.currentFrameCounter) Frames")
                                            Text("Move your phone vertically and take another round of view.")
                                        } else if viewModel.datasetWriter.currentState == .finishedMatch {
                                            Text("\(viewModel.datasetWriter.currentFrameCounter) Frames")
                                            Text("Enough views to train a model. You can also take an extra round.")
                                        }
                                    }
                                }
                                
                                if viewModel.appState.supportsDepth {
                                    Text("Depth Supported")
                                }
                            }.padding()
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        if case .Online = viewModel.appState.appMode {
                            Spacer()
                            Button(action: {
                                viewModel.resetWorldOrigin()
                            }) {
                                Text("Reset")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            Button(action: {
                                if let frame = viewModel.session?.currentFrame {
                                    viewModel.ddsWriter.writeFrameToTopic(frame: frame)
                                }
                            }) {
                                Text("Send")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                        }
                        if case .Offline = viewModel.appState.appMode {
                            if viewModel.appState.writerState == .SessionNotStarted {
                                Spacer()
                                
                                Button(action: {
                                    viewModel.resetWorldOrigin()
                                }) {
                                    Text("Reset")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 5)
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                
                                Button(action: {
                                    do {
                                        try viewModel.datasetWriter.initializeProject()
                                    }
                                    catch {
                                        print("\(error)")
                                    }
                                }) {
                                    Text("Start")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 5)
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                            }
                            
                            if viewModel.appState.writerState == .SessionStarted {
                                Spacer()
                                Button(action: {
                                    showNameEntry = true
                                }) {
                                    Text("End")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 5)
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                Button(action: {
                                    if let frame = viewModel.session?.currentFrame {
                                        viewModel.datasetWriter.writeFrameToDisk(frame: frame)
                                        
                                    }
                                }) {
                                    Text("Save Frame")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 5)
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                            }
                        }
                    }
                    .padding()
                }
                .preferredColorScheme(.light)
            }
        }
    }
}

struct NameEntryView: View {
    @Binding var enteredName: String
    @Binding var showNameEntry: Bool
    @Binding var showGenerateModel: Bool
    var viewModel: ARViewModel
    
    
    var body: some View {
        VStack {
            Text("Enter Model Name")
                .font(.title)
                .padding()
            
            TextField("Name", text: $enteredName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Submit") {
                self.viewModel.datasetWriter.finalizeProject(alterName: enteredName)
                showNameEntry = false
                showGenerateModel = true
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct GenerateModelView: View {
    var viewModel: ARViewModel
    @State var asyncProcessFinished = false
    @Binding var modelName: String
    @Binding var showGenerateModel: Bool
    @Binding var showDownloadModel: Bool
    
    
    var body: some View {
        VStack {
            if asyncProcessFinished {
                Text("Generate Model")
                    .font(.title)
                    .padding()
                
                Button("Generate Model") {
                    // Perform GET request to the server
                    performGetRequest()
                    showGenerateModel = false
                    showDownloadModel = true
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Text("Uploading Images")
                    .font(.title)
                    .padding()
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Uploading finished"), object: nil, queue: nil) { notification in
                asyncProcessFinished = true
            }
        }
    }
    
    
    func performGetRequest() {
        guard let url = URL(string: viewModel.datasetWriter.baseURL + "launch/" + modelName) else {
            print("Invalid URL")
            NotificationCenter.default.post(name: NSNotification.Name("Generating finished"), object:nil)
            return
        }
        
        print(url)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                NotificationCenter.default.post(name: NSNotification.Name("Generating finished"), object:nil)
                return
            }
            
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    // Process the received data (jsonString) as needed
                    print("Received data: \(jsonString)")
                    NotificationCenter.default.post(name: NSNotification.Name("Generating finished"), object:nil)
                }
            }
        }
        .resume()
    }
}

struct DownloadModelView: View {
    var viewModel: ARViewModel
    @State var generatingFinished = false
    @Binding var modelName: String
    @Binding var showGenerateModel: Bool
    @Binding var showDownloadModel: Bool
    
    
    var body: some View {
        VStack {
            if generatingFinished {
                Text("Download Model")
                    .font(.title)
                    .padding()
                
                Button("Download Model") {
                    // Perform GET request to the server
                    performGetRequest()
                    showDownloadModel = false
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Text("Generating Model")
                    .font(.title)
                    .padding()
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Generating finished"), object: nil, queue: nil) { notification in
                generatingFinished = true
            }
        }
    }
    
    
    func performGetRequest() {
        guard let url = URL(string: viewModel.datasetWriter.baseURL + "download/" + modelName + ".obj") else {
            print("Invalid URL")
            return
        }
        print(url)
        print(modelName)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    // Process the received data (jsonString) as needed
                    print("Received data: \(jsonString)")
                }
                saveOBJFile(data: data)
            }
        }
        .resume()
    }
    
    // Function to save the .obj file locally
    func saveOBJFile(data: Data) {
        // Specify the file name and file URL for saving the .obj file
        let fileName = modelName + ".obj"
        
        guard let fileURL = getDocumentsDirectory()?.appendingPathComponent(fileName) else {
            print("Failed to create file URL")
            return
        }
        
        do {
            // Write the data to the file URL
            try data.write(to: fileURL)
            
            print("File saved at: \(fileURL)")
        } catch {
            print("Error while saving file: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL? {
        let fileManager = FileManager.default
        
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }


}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ARViewModel(datasetWriter: DatasetWriter(), ddsWriter: DDSWriter()))
            .previewInterfaceOrientation(.portrait)
    }
}
#endif
