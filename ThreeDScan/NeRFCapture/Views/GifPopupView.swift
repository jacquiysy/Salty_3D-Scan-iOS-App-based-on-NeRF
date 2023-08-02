//
//  GifPopupView.swift
//  ThreeDScan
//
//  Created by jacquiy on 8/2/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString("<html><body style='background:transparent;'>< img src='data:image/gif;base64,\(data.base64EncodedString())' style='width:100%;height:auto;margin:0 auto;'/></body></html>", baseURL: nil)
    }
}


struct GifPopupView: View {
    var gifData: Data
    @State var showShareSheet = false

    var body: some View {
        VStack {
            Image(uiImage: UIImage(data: gifData)!)
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
//                .animated()
            
//            WebView(data: gifData)
            Button("Share GIF") {
                shareGIF()
            }
            .padding()
//            Button(action: {
//                self.showShareSheet = true
//            }) {
//                Text("Share")
//            }
//            .sheet(isPresented: $showShareSheet) {
//                ActivityViewController(activityItems: [gifData])
//            }

        }
    }

    func shareGIF() {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent("temp.gif")

        do {
            try gifData.write(to: fileURL)
            let documentInteractionController = UIDocumentInteractionController(url: fileURL)
            documentInteractionController.presentOptionsMenu(from: CGRect.zero, in: UIApplication.shared.windows.first?.rootViewController?.view ?? UIView(), animated: true)
        } catch {
            print("Error saving or sharing GIF:", error.localizedDescription)
        }
    }
//    struct ActivityViewController: UIViewControllerRepresentable {
//        let activityItems: [Any]
//        let applicationActivities: [UIActivity]? = nil
//
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
//            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
//            return controller
//        }
//
//        func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
//        }
//    }

}
