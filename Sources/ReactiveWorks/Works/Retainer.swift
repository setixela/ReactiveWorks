//
//  Retainer.swift
//  
//
//  Created by Aleksandr Solovyev on 02.01.2023.
//

import Foundation

public final class Retainer {
   private lazy var retained: Set<AnyHashable> = []

   public init() {}

   public func retain(_ some: AnyHashable) {
      cleanIfNeeded()
      retained.update(with: some)
      if retained.count > 100 {
         assertionFailure()
      }
   }

   public func cleanAll() {
      retained.removeAll()
   }

   deinit {
      retained.removeAll()
   }

   private func cleanIfNeeded() {
      let cleaned = retained.filter {
         let isFinished = ($0 as? Finishible)?.isFinished == true
         return !isFinished
      }

      retained = cleaned
   }
}
