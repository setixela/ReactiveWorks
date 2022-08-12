//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 12.08.2022.
//

import Foundation

public protocol VMWrapper: AnyObject, InitProtocol {
   associatedtype VM: VMP

   var subModel: VM { get set }
}

public extension VMWrapper where Self: VMP {
   init(_ wrapped: VM) {
      self.init()

      subModel = wrapped
   }
}
