//
//  Work+Queue.swift
//
//
//  Created by Aleksandr Solovyev on 31.12.2022.
//

import Foundation

public extension Work {
   @discardableResult
   func finishQueue(_ queue: DispatchQueue) -> Self {
      self.finishQueue = queue
      return self
   }
}
