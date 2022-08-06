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
}

public protocol ViewModelProtocol: UIViewModel {
   associatedtype View: UIView

   var view: View { get }

   init()
}

open class BaseViewModel<View: UIView>: NSObject, ViewModelProtocol {
   private weak var weakView: View?

   // will be cleaned after presenting view
   private var autostartedView: View?
   private var isAutoreleaseView = false

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

   public var uiView: UIView {
      if isAutoreleaseView, let readyView = autostartedView {
         autostartedView = nil
         return readyView
      }
      return view
   }

   public override required init() {
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
