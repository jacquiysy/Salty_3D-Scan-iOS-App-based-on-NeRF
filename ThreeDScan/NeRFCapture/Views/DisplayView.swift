//
//  DisplayView.swift
//  
//
//  Created by jacquiy on 7/12/23.
//

import SwiftUI
import SceneKit
import Foundation


struct DisplayView: View {
    
    var modelName : String
    var body: some View {
        VStack{
                ThreeDViewer(product:modelName).frame(width: UIScreen.main.bounds.width)
        }
    }
}


struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(modelName: "Airpods_Gen2.usdz")
    }
}
