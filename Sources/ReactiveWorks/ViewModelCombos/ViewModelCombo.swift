////
////  File.swift
////
////
////  Created by Aleksandr Solovyev on 06.08.2022.
////

import UIKit

// MARK: - Combo

public protocol Combo {}

public extension Combo {
   var mainModel: Self { self }
}

// MARK: - ViewModelProtocol + Combos

extension ViewModelProtocol {
   func myView() -> UIView {
      var horStack: UIStackView?
      var vertStack: UIStackView?

      if let model = self as? RightModelProtocol {
         horStack = UIStackView()
         horStack?.addArrangedSubview(view)
         horStack?.addArrangedSubview(model.rightModel().uiView)
      }

      if let model = self as? LeftModelProtocol {
         horStack = horStack ?? {
            let stk = UIStackView()
            stk.addArrangedSubview(view)
            return stk
         }()
         horStack?.insertArrangedSubview(model.leftModel().uiView, at: 0)
      }

      if let model = self as? DownModelProtocol {
         vertStack = UIStackView()
         if let horStack = horStack {
            vertStack?.addArrangedSubview(horStack)
            vertStack?.addArrangedSubview(model.downModel().uiView)
         } else {
            vertStack?.addArrangedSubview(view)
            vertStack?.addArrangedSubview(model.downModel().uiView)
         }
      }

      if let model = self as? TopModelProtocol {
         vertStack = vertStack ?? {
            let stk = UIStackView()
            if let horStack = horStack {
               stk.addArrangedSubview(model.topModel().uiView)
               stk.addArrangedSubview(horStack)
            } else {
               stk.addArrangedSubview(model.topModel().uiView)
               stk.addArrangedSubview(view)
            }
            return stk
         }()
         vertStack?.insertArrangedSubview(model.topModel().uiView, at: 0)
      }

      guard horStack != nil || vertStack != nil else {
         return autoreleased()
      }

      horStack?.axis = .horizontal

      if let vertStack = vertStack {
         vertStack.axis = .vertical
         return vertStack
      }

      return horStack ?? autoreleased()
   }

   private func autoreleased() -> UIView {
      if isAutoreleaseView, let readyView = autostartedView {
         autostartedView = nil
         return readyView
      }
      return view
   }
}
