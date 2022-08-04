//
//  AsyncWorker.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 30.07.2022.
//

import Foundation

public protocol WorkerProtocol {
   associatedtype In
   associatedtype Out

   typealias Wrk = Work<In, Out>

   func doAsync(work: Wrk)
}

public extension WorkerProtocol {
   var work: Wrk {
      let work = Wrk()
      work.closure = doAsync(work:)
      return work
   }

   func doAsync(_ input: In) -> Wrk {
      let work = Wrk(input: input)
      work.closure = doAsync(work:)
      DispatchQueue.main.async {
         work.closure?(work)
      }
      return work
   }

   func doSync(_ input: In) -> Wrk {
      let work = Wrk(input: input)
      work.closure = doAsync(work:)
      work.closure?(work)
      return work
   }
}
