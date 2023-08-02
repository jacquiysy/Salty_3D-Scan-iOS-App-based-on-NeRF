//
//  PlacementButtonView.swift
//  ModelPickerApp
//
//  Created by hgp on 1/13/21.
//

import SwiftUI

struct PlacementButtonView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            // Cancel Button
            Button(action: {
                print("DEBUG: Cancel model placement.")
                
                resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            // Confirm Button
            Button(action: {
                print("DEBUG: model placement confirmed.")
                
                modelConfirmedForPlacement = selectedModel
                
                resetPlacementParameters()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        isPlacementEnabled = false
        selectedModel = nil
    }
}

struct PlacementButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlacementButtonView(isPlacementEnabled: .constant(true), selectedModel: .constant(nil), modelConfirmedForPlacement: .constant(nil))
    }
}
