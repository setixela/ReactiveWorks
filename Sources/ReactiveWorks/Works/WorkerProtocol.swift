//
//  AsyncWorker.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 30.07.2022.
//

import Foundation

public protocol WorkerProtocol: AnyObject {
   associatedtype In
   associatedtype Out

   typealias Wrk = Work<In, Out>

   init()
   
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
      work.finishQueue.async {
         work.doSync(input)
      }
      return work
   }
}
