//
//  ARViewModel.swift
//  NeRFCapture
//
//  Created by Jad Abou-Chakra on 13/7/2022.
//

import Foundation
import Zip
import Combine
import ARKit
import RealityKit
import CoreMotion

enum AppError : Error {
    case projectAlreadyExists
    case manifestInitializationFailed
}

class ARViewModel : NSObject, ARSessionDelegate, ObservableObject {
    private var motionManager: CMMotionManager
    private var lastAcceleration: CMAcceleration?

    @Published var isMovingTooFast: Bool = false
    @Published var appState = AppState()
    var session: ARSession? = nil
    var arView: ARView? = nil
//    let frameSubject = PassthroughSubject<ARFrame, Never>()
    var cancellables = Set<AnyCancellable>()
    let datasetWriter: DatasetWriter
    let ddsWriter: DDSWriter
    
    init(datasetWriter: DatasetWriter, ddsWriter: DDSWriter) {
        motionManager = CMMotionManager()
        self.datasetWriter = datasetWriter
        self.ddsWriter = ddsWriter
        super.init()
        startMonitoringMotion()
        self.setupObservers()
        self.ddsWriter.setupDDS()


    }
    
    
    private func startMonitoringMotion() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (accelerometerData, error) in
                guard let acceleration = accelerometerData?.acceleration else { return }
                self?.checkMovementSpeed(acceleration: acceleration)
            }
        }
    }

    private func checkMovementSpeed(acceleration: CMAcceleration) {
        if let lastAcceleration = lastAcceleration {
            let speed = sqrt(pow(acceleration.x - lastAcceleration.x, 2) +
                             pow(acceleration.y - lastAcceleration.y, 2) +
                             pow(acceleration.z - lastAcceleration.z, 2))
            if speed > 0.5 { // Adjust this threshold as needed
                // print("Movement too fast!")
                isMovingTooFast = true
            } else {
                isMovingTooFast = false
            }
        }
        lastAcceleration = acceleration
    }
    
    func setupObservers() {
        datasetWriter.$writerState.sink {x in self.appState.writerState = x} .store(in: &cancellables)
        datasetWriter.$currentFrameCounter.sink { x in self.appState.numFrames = x }.store(in: &cancellables)
        ddsWriter.$peers.sink {x in self.appState.ddsPeers = UInt32(x)}.store(in: &cancellables)
        
        $appState
            .map(\.appMode)
            .prepend(appState.appMode)
            .removeDuplicates()
            .sink { x in
                switch x {
                case .Offline:
//                    self.appState.stream = false
                    print("Changed to offline")
                case .Online:
                    print("Changed to online")
                }
            }
            .store(in: &cancellables)
        
//        frameSubject.throttle(for: 0.5, scheduler: RunLoop.main, latest: true).sink {
//            f in
//            if self.appState.stream && self.appState.appMode == .Online {
//                self.ddsWriter.writeFrameToTopic(frame: f)
//            }
//        }.store(in: &cancellables)
    }
    
    
    func createARConfiguration() -> ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
            // Activate sceneDepth
            configuration.frameSemantics = .sceneDepth
        }
        return configuration
    }
    
    func resetWorldOrigin() {
        session?.pause()
        let config = createARConfiguration()
        session?.run(config, options: [.resetTracking])
    }
    
    
    func session(
        _ session: ARSession,
        didUpdate frame: ARFrame
    ) {
//        frameSubject.send(frame)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        self.appState.trackingState = trackingStateToString(camera.trackingState)
    }
}
