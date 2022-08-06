////
////  File.swift
////
////
////  Created by Aleksandr Solovyev on 06.08.2022.
////

import UIKit

//public protocol Combo {}
//
//public extension Combo {
//   var mainModel: Self { self }
//}
//
//public protocol ComboRight: Combo {
//   associatedtype RightModel: ViewModelProtocol
//
//   var rightModel: RightModel { get }
//}
//
//public extension ComboRight {
//   func setRight(_ closure: (RightModel) -> Void) -> Self {
//      closure(rightModel)
//      return self
//   }
//}
//
//public extension UIViewModel where Self: ComboRight {
//   var uiView: UIView {
//      print("uiview")
//      let stackView = UIStackView()
//      stackView.axis = .horizontal
//      stackView.addArrangedSubview(uiView)
//      stackView.addArrangedSubview(rightModel.uiView)
//      return stackView
//   }
//}
