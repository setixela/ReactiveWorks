//
//  DispatchQueue+Queues.swift
//  
//
//  Created by Aleksandr Solovyev on 01.01.2023.
//

import Foundation

public extension DispatchQueue {

   // Serial

   static var serial: DispatchQueue {
      DispatchQueue(label: "Serial default", qos: .default)
   }

   static var serialBackground: DispatchQueue {
      DispatchQueue(label: "Serial background", qos: .background)
   }

   static var serialUtility: DispatchQueue {
      DispatchQueue(label: "Serial utility", qos: .utility)
   }

   static var serialInitiated: DispatchQueue {
      DispatchQueue(label: "Serial userInitiated", qos: .userInitiated)
   }


   static var serialInteractive: DispatchQueue {
      DispatchQueue(label: "Serial userInteractive", qos: .userInteractive)
   }

   // Concurent

   static var concurent: DispatchQueue{
      DispatchQueue(label: "Concurrent default", qos: .default, attributes: .concurrent)
   }

   static var concurentBackground: DispatchQueue {
      DispatchQueue(label: "Concurrent background", qos: .background, attributes: .concurrent)
   }

   static var concurentUtility: DispatchQueue {
      DispatchQueue(label: "Concurrent Utility", qos: .utility, attributes: .concurrent)
   }

   static var concurentInteractive: DispatchQueue {
      DispatchQueue(label: "Concurrent userInteractive", qos: .userInteractive, attributes: .concurrent)
   }

   static var concurentInitiated: DispatchQueue {
      DispatchQueue(label: "Concurrent userInitiated", qos: .userInitiated, attributes: .concurrent)
   }

   // Global

   static var global: DispatchQueue {
      DispatchQueue.global(qos: .default)
   }

   static var globalBackground: DispatchQueue {
      DispatchQueue.global(qos: .background)
   }

   static var globalUtility: DispatchQueue {
      DispatchQueue.global(qos: .utility)
   }

   static var globalInteractive: DispatchQueue {
      DispatchQueue.global(qos: .userInteractive)
   }

   static var globalInitiated: DispatchQueue {
      DispatchQueue.global(qos: .userInitiated)
   }
}
