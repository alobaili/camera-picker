# CameraPicker

A camera picker for SwiftUI.

## 🚧 **Still Under Development** 🚧

If you want to give it a try, currently it uses `UIImagePickerController` under the hood and
handles taking a single still image without cropping.

Add this package as a dependency from the main branch to your iOS project. Make sure to add the
NSCameraUsageDescription key to your projects Info.plist file.

Basic example code:
```swift
import SwiftUI
import AVKit
import CameraPicker

struct ContentView: View {
    @State private var pickedItems: [CameraPickerItem] = []
    
    var body: some View {
        VStack {
            CameraPicker(selection: $pickedItems) {
                Text("Capture an image")
            }

            ForEach(pickedItems) { item in
                switch item {
                    case .image(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .video(let player):
                        VideoPlayer(player: player)
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
