//
//  Model.swift
//  ModelPickerApp
//
//  Created by hgp on 1/13/21.
//

import UIKit
import RealityKit
import Combine

class Model {
    var name: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.name = modelName
        
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "3DModels") else {
            print("Error: Unable to find the model file in the 3DModels bundle.")
            return
        }
        print(modelURL)
        guard let path = Bundle.main.path(forResource: "3DModels", ofType: nil) else{return}
        self.cancellable = ModelEntity.loadModelAsync(named: "3DModels/" + modelName)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                print("Unable to load a model due to error \(error)")
            }
            self.cancellable?.cancel()
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
                print("DEBUG: Successfully loaded modelEntity for modelName: \(modelName)")
            })
    }
}
