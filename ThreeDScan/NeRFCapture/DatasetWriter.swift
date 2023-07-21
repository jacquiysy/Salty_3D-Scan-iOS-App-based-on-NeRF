//
//  DatasetWriter.swift
//  NeRFCapture
//
//  Created by Jad Abou-Chakra on 11/1/2023.
//

import Foundation
import ARKit
import Zip

extension UIImage {
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}



class DatasetWriter {
    
    enum SessionState {
        case SessionNotStarted
        case SessionStarted
    }
    
    enum ViewState {
        case firstMatch
        case secondMatch
        case noMatch
        case finishedMatch
    }
    
    var manifest = Manifest()
    var projectName = ""
    var projectDir = getDocumentsDirectory()
    var useDepthIfAvailable = true
    var transforms: [[[Float]]] = []
    var threshold: Float = 1.0
    var finshedRound: Int = 0
    
    @Published var currentState: ViewState = .noMatch
    @Published var currentFrameCounter = 0
    @Published var writerState = SessionState.SessionNotStarted
    @Published var baseURL = "http://10.0.6.82:8080/"
    
    
    func projectExists(_ projectDir: URL) -> Bool {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: projectDir.absoluteString, isDirectory: &isDir)
    }
    
    func initializeProject() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYMMddHHmmss"
        projectName = dateFormatter.string(from: Date())
        projectDir = getDocumentsDirectory()
            .appendingPathComponent(projectName)
        if projectExists(projectDir) {
            throw AppError.projectAlreadyExists
        }
        do {
            try FileManager.default.createDirectory(at: projectDir.appendingPathComponent("images"), withIntermediateDirectories: true)
        }
        catch {
            print(error)
        }
        
        manifest = Manifest()
        
        // The first frame will set these properly
        manifest.w = 0
        manifest.h = 0
        
        // These don't matter since every frame will redefine them
        manifest.flX = 1.0
        manifest.flY =  1.0
        manifest.cx =  320
        manifest.cy =  240
        
        manifest.depthIntegerScale = 1.0
        writerState = .SessionStarted
    }
    
    func clean() {
        guard case .SessionStarted = writerState else { return; }
        writerState = .SessionNotStarted
        DispatchQueue.global().async {
            do {
                try FileManager.default.removeItem(at: self.projectDir)
            }
            catch {
                print("Could not cleanup project files")
            }
        }
    }
    
    func finalizeProject(zip: Bool = true, alterName: String = ""){
        writerState = .SessionNotStarted
        let manifest_path = getDocumentsDirectory()
            .appendingPathComponent(projectName)
            .appendingPathComponent("transforms.json")
        writeManifestToPath(path: manifest_path)
        DispatchQueue.global().async {
            do {
                if zip {

                    if alterName == "" {
                        let _ = try Zip.quickZipFiles([self.projectDir], fileName: self.projectName)
                    } else {
                        let _ = try Zip.quickZipFiles([self.projectDir], fileName: alterName)
                    }

                    self.uploadFilesToServer(alterName: alterName)
                }
                try FileManager.default.removeItem(at: self.projectDir)
            }
            catch {
                print("Could not zip")
            }
        }
        currentFrameCounter = 0
    }
    
    func uploadFilesToServer(alterName: String = "") {
        var fileURLs: [URL] = []
        if alterName == "" {
            fileURLs = [self.projectDir.deletingLastPathComponent().appendingPathComponent(projectName + ".zip")]
        } else {
            fileURLs = [self.projectDir.deletingLastPathComponent().appendingPathComponent(alterName + ".zip")]
        }
        

        let serverURL = URL(string: baseURL + "upload")!

        for fileURL in fileURLs {
            let fileName = fileURL.lastPathComponent

            do {
                let fileData = try Data(contentsOf: fileURL)

                let request = NSMutableURLRequest(url: serverURL)
                request.httpMethod = "POST"

                let boundary = "---------------------------14737809831466499882746641449"
                let contentType = "multipart/form-data; boundary=\(boundary)"
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")

                let body = NSMutableData()
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(fileData)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
                body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)

                request.httpBody = body as Data
                
                // TODO: Add uploading failed

                let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        NotificationCenter.default.post(name: NSNotification.Name("Uploading finished"), object:nil)
                    } else if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response: \(responseString ?? "")")
                        NotificationCenter.default.post(name: NSNotification.Name("Uploading finished"), object:nil)
                    }
                }

                task.resume()
            } catch {
                print("Error reading file: \(error)")
                NotificationCenter.default.post(name: NSNotification.Name("Uploading finished"), object:nil)
            }
        }

    }
    
    func getCurrentFrameName() -> String {
        let frameName = String(currentFrameCounter)
        return frameName
    }
    
    func getFrameMetadata(_ frame: ARFrame, withDepth: Bool = false) -> Manifest.Frame {
        let frameName = getCurrentFrameName()
        let filePath = "images/\(frameName)"
        let depthPath = "images/\(frameName).depth.png"
        let manifest_frame = Manifest.Frame(
            filePath: filePath,
            depthPath: withDepth ? depthPath : nil,
            transformMatrix: arrayFromTransform(frame.camera.transform),
            timestamp: frame.timestamp,
            flX:  frame.camera.intrinsics[0, 0],
            flY:  frame.camera.intrinsics[1, 1],
            cx:  frame.camera.intrinsics[2, 0],
            cy:  frame.camera.intrinsics[2, 1],
            w: Int(frame.camera.imageResolution.width),
            h: Int(frame.camera.imageResolution.height)
        )
        return manifest_frame
    }
    
    func writeManifestToPath(path: URL) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .withoutEscapingSlashes
        if let encoded = try? encoder.encode(manifest) {
            do {
                try encoded.write(to: path)
            } catch {
                print(error)
            }
        }
    }
    
    func writeFrameToDisk(frame: ARFrame, useDepthIfAvailable: Bool = true) {
        let frameName =  "\(getCurrentFrameName()).png"
        let depthFrameName =  "\(getCurrentFrameName()).depth.png"
        let baseDir = projectDir
            .appendingPathComponent("images")
        let fileName = baseDir
            .appendingPathComponent(frameName)
        let depthFileName = baseDir
            .appendingPathComponent(depthFrameName)
        
        if manifest.w == 0 {
            manifest.w = Int(frame.camera.imageResolution.width)
            manifest.h = Int(frame.camera.imageResolution.height)
            manifest.flX =  frame.camera.intrinsics[0, 0]
            manifest.flY =  frame.camera.intrinsics[1, 1]
            manifest.cx =  frame.camera.intrinsics[2, 0]
            manifest.cy =  frame.camera.intrinsics[2, 1]
        }
        
        let useDepth = frame.sceneDepth != nil && useDepthIfAvailable
        
        let frameMetadata = getFrameMetadata(frame, withDepth: useDepth)
        let rgbBuffer = pixelBufferToUIImage(pixelBuffer: frame.capturedImage)
        let depthBuffer = useDepth ? pixelBufferToUIImage(pixelBuffer: frame.sceneDepth!.depthMap).resizeImageTo(size:  frame.camera.imageResolution) : nil
        
        DispatchQueue.global().async {
            do {
                let rgbData = rgbBuffer.pngData()
                try rgbData?.write(to: fileName)
                if useDepth {
                    let depthData = depthBuffer!.pngData()
                    try depthData?.write(to: depthFileName)
                }
            }
            catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.manifest.frames.append(frameMetadata)
                self.addTransforms(frameMetadata.transformMatrix)
            }
        }
        currentFrameCounter += 1
    }
    
    func addTransforms(_ transform: [[Float]]) -> ViewState {
        transforms.append(transform)
        let xyz = transform.map{ $0.reduce(0, +) }
        for (i, storedTransform) in zip(transforms.indices, transforms) {
            let xyzStored = storedTransform.map{ $0.reduce(0, +) }
            if abs(xyz[0] + xyzStored[0]) <= threshold && abs(xyz[1] - xyzStored[1]) <= threshold && abs(xyz[2] + xyzStored[2]) <= threshold && currentState != .firstMatch{
                currentState = .firstMatch
                return currentState
            } else if abs(xyz[0] - xyzStored[0]) <= threshold && abs(xyz[1] - xyzStored[1]) <= threshold && abs(xyz[2] - xyzStored[2]) <= threshold && transforms.count >= 3 && i == 0{
                if finshedRound >= 3 {
                    currentState = .finishedMatch
                } else {
                    currentState = .secondMatch
                }
                finshedRound += 1
                transforms.removeAll()
                return currentState
            }
        }
        if transforms.count == 1 {
            currentState = .noMatch
        }
        return currentState
    }
    
    
}
