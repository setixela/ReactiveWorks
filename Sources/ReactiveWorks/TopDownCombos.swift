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
   func setRight(_ closure: (RightModel) -> Void) -> Self {
      closure(rightModel)
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
   func setLeft(_ closure: (LeftModel) -> Void) -> Self {
      closure(leftModel)
      return self
   }
}
