//
//  CameraPicker.swift
//
//
//  Created by Abdulaziz Alobaili on 12/05/2023.
//

import SwiftUI
import AVFoundation

public extension CameraPicker {
    typealias Device = UIImagePickerController.CameraDevice
    typealias CaptureMode = UIImagePickerController.CameraCaptureMode
    typealias FlashMode = UIImagePickerController.CameraFlashMode
}

public struct CameraPicker<Label>: View where Label: View {
    let label: Label
    @Binding var selection: [any CameraPickerItem]
    @State private var imagePickerControllerError: LocalizedError?
    @State private var showingCamera = false

    let allowesEditing: Bool
    let preferredMediaTypes: Set<CameraPickerMediaType>
    let cameraDevice: Device
    let preferredCaptureMode: CaptureMode
    let flashMode: FlashMode

    public init(
        selection: Binding<[any CameraPickerItem]>,
        allowsEditing: Bool = false,
        preferredMediaTypes: Set<CameraPickerMediaType> = [.image],
        cameraDevice: Device = .rear,
        preferredCaptureMode: CaptureMode = .photo,
        flashMode: FlashMode = .auto,
        @ViewBuilder label: () -> Label
    ) {
        _selection = selection
        self.label = label()
        self.allowesEditing = allowsEditing
        self.preferredMediaTypes = preferredMediaTypes
        self.cameraDevice = cameraDevice
        self.preferredCaptureMode = preferredCaptureMode
        self.flashMode = flashMode
    }

    public var body: some View {
        Button {
            showingCamera = true
        } label: {
            label
        }
        .fullScreenCover(isPresented: $showingCamera) {
            if let imagePickerControllerError {
                VStack {
                    Text(imagePickerControllerError.localizedDescription)

                    Button("Close") {
                        showingCamera = false
                    }
                }
            } else {
                UIImagePickerControllerRepresentation(
                    selection: $selection,
                    error: $imagePickerControllerError,
                    allowsEditing: allowesEditing,
                    preferredMediaTypes: preferredMediaTypes,
                    cameraDevice: cameraDevice,
                    preferredCaptureMode: preferredCaptureMode,
                    flashMode: flashMode
                )
                .ignoresSafeArea()
            }
        }
    }
}

extension CameraPicker {
    private static func arrayBindingFrom(
        optionalBinding: Binding<(any CameraPickerItem)?>
    ) -> Binding<[any CameraPickerItem]> {
        Binding<[any CameraPickerItem]> {
            if let item = optionalBinding.wrappedValue {
                return [item]
            } else {
                return []
            }
        } set: { newItems in
            if let item = newItems.first {
                optionalBinding.wrappedValue = item
            } else {
                optionalBinding.wrappedValue = nil
            }
        }
    }

    public init(
        selection: Binding<(any CameraPickerItem)?>,
        allowsEditing: Bool = false,
        preferredMediaTypes: Set<CameraPickerMediaType> = [.image],
        cameraDevice: Device = .rear,
        preferredCaptureMode: CaptureMode = .photo,
        flashMode: FlashMode = .auto,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            selection: Self.arrayBindingFrom(optionalBinding: selection),
            allowsEditing: allowsEditing,
            preferredMediaTypes: preferredMediaTypes,
            cameraDevice: cameraDevice,
            preferredCaptureMode: preferredCaptureMode,
            flashMode: flashMode,
            label: label
        )
    }
}

extension CameraPicker where Label == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<(any CameraPickerItem)?>,
        allowsEditing: Bool = false,
        preferredMediaTypes: Set<CameraPickerMediaType> = [.image],
        cameraDevice: Device = .rear,
        preferredCaptureMode: CaptureMode = .photo,
        flashMode: FlashMode = .auto
    ) {
        self.init(
            selection: selection,
            allowsEditing: allowsEditing,
            preferredMediaTypes: preferredMediaTypes,
            cameraDevice: cameraDevice,
            preferredCaptureMode: preferredCaptureMode,
            flashMode: flashMode
        ) {
            Text(titleKey)
        }
    }

    public init<S>(
        _ title: S,
        selection: Binding<(any CameraPickerItem)?>,
        allowsEditing: Bool = false,
        preferredMediaTypes: Set<CameraPickerMediaType> = [.image],
        cameraDevice: Device = .rear,
        preferredCaptureMode: CaptureMode = .photo,
        flashMode: FlashMode = .auto
    ) where S: StringProtocol {
        self.init(
            selection: selection,
            allowsEditing: allowsEditing,
            preferredMediaTypes: preferredMediaTypes,
            cameraDevice: cameraDevice,
            preferredCaptureMode: preferredCaptureMode,
            flashMode: flashMode
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<[any CameraPickerItem]>,
        allowsEditing: Bool = false,
        preferredMediaTypes: Set<CameraPickerMediaType> = [.image],
        cameraDevice: Device = .rear,
        preferredCaptureMode: CaptureMode = .photo,
        flashMode: FlashMode = .auto
    ) {
        self.init(
            selection: selection,
            allowsEditing: allowsEditing,
            preferredMediaTypes: preferredMediaTypes,
            cameraDevice: cameraDevice,
            preferredCaptureMode: preferredCaptureMode,
            flashMode: flashMode
        ) {
            Text(titleKey)
        }
    }

    public init<S>(
        _ title: S,
        selection: Binding<[any CameraPickerItem]>,
        allowsEditing: Bool = false,
        preferredMediaTypes: Set<CameraPickerMediaType> = [.image],
        cameraDevice: Device = .rear,
        preferredCaptureMode: CaptureMode = .photo,
        flashMode: FlashMode = .auto
    ) where S: StringProtocol {
        self.init(
            selection: selection,
            allowsEditing: allowsEditing,
            preferredMediaTypes: preferredMediaTypes,
            cameraDevice: cameraDevice,
            preferredCaptureMode: preferredCaptureMode,
            flashMode: flashMode
        ) {
            Text(title)
        }
    }
}

struct CameraPicker_Previews: PreviewProvider {
    static var previews: some View {
        CameraPicker(selection: .constant([])) {
            Text("Example Text View Label")
        }
    }
}
