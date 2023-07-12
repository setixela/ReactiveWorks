//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 08.11.2022.
//

import Foundation

public extension Eventable {
   @discardableResult
   func on<T>(_ eventKey: Key<T>) -> Work<Void, T> {
      let hash = eventKey.hashValue
      let work = Work<Void, T>()
      work.type = .event
      //
      let closure: Event<T> = { value in
         work.doSyncWithResult(value)
      }
      //
      events[hash] = Lambda(lambda: closure)

      return work
   }
}

public extension Eventable2 {
    @discardableResult
    func on<T>(_ eventKey: Key2<T>) -> Work<Void, T> {
        let hash = eventKey.hashValue
        let work = Work<Void, T>()
        work.type = .event
        //
        let closure: Event<T> = { value in
            work.doSyncWithResult(value)
        }
        //
        events2[hash] = Lambda(lambda: closure)
        
        return work
    }
}

public extension Eventable3 {
   @discardableResult
   func on<T>(_ eventKey: Key3<T>) -> Work<Void, T> {
      let hash = eventKey.hashValue
      let work = Work<Void, T>()
      work.type = .event
      //
      let closure: Event<T> = { value in
         work.doSyncWithResult(value)
      }
      //
      events3[hash] = Lambda(lambda: closure)

      return work
   }
}

public extension Work {
   @discardableResult
   func sendAsyncEvent(_ result: Out) -> Self {
      DispatchQueue.main.async { [weak self] in
         self?.doSyncWithResult(result)
      }
      return self
   }
   
   @discardableResult
   func sendAsyncEvent() -> Self where Out == Void {
      sendAsyncEvent(())
      return self
   }
}
