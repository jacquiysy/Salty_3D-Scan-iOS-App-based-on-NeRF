//
//  GifPopupView.swift
//  ThreeDScan
//
//  Created by jacquiy on 8/2/23.
//

import SwiftUI
import FLAnimatedImage

enum URLType {

  case name(String)
  case url(URL)

  var url: URL? {
    switch self {
      case .name(let name):
        return Bundle.main.url(forResource: name, withExtension: "GIF")
      case .url(let remoteURL):
        return remoteURL
    }

  }

}
struct GIFView: UIViewRepresentable {

    private var type: URLType
    
    init(type: URLType) {
        self.type = type
    }

    func makeUIView(context: Context) -> UIView {
      let view = UIView(frame: .zero)

      view.addSubview(activityIndicator)
      view.addSubview(imageView)

      imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
      imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

      return view
    }

    
    func updateUIView(_ uiView: UIView, context: Context) {

      activityIndicator.startAnimating()

      guard let url = type.url else { return }

      DispatchQueue.global().async {
        if let data = try? Data(contentsOf: url) {
          let image = FLAnimatedImage(animatedGIFData: data)

          DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            imageView.animatedImage = image
          }
        }
      }
    }

    private let imageView: FLAnimatedImageView = {

        let imageView = FLAnimatedImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false

        // UNCOMMENT TO ADD ROUNDING TO YOUR VIEW
//      imageView.layer.cornerRadius = 24

        imageView.layer.masksToBounds = true
        return imageView

    }()

    private let activityIndicator: UIActivityIndicatorView = {

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .systemBlue
        return activityIndicator
    }()

}


struct GifPopupView: View {
    var gifData: Data
    var modelName: String

    var body: some View {
        VStack {
            //            Image(uiImage: UIImage(data: gifData)!)
            //                .resizable()
            //                .scaledToFit()
            //                .frame(width: 500, height: 500)
                GIFView(type: .url(URL(string: "http://10.0.6.82:8080/download/" + (modelName as NSString).deletingPathExtension + ".gif")!))
                Button("Share GIF") {
                    shareGIF()
                }
                .padding()
            }
        }

    func shareGIF() {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent("temp.gif")

        do {
            // Write the GIF data to a temporary file
            try gifData.write(to: fileURL)

            // Create the UIActivityViewController
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

            // Excluded activity types if needed (optional)
            // activityViewController.excludedActivityTypes = [.airDrop, .addToReadingList]

            // Present the UIActivityViewController
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        } catch {
            print("Error saving or sharing GIF:", error.localizedDescription)
        }
    }


}
