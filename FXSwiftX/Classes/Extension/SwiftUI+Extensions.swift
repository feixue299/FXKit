//
//  File.swift
//  
//
//  Created by aria on 2022/9/1.
//

import Foundation
import UIKit
import SwiftUI

@available(iOS 13.0, *)
public extension View {

  func onTapGestureForced(
    count: Int = 1,
    perform action: @escaping () -> Void
  ) -> some View {
    self
      .contentShape(Rectangle())
      .onTapGesture(count: count, perform: action)
  }
}

@available(iOS 13.0, *)
public struct UIViewPreview<V: UIView>: UIViewRepresentable {

  public let builder: () -> V

  public init(builder: @escaping () -> V) {
    self.builder = builder
  }

  public func makeUIView(context: Context) -> some UIView { builder() }
  public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

@available(iOS 13.0, *)
public struct UIViewControllerPreview<VC: UIViewController>: UIViewControllerRepresentable {

  public let builder: () -> VC

  public init(builder: @escaping () -> VC) {
    self.builder = builder
  }

  public func makeUIViewController(context: Context) -> VC { builder() }
  public func updateUIViewController(_ uiViewController: VC, context: Context) {}
}


@available(iOS 13.0, *)
public extension Image {
    init(uiImage: UIImage?) {
        if let uiImage {
            self.init(uiImage: uiImage)
        } else {
            self.init(uiImage: UIImage())
        }
    }
}
