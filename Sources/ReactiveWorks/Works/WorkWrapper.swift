//
//  WorkWrapper.swift
//
//
//  Created by Aleksandr Solovyev on 02.01.2023.
//

import Foundation

// MARK: - Erasing Work Wrapper

public protocol WorkWrappperProtocol {
   func perform<AnyType>(_ value: AnyType)
   func cancel()
}

public struct WorkWrappper<T, U>: WorkWrappperProtocol where T: Any, U: Any {
   public func perform<AnyType>(_ value: AnyType) where AnyType: Any {
      guard
         let value = value as? T
      else {
         print("Lambda payloads not conform: {\(value)} is not {\(T.self)}")
         fatalError()
      }

      if let onQueue = work.doQueue {
         onQueue.async {
            work.doSync(value)
         }
      } else {
         work.doSync(value)
      }
   }

   public func cancel() {
      work.cancel()
   }

   let work: Work<T, U>

   init(work: Work<T, U>) {
      self.work = work
   }
}
