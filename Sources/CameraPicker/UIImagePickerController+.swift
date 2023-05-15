//
//  File.swift
//  
//
//  Created by Abdulaziz Alobaili on 15/05/2023.
//

import UIKit

// This is a fix for not being able to drag the crop area of the captired image to the endges.
// Copy-pasted from this Stack Overflow answer: https://stackoverflow.com/a/72559127/10654098
extension UIImagePickerController {
    open override var childForStatusBarHidden: UIViewController? { nil }

    open override var prefersStatusBarHidden: Bool { true }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        fixCannotMoveEditingBox()
    }

    private func fixCannotMoveEditingBox() {
        if let cropView, let scrollView, scrollView.contentOffset.y == 0 {
            let top = cropView.frame.minY + view.frame.minY
            let bottom = scrollView.frame.height - cropView.frame.height - top
            scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)

            var offset: CGFloat = 0

            if scrollView.contentSize.height > scrollView.contentSize.width {
                offset = 0.5 * (scrollView.contentSize.height - scrollView.contentSize.width)
            }

            scrollView.contentOffset = CGPoint(x: 0, y: -top + offset)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.fixCannotMoveEditingBox()
        }
    }

    private var cropView: UIView? { findCropView(from: view) }

    private var scrollView: UIScrollView? { findScrollView(from: view) }

    private func findCropView(from view: UIView) -> UIView? {
        let width = UIScreen.main.bounds.width
        let size = view.bounds.size

        if width == size.height, width == size.height {
            return view
        }

        for view in view.subviews {
            if let cropView = findCropView(from: view) {
                return cropView
            }
        }

        return nil
    }

    private func findScrollView(from view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }

        for view in view.subviews {
            if let scrollView = findScrollView(from: view) {
                return scrollView
            }
        }

        return nil
    }
}
