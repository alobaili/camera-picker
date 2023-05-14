//
//  UIImagePickerControllerRepresentation.swift
//  
//
//  Created by Abdulaziz Alobaili on 14/05/2023.
//

import SwiftUI

struct UIImagePickerControllerRepresentation: UIViewControllerRepresentable {
    @Binding var error: LocalizedError?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            error = ImagePickerControllerError.cameraUnavailable
        }

        imagePickerController.sourceType = .camera

        // TODO: Check if movie is available and handle that case appropriately.
        if let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            imagePickerController.mediaTypes = availableMediaTypes
        }

        // TODO: See if it makes sense to use cameraOverlayView either above system UI or replacing it.

        return imagePickerController
    }

    func updateUIViewController(_ imagePickerController: UIImagePickerController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension UIImagePickerControllerRepresentation {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: UIImagePickerControllerRepresentation

        init(parent: UIImagePickerControllerRepresentation) {
            self.parent = parent
        }
    }
}

extension UIImagePickerControllerRepresentation {
    enum ImagePickerControllerError: LocalizedError {
        case cameraUnavailable
    }
}
