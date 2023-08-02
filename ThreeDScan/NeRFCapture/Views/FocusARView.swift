//
//  copy directly from https://github.com/maxxfrazer/FocusEntity/blob/main/FocusEntity-Example/FocusEntity-Example/FocusARView.swift
//  ModelPickerApp
//
//  Created by hgp on 1/13/21.
//

import RealityKit
import FocusEntity
import Combine
import ARKit
import UIKit

class FocusARView: ARView {
  var focusEntity: FocusEntity?
  required init(frame frameRect: CGRect) {
    super.init(frame: frameRect)
    self.setupConfig()
    self.focusEntity = FocusEntity(on: self, focus: .classic)
  }

  func setupConfig() {
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = [.horizontal, .vertical]
    config.environmentTexturing = .automatic
    
    if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
        config.sceneReconstruction = .mesh
    }
    
    self.session.run(config)
  }

  @objc required dynamic init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FocusARView: FocusEntityDelegate {
  func toTrackingState() {
    print("tracking")
  }
  func toInitializingState() {
    print("initializing")
  }
}
