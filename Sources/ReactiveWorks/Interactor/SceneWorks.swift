//
//  SceneWorks.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 11.08.2022.
//

import Foundation

public protocol SceneWorks: InitProtocol, Assetable {
   associatedtype TempStorage

   var tempStorage: TempStorage { get set }
}

public extension SceneWorks {
   @discardableResult
   func doAsync<In, Out>(_ keypath: KeyPath<Self, Work<In, Out>>) -> Work<In, Out> {
      let work = self[keyPath: keypath]
      return work
   }
}

public protocol WorkableModel {
   associatedtype Works: SceneWorks

   var works: Works { get }
}
