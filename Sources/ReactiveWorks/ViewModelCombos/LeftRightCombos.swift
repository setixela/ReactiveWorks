//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 07.08.2022.
//

import Foundation

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
   associatedtype RightModel: UIViewModel

   var rightModel: RightModel { get }
}

public extension ComboRight {
   func rightModel() -> UIViewModel {
      return rightModel
   }
}

public extension ComboRight {
   @discardableResult
   func setRight(_ closure: (RightModel) -> Void) -> Self {
      closure(rightModel)
      return self
   }
}

//

public protocol ComboRight2: ComboRight, Right2ModelProtocol {
   var right2Model: RightModel { get }
}

public extension ComboRight2 {
   func right2Model() -> UIViewModel {
      return right2Model
   }
}

public extension ComboRight2 {
   @discardableResult
   func setRight2(_ closure: (RightModel) -> Void) -> Self {
      closure(right2Model)
      return self
   }
}

// MARK: - ComboLeft

public protocol ComboLeft: Combo, LeftModelProtocol {
   associatedtype LeftModel: UIViewModel

   var leftModel: LeftModel { get }
}

public extension ComboLeft {
   func leftModel() -> UIViewModel {
      return leftModel
   }
}

public extension ComboLeft {
   @discardableResult
   func setLeft(_ closure: (LeftModel) -> Void) -> Self {
      closure(leftModel)
      return self
   }
}
