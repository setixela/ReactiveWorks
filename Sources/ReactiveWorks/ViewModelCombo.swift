////
////  File.swift
////  
////
////  Created by Aleksandr Solovyev on 06.08.2022.
////
//
//import UIKit
//
//public protocol Combo {
////   var mainModel: Self { get }
//}
//
//public extension Combo {
//   var mainModel: Self { self }
//}
//
//public protocol ComboRight: Combo {
//
//}
//
//public protocol ComboLeft: Combo {
//
//}
//
//public protocol ComboLeftRight: ComboLeft, ComboRight {
//
//}
//
//public protocol LeftExtender: Combo {
//   associatedtype LeftModel: ViewModelProtocol
//
//   var leftModel: LeftModel { get }
//}
//
//public extension LeftExtender {
//   func set(leftModel: (LeftModel) -> Void) -> Self {
//      leftModel(self.leftModel)
//      return self
//   }
//}
//
//public protocol RightExtender: Combo {
//   associatedtype RightModel: ViewModelProtocol
//
//   var rightModel: RightModel { get }
//}
//
//public extension RightExtender {
//   func set(rightModel: (RightModel) -> Void) -> Self {
//      rightModel(self.rightModel)
//      return self
//   }
//}
//
//public extension ViewModelProtocol where Self: LeftExtender {
//   var uiView: UIView {
//      print("uiview")
//      let stackView = UIStackView()
//      stackView.addArrangedSubview(self.leftModel.uiView)
//      stackView.addArrangedSubview(self.uiView)
//      return stackView
//   }
//}
//
////
//public extension ViewModelProtocol where Self: RightExtender {
//   var uiView: UIView {
//      print("uiview")
//      let stackView = UIStackView()
//      stackView.addArrangedSubview(self.rightModel.uiView)
//      stackView.addArrangedSubview(self.uiView)
//      return stackView
//   }
//}
//
////
//public extension ViewModelProtocol where Self: RightExtender, Self: LeftExtender {
//   var uiView: UIView {
//      print("uiview")
//      let stackView = UIStackView()
//      stackView.addArrangedSubview(self.leftModel.uiView)
//      stackView.addArrangedSubview(self.uiView)
//      stackView.addArrangedSubview(self.rightModel.uiView)
//      return stackView
//   }
//}
