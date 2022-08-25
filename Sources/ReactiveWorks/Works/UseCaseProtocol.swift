//
//  UseCaseProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import Foundation

public protocol UseCaseProtocol {
   associatedtype In
   associatedtype Out

   typealias WRK = Work<In, Out>

   var work: WRK { get }
}

public extension UseCaseProtocol {
   func retainedWork(_ retainer: Retainer) -> Work<In, Out> {
      let work = self.work
      retainer.retain(work)
      return work
   }
}
