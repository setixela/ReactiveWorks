//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 14.08.2022.
//

import Foundation

public protocol WorkBasket {
   var retainer: Retainer { get }
}

public extension WorkBasket {
   func retainedWork<U: UseCaseProtocol>(_ keypath: KeyPath<Self, U>) -> Work<U.In, U.Out> {
      let useCase = self[keyPath: keypath]
      let work = useCase.work
      retainer.retain(work)
      return work
   }
}
