# CameraPicker

A camera picker for SwiftUI.

## 🚧 **Still Under Development** 🚧
Currently this package still uses 0 as the major version number, which means the public interface
is subject to discussions and design changes. Breaking changes between releases should be expected.

Feedback through Issues or Discussions is always welcome, and I will try to respond as soon as I can.

If you want to give it a try, currently it uses `UIImagePickerController` under the hood and
handles taking a single still image or video and saving the picked photo into the photo library.

Add this package as a dependency from the main branch or the latest tag to your iOS project. 
Make sure to add the `NSCameraUsageDescription` key to your app's Info.plist file. For capturing video,
You need to add the `NSMicrophoneUsageDescription`, and for saving the captured image or video, add the
`NSPhotoLibraryAddUsageDescription`.

Basic example code:
```swift
import SwiftUI
import AVKit
import CameraPicker

struct ContentView: View {
    @State private var pickedItem: (any CameraPickerItem)?

    var body: some View {
        VStack {
            CameraPicker("Capture an Image", selection: $pickedItem, preferredMediaTypes: [.image, .movie()])

            switch pickedItem {
                case let pickedItem as ImageCameraPickerItem:
                    pickedItem.mediaType
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                case let pickedItem as MovieCameraPickerItem:
                    VideoPlayer(player: pickedItem.mediaType)
                        .frame(width: 400, height: 400)
                default:
                    EmptyView()
            }
        }
    }
}
```
The above code displays a button. When tapped, it will open the camera and show controls for
picking an image or video. Once an image or a video is captured, the
picker will dismiss and the image or the video will be displayed in the `VStack`.

To save a `CameraPickerItem` to the photo library, just call `save()`:
```swift
Button("Save") {
    Task {
        try? await pickedItem?.save()
    }
}
```
