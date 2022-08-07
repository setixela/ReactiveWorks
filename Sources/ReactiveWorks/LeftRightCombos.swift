//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 07.08.2022.
//

import Foundation

// MARK: - DownModelProtocol

public protocol DownModelProtocol {
   func downModel() -> UIViewModel
}

extension DownModelProtocol {
   func downModel() -> UIViewModel {
      fatalError()
   }
}

// MARK: - TopModelProtocol

public protocol TopModelProtocol {
   func topModel() -> UIViewModel
}

extension TopModelProtocol {
   func topModel() -> UIViewModel {
      fatalError()
   }
}

// MARK: - ComboDown

public protocol ComboDown: Combo, DownModelProtocol {
   associatedtype DownModel: UIViewModel

   var downModel: DownModel { get }
}

public extension ComboDown {
   func downModel() -> UIViewModel {
      return downModel
   }
}

public extension ComboDown {
   func setDown(_ closure: (DownModel) -> Void) -> Self {
      closure(downModel)
      return self
   }
}

// MARK: - ComboTop

public protocol ComboTop: Combo, TopModelProtocol {
   associatedtype TopModel: UIViewModel

   var topModel: TopModel { get }
}

public extension ComboTop {
   func topModel() -> UIViewModel {
      return topModel
   }
}

public extension ComboTop {
   func setTop(_ closure: (TopModel) -> Void) -> Self {
      closure(topModel)
      return self
   }
}
