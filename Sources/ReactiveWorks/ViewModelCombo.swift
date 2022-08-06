////
////  File.swift
////
////
////  Created by Aleksandr Solovyev on 06.08.2022.
////

import UIKit

public protocol Combo {
   var uiView: UIView { get }
}

public extension Combo {
   var mainModel: Self { self }
}

public protocol ComboRight: Combo {
   associatedtype RightModel: ViewModelProtocol

   var rightModel: RightModel { get }
}

public extension ComboRight {
   func setRight(_ closure: (RightModel) -> Void) -> Self {
      closure(rightModel)
      return self
   }
}

public extension ViewModelProtocol where Self: ComboRight {
   var uiView: UIView {
      print("uiview")
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.addArrangedSubview(self.uiView)
      stackView.addArrangedSubview(rightModel.uiView)
      print("exe")
      return stackView
   }
}
