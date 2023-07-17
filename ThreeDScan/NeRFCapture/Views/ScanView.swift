//
//  ScanView.swift
//  
//
//  Created by jacquiy on 7/12/23.
//

import SwiftUI

struct ScanView: View {
    var viewModel: ARViewModel?
    var contentView: ContentView?
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
//
//    let window = UIWindow(frame: UIScreen.main.bounds)
//    window.rootViewController = UIHostingController(rootView: contentView)
//    self.window = window
//    self.view = contentView
//    window.makeKeyAndVisible()
    var body: some View {
//        nerfcapture
        VStack{
            delegate.view
        }
//        Text("Test")
    }
    
}
