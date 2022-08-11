//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 10.08.2022.
//

import Foundation

public protocol WeakSelfied: InitProtocol {
   associatedtype WeakSelf
}

public protocol Modable: AnyObject {
   associatedtype Mode: WeakSelfied

   var modes: Mode { get set }
}

public extension Modable {
   @discardableResult
   func onModeChanged(_ keypath: WritableKeyPath<Mode, Event<Mode.WeakSelf?>?>,
                      _ block: Event<Mode.WeakSelf?>?) -> Self where Mode.WeakSelf == Self
   {
      modes[keyPath: keypath] = block

      return self
   }

   @discardableResult
   func setMode(_ keypath: KeyPath<Mode, Event<Mode.WeakSelf?>?>) -> Self where Mode.WeakSelf == Self {
      DispatchQueue.main.async { [weak self] in
         self?.modes[keyPath: keypath]?(self)
      }

      return self
   }
}
