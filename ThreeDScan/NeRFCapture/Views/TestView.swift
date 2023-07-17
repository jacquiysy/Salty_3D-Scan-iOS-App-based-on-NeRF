//
//  DisplayView.swift
//  
//
//  Created by jacquiy on 7/12/23.
//

import SwiftUI
import SceneKit
import Foundation

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}


struct TestView: View {
    
    @State private var image = UIImage()
    @State private var showSheet = false

    var body: some View {
            VStack {
                    Image(uiImage: self.image)
                  .resizable()
                  .cornerRadius(50)
//                  .frame(width: 500, height: 500)
                  .background(Color.black.opacity(0.2))
                  .aspectRatio(contentMode: .fill)

         Text("Select Model")
             .font(.headline)
             .frame(maxWidth: .infinity)
             .frame(height: 50)
//             .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.262745098, green: 0.0862745098, blue: 0.8588235294, alpha: 1)), Color(#colorLiteral(red: 0.5647058824, green: 0.462745098, blue: 0.9058823529, alpha: 1))]), startPoint: .top, endPoint: .bottom))
//             .cornerRadius(16)
//             .foregroundColor(.white)
            .padding(.horizontal, 20)
            .onTapGesture {
            showSheet = true
            }
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showSheet) {
                    // Pick an image from the photo library:
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)

                    //  If you wish to take a photo from camera instead:
                    // ImagePicker(sourceType: .camera, selectedImage: self.$image)
            }
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
