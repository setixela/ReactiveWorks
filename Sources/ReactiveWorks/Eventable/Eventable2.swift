//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 03.02.2023.
//

public protocol Eventable2: Eventable {
   associatedtype Events2: InitProtocol
   
   typealias Key2<T> = KeyPath<Events2, T?>
   
   var events2: EventsStore { get set }
}

public extension Eventable2 {
   @discardableResult
   func on<T>(_ eventKey: Key2<T>, _ closure: @escaping Event<T>) -> Self {
      let hash = eventKey.hashValue
      let lambda = Lambda(lambda: closure)
      events2[hash] = lambda
      return self
   }
   
   @discardableResult
   func on<S: AnyObject>(_ eventKey: Key2<Void>, _ slf: S?, _ closure: @escaping (S) -> Void) -> Self {
      let hash = eventKey.hashValue
      let clos = { [weak slf] in
         guard let slf = slf else { return }
         closure(slf)
      }
      let lambda = Lambda(lambda: clos)
      events2[hash] = lambda
      return self
   }
   
   @discardableResult
   func on<T, S: AnyObject>(_ eventKey: Key2<T>, _ slf: S?, _ closure: @escaping (S, T) -> Void) -> Self {
      let hash = eventKey.hashValue
      let clos = { [weak slf] (value: T) in
         guard let slf = slf else { return }
         closure(slf, value)
      }
      let lambda = Lambda(lambda: clos)
      events2[hash] = lambda
      return self
   }
   
   @discardableResult
   func send(_ eventKey: Key2<Void>) -> Self {
      let hash = eventKey.hashValue
      guard
         let lambda = events2[hash]
      else {
         return self
      }
      
      lambda?.perform(())
      
      return self
   }
   
   @discardableResult
   func send<T>(_ eventKey: Key2<T>, _ payload: T) -> Self {
      let hash = eventKey.hashValue
      guard
         let lambda = events2[hash]
      else {
         return self
      }
      
      lambda?.perform(payload)
      
      return self
   }
   
   func hasSubcriberForEvent<T>(_ eventKey: Key2<T>) -> Bool {
      events2[eventKey.hashValue] != nil
   }
}
