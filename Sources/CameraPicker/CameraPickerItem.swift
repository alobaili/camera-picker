//
//  CameraPickerItem.swift
//  
//
//  Created by Abdulaziz Alobaili on 12/05/2023.
//

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
