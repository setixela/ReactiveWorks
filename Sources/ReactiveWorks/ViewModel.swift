//
//  ViewModelProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 28.05.2022.
//

import UIKit

// Associatedtype View Erasing protocol
public protocol UIViewModel: ModelProtocol {
   var uiView: UIView { get }

   func start()
}

public protocol ViewModelProtocol: UIViewModel {
   associatedtype View: UIView

   var view: View { get }

   var autostartedView: View? { get set }
   var isAutoreleaseView: Bool { get set }

   init()
}

public extension ViewModelProtocol where Self: ComboRight {
   var uiView: UIView {
      print("uiview")
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.addArrangedSubview(uiView)
      stackView.addArrangedSubview(rightModel.uiView)
      return stackView
   }
}


public extension ViewModelProtocol {
   var uiView: UIView {
      if isAutoreleaseView, let readyView = autostartedView {
         autostartedView = nil
         return readyView
      }
      return view
   }
}

open class BaseViewModel<View: UIView>: NSObject, ViewModelProtocol {
   private weak var weakView: View?

   // will be cleaned after presenting view
   public var autostartedView: View?
   public var isAutoreleaseView = false

   public var view: View {
      if let view = weakView {
         return view
      } else {
         let view = View(frame: .zero)
         weakView = view
         autostartedView = view
         start()
         return view
      }
   }

//   public var uiView: UIView {
//      if isAutoreleaseView, let readyView = autostartedView {
//         autostartedView = nil
//         return readyView
//      }
//      return view
//   }

   override public required init() {
      super.init()
   }

   public init(isAutoreleaseView: Bool) {
      super.init()
      self.isAutoreleaseView = isAutoreleaseView
   }

   open func start() {}

   public func setupView(_ closure: GenericClosure<View>) {
      closure(view)
   }
}

public extension UIViewModel where Self: Stateable {
   init(state: State) {
      self.init(state)
   }
}
