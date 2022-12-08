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
   var isAutoreleaseView: Bool { get set }
}

public protocol ViewModelProtocol: UIViewModel {
   associatedtype View: UIView

   var view: View { get }

   var autostartedView: View? { get set }

   init()
}

public extension ViewModelProtocol {
   init(_ closure: GenericClosure<Self>) {
      self.init()

      closure(self)
   }
}

public extension UIViewModel where Self: ViewModelProtocol {
   var uiView: UIView {
      let vuew = myView()
      if Config.isDebugView {
         vuew.backgroundColor = .random
      }
      return myView()
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

   deinit {
      autostartedView = nil
   }

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

private extension UIColor {
   static var random: UIColor {
      .init(hue: .random(in: 0 ... 1), saturation: 0.33, brightness: 1, alpha: 0.4)
   }
}
