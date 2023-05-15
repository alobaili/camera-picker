//
//  CameraPicker.swift
//
//
//  Created by Abdulaziz Alobaili on 12/05/2023.
//

import SwiftUI
import AVFoundation

public struct CameraPicker<Label>: View where Label: View {
    let label: Label
    @Binding var selection: [CameraPickerItem]
    @State private var imagePickerControllerError: LocalizedError?

    @State private var showingCamera = false

    let allowesEditing: Bool
    let videoQuality: UIImagePickerController.QualityType

    public init(
        selection: Binding<[CameraPickerItem]>,
        allowsEditing: Bool = false,
        videoQuality: UIImagePickerController.QualityType = .typeMedium,
        @ViewBuilder label: () -> Label
    ) {
        _selection = selection
        self.label = label()
        self.allowesEditing = allowsEditing
        self.videoQuality = videoQuality
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
                    videoQuality: videoQuality
                )
                .ignoresSafeArea()
            }
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
