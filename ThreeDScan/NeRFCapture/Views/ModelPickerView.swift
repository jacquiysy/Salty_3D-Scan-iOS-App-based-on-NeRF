//
//  ModelPickerView.swift
//  ModelPickerApp
//
//  Created by hgp on 1/13/21.
//

import SwiftUI

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0..<self.models.count) { index in
                    Button(action: {
                        print("DEBUG: Selected model with name: \(self.models[index])")
                        
                        selectedModel = models[index]
                        
                        isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
    
}

//struct ModelPickerView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        ModelPickerView(isPlacementEnabled: .constant(false), selectedModel: .constant(nil), models: ["fender_stratocaster", "teapot"])
//    }
//}
