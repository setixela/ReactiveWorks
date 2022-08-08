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

public protocol Down2ModelProtocol: DownModelProtocol {
   func down2Model() -> UIViewModel
}

extension Down2ModelProtocol {
   func down2Model() -> UIViewModel {
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
   @discardableResult
   func setDown(_ closure: (DownModel) -> Void) -> Self {
      closure(downModel)
      return self
   }
}

///

public protocol ComboDown2: ComboDown, Down2ModelProtocol {
   associatedtype Down2Model: UIViewModel

   var down2Model: Down2Model { get }
}

public extension ComboDown2 {
   func down2Model() -> UIViewModel {
      return down2Model
   }
}

public extension ComboDown2 {
   @discardableResult
   func setDown2(_ closure: (Down2Model) -> Void) -> Self {
      closure(down2Model)
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
   @discardableResult
   func setTop(_ closure: (TopModel) -> Void) -> Self {
      closure(topModel)
      return self
   }
}
