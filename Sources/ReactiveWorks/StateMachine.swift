//
//  StateMachine.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 16.08.2022.
//

import Foundation

public protocol StateMachine: AnyObject {
   associatedtype ModelState

   func setState(_ state: ModelState)
}

public protocol StateMachine2: StateMachine {
   associatedtype ModelState2

   func setState2(_ state: ModelState2)
}

public extension StateMachine2 {
   var stateDelegate2: (ModelState2) -> Void {
      let fun: (ModelState2) -> Void = { [weak self] in
         self?.setState2($0)
      }

      return fun
   }
}

public extension StateMachine {
   var stateDelegate: (ModelState) -> Void {
      let fun: (ModelState) -> Void = { [weak self] in
         self?.setState($0)
      }

      return fun
   }

   func debug(_ state: ModelState) {
      log(state, self)
   }
}
