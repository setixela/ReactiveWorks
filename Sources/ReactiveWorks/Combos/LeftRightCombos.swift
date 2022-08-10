//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 07.08.2022.
//

import Foundation

// MARK: - Combo

public protocol Combo {
   associatedtype M: UIViewModel

   var mainModel: M { get }
}

public extension Combo {
   var mainModel: Self { self }
}

extension Combo {
   @discardableResult
   func setMain<M: VMP & Stateable>(_ closure: (M) -> Void) -> Self {
      closure(self as! M)
      return self
   }
}

// MARK: - RightModelProtocol

public protocol RightModelProtocol {
   func rightModel() -> UIViewModel
}

extension RightModelProtocol {
   func rightModel() -> UIViewModel {
      fatalError()
   }
}

public protocol Right2ModelProtocol: RightModelProtocol {
   func right2Model() -> UIViewModel
}

extension Right2ModelProtocol {
   func right2Model() -> UIViewModel {
      fatalError()
   }
}

// MARK: - LeftModelProtocol

public protocol LeftModelProtocol {
   func leftModel() -> UIViewModel
}

extension LeftModelProtocol {
   func leftModel() -> UIViewModel {
      fatalError()
   }
}

// MARK: - ComboRight

public protocol ComboRight: Combo, RightModelProtocol {
   associatedtype R: UIViewModel

   var rightModel: R { get }
}

public extension ComboRight {
   func rightModel() -> UIViewModel {
      return rightModel
   }
}

public extension ComboRight {
   @discardableResult
   func setRight(_ closure: (R) -> Void) -> Self {
      closure(rightModel)
      return self
   }
}

//

public protocol ComboRight2: ComboRight, Right2ModelProtocol {
   associatedtype R2: UIViewModel

   var right2Model: R2 { get }
}

public extension ComboRight2 {
   func right2Model() -> UIViewModel {
      return right2Model
   }
}

public extension ComboRight2 {
   @discardableResult
   func setRight2(_ closure: (R2) -> Void) -> Self {
      closure(right2Model)
      return self
   }
}

// MARK: - ComboLeft

public protocol ComboLeft: Combo, LeftModelProtocol {
   associatedtype L: UIViewModel

   var leftModel: L { get }
}

public extension ComboLeft {
   func leftModel() -> UIViewModel {
      return leftModel
   }
}

public extension ComboLeft {
   @discardableResult
   func setLeft(_ closure: (L) -> Void) -> Self {
      closure(leftModel)
      return self
   }
}
