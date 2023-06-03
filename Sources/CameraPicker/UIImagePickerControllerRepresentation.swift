//
//  UIImagePickerControllerRepresentation.swift
//  
//
//  Created by Abdulaziz Alobaili on 14/05/2023.
//

import SwiftUI
import UniformTypeIdentifiers

public enum CameraPickerMediaType: Hashable {
    case image
    case movie(
        quality: UIImagePickerController.QualityType = .typeMedium,
        maximumDuration: TimeInterval = 600
    )

    fileprivate var utTypeIdentifier: String {
        switch self {
            case .image: return UTType.image.identifier
            case .movie: return UTType.movie.identifier
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(utTypeIdentifier)
    }
}

struct UIImagePickerControllerRepresentation: UIViewControllerRepresentable {
    @Binding var selection: [any CameraPickerItem]
    @Binding var error: LocalizedError?
    let allowsEditing: Bool
    let preferredMediaTypes: Set<CameraPickerMediaType>
    let cameraDevice: UIImagePickerController.CameraDevice
    let captureMode: UIImagePickerController.CameraCaptureMode
    let flashMode: UIImagePickerController.CameraFlashMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator

        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            error = ImagePickerControllerError.cameraUnavailable
        }

        imagePickerController.sourceType = .camera

        if let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            let availableMediaTypesSet = Set(availableMediaTypes)
            let preferredMediaTypesSet = Set(preferredMediaTypes.map(\.utTypeIdentifier))
            let intersection = availableMediaTypesSet.intersection(preferredMediaTypesSet)
            imagePickerController.mediaTypes = Array(intersection)
        }

        for case .movie(let quality, let maximumDuration) in preferredMediaTypes {
            imagePickerController.videoQuality = quality
            imagePickerController.videoMaximumDuration = maximumDuration
        }

        imagePickerController.allowsEditing = false
        imagePickerController.cameraDevice = cameraDevice
        imagePickerController.cameraCaptureMode = captureMode
        imagePickerController.cameraFlashMode = flashMode

        // TODO: Use cameraOverlayView and set showsCameraControls to false to add the ability to take multiple images.

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

            if let editedImage = info[.editedImage] as? UIImage {
                let image = Image(uiImage: editedImage)
                let imageCameraPickerItem = ImageCameraPickerItem(
                    mediaType: image,
                    underlyingMediaType: editedImage
                )
                parent.selection = [imageCameraPickerItem]
                picker.dismiss(animated: true)
                return
            }

            let originalImage = info[.originalImage] as! UIImage
            let image = Image(uiImage: originalImage)
            let imageCameraPickerItem = ImageCameraPickerItem(mediaType: image, underlyingMediaType: originalImage)
            parent.selection = [imageCameraPickerItem]
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

extension UIImagePickerControllerRepresentation {
    enum ImagePickerControllerError: LocalizedError {
        case cameraUnavailable
    }
}
