//
//  ArView.swift
//  
//
//  Created by jacquiy on 7/12/23.
//


import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ArView: View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    var models: [Model] = getModelFilenames()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement)
            
            if isPlacementEnabled {
                PlacementButtonView(
                    isPlacementEnabled: $isPlacementEnabled,
                    selectedModel: $selectedModel,
                    modelConfirmedForPlacement: $modelConfirmedForPlacement
                )
            } else {
                ModelPickerView(isPlacementEnabled: $isPlacementEnabled, selectedModel: $selectedModel, models: models)
            }
        }
    }
}

func getModelFilenames() -> [Model] {
        // Dynamically get our model filenames
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModels: [Model] = []
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        
        return availableModels
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?

    func makeUIView(context: Context) -> ARView {
        
        let arView = FocusARView(frame: .zero)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = modelConfirmedForPlacement {
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene - \(model.name)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: Unable to load modelEntity for \(model.name)")
            }

            DispatchQueue.main.async {
                modelConfirmedForPlacement = nil
            }
        }
    }
    
}

#if DEBUG
struct ArView_Previews: PreviewProvider {
    static var previews: some View {
        TDScanView()
    }
}
#endif
