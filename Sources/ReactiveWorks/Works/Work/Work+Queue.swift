//
//  Work+Queue.swift
//
//
//  Created by Aleksandr Solovyev on 31.12.2022.
//

import Foundation

public extension Work {
   @discardableResult
   func finishOnQueue(_ queue: DispatchQueue) -> Self {
      finishQueue = queue
      return self
   }

   @discardableResult
   func doOnQueue(_ queue: DispatchQueue) -> Self {
      doQueue = queue
      return self
   }
}
