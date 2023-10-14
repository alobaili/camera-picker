//
//  UIImagePickerControllerRepresentation.swift
//  
//
//  Created by Abdulaziz Alobaili on 14/05/2023.
//

import SwiftUI
import AVFoundation
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

// TODO: Move this to a separate file.
class MyImagePickerController: UIImagePickerController {
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        let camPreviewView = children[0].children[0].children[0].view!
        camPreviewView.translatesAutoresizingMaskIntoConstraints = false
        camPreviewView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            camPreviewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            camPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            camPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            camPreviewView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.33)
        ])
    }
}

// TODO: Move this to a separate file.
struct CameraOverlayView: View {
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Button(action: action) {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 88, height: 88)
            }
            .padding(4)
            .background(
                Circle()
                    .stroke(lineWidth: 4)
            )
        }
    }
}

#Preview {
    CameraOverlayView(action: {})
}

struct UIImagePickerControllerRepresentation: UIViewControllerRepresentable {
    @Binding var selection: [any CameraPickerItem]
    @Binding var error: LocalizedError?
    let allowsEditing: Bool
    let preferredMediaTypes: Set<CameraPickerMediaType>
    let cameraDevice: UIImagePickerController.CameraDevice
    let preferredCaptureMode: UIImagePickerController.CameraCaptureMode
    let flashMode: UIImagePickerController.CameraFlashMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = MyImagePickerController()
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

        imagePickerController.allowsEditing = allowsEditing
        imagePickerController.cameraDevice = cameraDevice

        if let availableCaptureModes =  UIImagePickerController.availableCaptureModes(for: cameraDevice) {
            let availableCaptureModesSet = Set(availableCaptureModes)
            let preferredCaptureModesSet = Set([preferredCaptureMode.rawValue as NSNumber])
            let intersection = availableCaptureModesSet.intersection(preferredCaptureModesSet)

            let mediaTypes = imagePickerController.mediaTypes
            if mediaTypes == [CameraPickerMediaType.movie().utTypeIdentifier] {
                imagePickerController.cameraCaptureMode = .video
            } else if mediaTypes == [CameraPickerMediaType.image.utTypeIdentifier] {
                imagePickerController.cameraCaptureMode = .photo
            } else {
                if let resolvedCameraCaptureModeRawValue = intersection.first as? Int {
                    let resolvedCameraCaptureMode: UIImagePickerController.CameraCaptureMode?
                    resolvedCameraCaptureMode = .init(rawValue: resolvedCameraCaptureModeRawValue)
                    imagePickerController.cameraCaptureMode = resolvedCameraCaptureMode ?? .photo
                }
            }
        }

        imagePickerController.cameraFlashMode = flashMode

        // TODO: Use cameraOverlayView and set showsCameraControls to false to add the ability to take multiple images.
        imagePickerController.showsCameraControls = false

        let cameraOverlayView = CameraOverlayView {
            imagePickerController.takePicture()
        }

        let hostingController = UIHostingController(rootView: cameraOverlayView)
        let hostingControllerView = hostingController.view!
        hostingControllerView.backgroundColor = .clear

        // This hardcoding of the frame presents a UI bug where the overlay is
        // displayed behind the iOS Home indicator.
        // TODO: Use Auto Layout instead.
        hostingControllerView.frame = (imagePickerController.cameraOverlayView?.frame)!
        imagePickerController.cameraOverlayView = hostingControllerView

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
            guard
                let mediaTypeString = info[.mediaType] as? String,
                let mediaType = UTType(mediaTypeString)
            else {
                return
            }

            if mediaType == .image {
                let editedImage = info[.editedImage] as? UIImage
                let originalImage = info[.originalImage] as? UIImage

                if let imageToHandle = editedImage ?? originalImage {
                    let image = Image(uiImage: imageToHandle)
                    let imageCameraPickerItem = ImageCameraPickerItem(
                        mediaType: image,
                        underlyingMediaType: imageToHandle
                    )

                    parent.selection = [imageCameraPickerItem]
                }
            } else if mediaType == .movie {
                if let movieURL = info[.mediaURL] as? URL {
                    let player = AVPlayer(url: movieURL)

                    let movieCameraPickerItem = MovieCameraPickerItem(
                        mediaType: player,
                        underlyingMediaType: movieURL
                    )

                    parent.selection = [movieCameraPickerItem]
                }
            }


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
