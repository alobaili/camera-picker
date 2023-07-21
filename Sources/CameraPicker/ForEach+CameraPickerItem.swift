//
//  File.swift
//  
//
//  Created by Abdulaziz Alobaili on 02/06/2023.
//

import SwiftUI

public extension ForEach where ID == UUID, Content: View, Data.Element == any CameraPickerItem {
    init(_ data: Data, @ViewBuilder content: @escaping (any CameraPickerItem) -> Content) {
        self.init(data, id: \.id, content: content)
    }
}
