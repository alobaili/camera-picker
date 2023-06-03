//
//  MediaSaver.swift
//  
//
//  Created by Abdulaziz Alobaili on 02/06/2023.
//

import UIKit

final class MediaSaver: NSObject {
    typealias SaveImageContinuation = CheckedContinuation<Void, Error>

    var continuation: SaveImageContinuation?

    func save(_ image: UIImage) async throws {
        try await withCheckedThrowingContinuation { (continuation: SaveImageContinuation) in
            self.continuation = continuation

            UIImageWriteToSavedPhotosAlbum(
                image,
                self,
                #selector(image(_:didFinishSavingWithError:contextInfo:)),
                nil
            )
        }
    }

    @objc func image(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error {
            continuation?.resume(throwing: error)
            return
        } else {
            continuation?.resume()
        }

        continuation = nil
    }
}
