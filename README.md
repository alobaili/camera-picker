# CameraPicker

A camera picker for SwiftUI.

## 🚧 **Still Under Development** 🚧
Feedback through Issues or Discussions is always welcome, and I will try to respond as soon as I can.

If you want to give it a try, currently it uses `UIImagePickerController` under the hood and
handles taking a single still image without cropping and saving the picked photo into the photo library.

Add this package as a dependency from the main branch to your iOS project. Make sure to add the
NSCameraUsageDescription key to your projects Info.plist file.

Basic example code:
```swift
import SwiftUI
import AVKit
import CameraPicker

struct ContentView: View {
    @State private var pickedItems: [any CameraPickerItem] = []
    
    var body: some View {
        VStack {
            CameraPicker(selection: $pickedItems) {
                Text("Capture an image")
            }

            ForEach(pickedItems) { item in
                switch item {
                    case let item as ImageCameraPickerItem:
                        item.mediaType
                            .resizable()
                            .scaledToFit()
                    default:
                        EmptyView() // Video Camera Picker Items is still a TODO.
                }
            }
            .frame(width: 100, height: 100)
        }
    }
}
```
The above code displays a button. When tapped, it will open the camera and show controls for
picking an image or video (video capture is still under development). Once an image is captured, the
picker will dismiss and the image will be displayed in the `VStack`.

To save a `CameraPickerItem` to the photo library, just call `save()`:
```swift
Button("Save") {
    Task {
        try? await pickedItem.save()
    }
}
```
