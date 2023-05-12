import SwiftUI
import AVFoundation

public enum CameraPickerItem {
    case image(Image)
    case video(AVPlayer)
}

extension CameraPickerItem: Identifiable {
    public var id: UUID {
        UUID()
    }
}

public struct CameraPicker<Label>: View where Label: View {
    let label: Label
    @Binding var selection: [CameraPickerItem]

    @State private var showingCamera = false

    public init(
        selection: Binding<[CameraPickerItem]>,
        @ViewBuilder label: () -> Label
    ) {
        _selection = selection
        self.label = label()
    }

    public var body: some View {
        Button {
            showingCamera = true
        } label: {
            label
        }
        .fullScreenCover(isPresented: $showingCamera) {
            Text("Camera Here")

            Button("Close") {
                showingCamera = false
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
