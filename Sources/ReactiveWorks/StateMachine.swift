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

   @discardableResult
   func setStates(_ states: ModelState...) -> Self
}

public protocol StateMachine2: StateMachine {
   associatedtype ModelState2

   func setState2(_ state: ModelState2)

   @discardableResult
   func setStates2(_ states: ModelState2...) -> Self
}

public extension StateMachine {
   var stateDelegate: (ModelState) -> Void {
      let fun: (ModelState) -> Void = { [weak self] in
         self?.setState($0)
      }

      return fun
   }

   @discardableResult
   func setStates(_ states: ModelState...) -> Self {
      states.forEach {
         setState($0)
      }
      return self
   }

   func setState(_ state: ModelState) {
      setStates(state)
   }
}

public extension StateMachine2 {
   var stateDelegate2: (ModelState2) -> Void {
      let fun: (ModelState2) -> Void = { [weak self] in
         self?.setState2($0)
      }

      return fun
   }

   @discardableResult
   func setStates2(_ states: ModelState2...) -> Self {
      states.forEach {
         setState2($0)
      }
      return self
   }

   func setState2(_ state: ModelState2) {
      setStates2(state)
   }
}
