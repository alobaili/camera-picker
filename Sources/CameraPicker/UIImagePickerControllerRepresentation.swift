//
//  UIImagePickerControllerRepresentation.swift
//  
//
//  Created by Abdulaziz Alobaili on 14/05/2023.
//

import SwiftUI

struct UIImagePickerControllerRepresentation: UIViewControllerRepresentable {
    @Binding var selection: [CameraPickerItem]
    @Binding var error: LocalizedError?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator

        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            error = ImagePickerControllerError.cameraUnavailable
        }

        imagePickerController.sourceType = .camera

        // TODO: Check if movie is available and handle that case appropriately.
        if let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            imagePickerController.mediaTypes = availableMediaTypes
        }

        // TODO: Use cameraOverlayView and set showsCameraControls to false to add the ability to take multiple images.

        // TODO: Handle allowsEditing.

        return imagePickerController
    }

    func updateUIViewController(_ imagePickerController: UIImagePickerController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension UIImagePickerControllerRepresentation {
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: UIImagePickerControllerRepresentation

        init(parent: UIImagePickerControllerRepresentation) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            // TODO: Handle movies.
            // TODO: Handle edited images.
            let originalImage = info[.originalImage] as! UIImage
            parent.selection = [.image(Image(uiImage: originalImage))]
            picker.dismiss(animated: true)
        }
    }
}

extension UIImagePickerControllerRepresentation {
    enum ImagePickerControllerError: LocalizedError {
        case cameraUnavailable
    }
}
