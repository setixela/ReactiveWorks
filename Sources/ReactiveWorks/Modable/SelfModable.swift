//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 10.08.2022.
//

func log(_ object: Any, _ slf: Any? = nil) {
   print("\n ##### (\((slf != nil) ? slf! : "")) |-> \(object)\n")
}

import Foundation

public protocol WeakSelfied: InitProtocol {
   associatedtype WeakSelf
}

public protocol SelfModable: AnyObject {
   associatedtype SelfMode: WeakSelfied

   var selfMode: SelfMode { get set }
}

public extension SelfModable {
   @discardableResult
   func onModeChanged(_ keypath: WritableKeyPath<SelfMode, Event<SelfMode.WeakSelf?>?>,
                      _ block: Event<SelfMode.WeakSelf?>?) -> Self where SelfMode.WeakSelf == Self
   {
      selfMode[keyPath: keypath] = block

      return self
   }

   @discardableResult
   func setMode(_ keypath: KeyPath<SelfMode, Event<SelfMode.WeakSelf?>?>) -> Self where SelfMode.WeakSelf == Self {
      let mode = self.selfMode[keyPath: keypath]
      DispatchQueue.main.async { [weak self] in
         mode?(self)
      }

      return self
   }
}

public protocol ModeProtocol: InitProtocol {}

public protocol Modable: AnyObject {
   associatedtype Mode: ModeProtocol

   var modes: Mode { get set }
}

public extension Modable {
   @discardableResult
   func onModeChanged(_ keypath: WritableKeyPath<Mode, GenericClosure<Void>?>,
                      _ block:  GenericClosure<Void>?) -> Self
   {
      modes[keyPath: keypath] = block

      return self
   }

   @discardableResult
   func setMode(_ keypath: KeyPath<Mode, GenericClosure<Void>?>) -> Self {
      let mode = self.modes[keyPath: keypath]
      DispatchQueue.main.async {
         mode?(())
      }

      return self
   }
}


