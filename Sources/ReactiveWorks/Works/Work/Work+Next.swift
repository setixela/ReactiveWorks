//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

import Foundation

// MARK: - NextWorks

public extension Work {
   @discardableResult
   func doNext<Out2>(_ work: Work<Out, Out2>, on: DispatchQueue? = nil) -> Work<Out, Out2> {
      work.savedResultClosure = savedResultClosure
      work.doQueue = on ?? doQueue

      nextWork = WorkWrappper<Out, Out2>(work: work)

      return work
   }

   @discardableResult
   func doRecover<Out2>(_ work: Work<Out, Out2>, on: DispatchQueue? = nil) -> Work<Out, Out2> {
      work.savedResultClosure = savedResultClosure
      work.type = .recoverNext
      work.doQueue = on ?? doQueue

      recoverWork = WorkWrappper<Out, Out2>(work: work)

      return work
   }

   @discardableResult
   func doVoidRecover<Out2>(_ work: Work<Void, Out2>, on: DispatchQueue? = nil) -> Work<Void, Out2> {
      work.savedResultClosure = savedResultClosure
      work.type = .recoverNext
      work.doQueue = on ?? doQueue

      voidRecoverWork = WorkWrappper<Void, Out2>(work: work)

      return work
   }

   @discardableResult
   func doAnyway(on: DispatchQueue? = nil) -> Work<Input, Out> where Input == Out {
      let newWork = Work<Input, Out>() { [weak self] work in
         guard let input = self?.unsafeInput else { fatalError() }

         work.success(result: input)
      }

      newWork.type = .recover
      newWork.savedResultClosure = savedResultClosure
      newWork.doQueue = on ?? doQueue

      recoverWork = WorkWrappper<Input, Out>(work: newWork)
      nextWork = recoverWork

      return newWork
   }

   // breaking and start void input task
   @discardableResult
   func doVoidNext<Out2>(_ work: Work<Void, Out2>, on: DispatchQueue? = nil) -> Work<Void, Out2> {
      work.savedResultClosure = savedResultClosure
      work.type = .initVoid
      work.doQueue = on ?? doQueue

      voidNextWork = WorkWrappper<Void, Out2>(work: work)

      return work
   }

   // breaking and start void input task
   @discardableResult
   func doVoidNext<Out2>(on: DispatchQueue? = nil, _ closure: @escaping WorkClosure<Void, Out2>) -> Work<Void, Out2> {
      let newWork = Work<Void, Out2>(input: nil,
                                     closure,
                                     savedResultClosure)

      newWork.type = .initVoidClosure
      newWork.doQueue = on ?? doQueue
      nextWork = WorkWrappper<Void, Out2>(work: newWork)

      return newWork
   }

   // Anyway start void input task , input: Worker.In? = nil
   @discardableResult
   func doAnyway<Out2>(_ work: Work<Void, Out2>, on: DispatchQueue? = nil) -> Work<Void, Out2> {
      work.savedResultClosure = savedResultClosure
      work.type = .anywayVoid
      work.doQueue = on ?? doQueue

      anywayWork = WorkWrappper<Void, Out2>(work: work)

      return work
   }

   @discardableResult
   func doAnywayInput<T>(_ input: T?, on: DispatchQueue? = nil) -> Work<Void, T> {
      let work = Work<Void, T>()
      work.savedResultClosure = savedResultClosure
      work.type = .anywayVoid
      work.closure = {
         guard let input = input else {
            $0.fail()
            return
         }

         $0.success(result: input)
      }

      work.doQueue = on ?? doQueue
      anywayWork = WorkWrappper<Void, T>(work: work)

      return work
   }

   // breaking and start void input task
   @discardableResult
   func doAnyway<Out2>(on: DispatchQueue? = nil, _ closure: @escaping WorkClosure<Void, Out2>) -> Work<Void, Out2> {
      let newWork = Work<Void, Out2>(input: nil,
                                     closure,
                                     savedResultClosure)

      newWork.type = .anywayClosure
      newWork.doQueue = on ?? doQueue
      anywayWork = WorkWrappper<Void, Out2>(work: newWork)

      return newWork
   }

   @discardableResult
   func doNext<U: UseCaseProtocol>(_ usecase: U, on: DispatchQueue? = nil) -> Work<U.In, U.Out>
      where Out == U.In
   {
      let work = usecase.work

      //   work.type = .nextUsecase
      work.savedResultClosure = savedResultClosure
      work.doQueue = on ?? doQueue
      nextWork = WorkWrappper<U.In, U.Out>(work: work)
      return work
   }

   @discardableResult
   func doNext<Out2>(on: DispatchQueue? = nil, _ closure: @escaping WorkClosure<Out, Out2>) -> Work<Out, Out2> {
      let newWork = Work<Out, Out2>(input: nil,
                                    closure,
                                    savedResultClosure)

      //    newWork.type = .nextClosure
      newWork.doQueue = on ?? doQueue
      nextWork = WorkWrappper<Out, Out2>(work: newWork)

      return newWork
   }

   @discardableResult
   func doNext<Worker>(_ worker: Worker?, input: Worker.In? = nil, on: DispatchQueue? = nil)
      -> Work<Worker.In, Worker.Out>
      where Worker: WorkerProtocol, Out == Worker.In
   {
      guard let worker = worker else {
         fatalError()
         // return .init()
      }

      let work = Work<Worker.In, Worker.Out>(input: input,
                                             worker.doAsync(work:),
                                             savedResultClosure)
      //  work.type = .nextWorker
      work.doQueue = on ?? doQueue
      nextWork = WorkWrappper<Worker.In, Worker.Out>(work: work)

      return work
   }

   func doMap<T>(on: DispatchQueue? = nil, _ mapper: @escaping MapClosure<Out, T?>) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
      work.closure = { work in
         guard let input = work.input else {
            work.fail()
            return
         }

         guard let result = mapper(input) else {
            work.fail()
            return
         }

         work.success(result: result)
      }
      work.type = .mapper
      work.doQueue = on ?? doQueue
      nextWork = WorkWrappper(work: work)

      return work
   }

   func doCheck(on: DispatchQueue? = nil, _ checker: @escaping (Out) -> Bool) -> Work<Out, Out> {
      let newWork = Work<Out, Out>()
      newWork.savedResultClosure = savedResultClosure
      newWork.closure = { work in
         let input = work.in

         if checker(input) {
            work.success(input)
         } else {
            work.fail(input)
         }
      }
      newWork.type = .mapper
      newWork.doQueue = on ?? doQueue
      nextWork = WorkWrappper(work: newWork)

      return newWork
   }

   func doMix<T: Any>(_ value: T?, on: DispatchQueue? = nil) -> Work<Out, (Out, T)> {
      let work = Work<Out, (Out, T)>()
      work.savedResultClosure = savedResultClosure
      work.doQueue = on ?? doQueue
      work.closure = { work in
         guard
            let value = value,
            let input = work.input
         else {
            work.fail()
            return
         }

         work.success(result: (input, value))
      }
      work.type = .mixer
      nextWork = WorkWrappper(work: work)

      return work
   }

   func doMixSaved<OutSaved>(on: DispatchQueue? = nil) -> Work<Out, (Out, OutSaved)> {
      let work = Work<Out, (Out, OutSaved)>()
      work.savedResultClosure = savedResultClosure
      work.doQueue = on ?? doQueue
      work.closure = { [savedResultClosure] work in
         let savedValue = savedResultClosure?()

         guard let saved = savedValue as? OutSaved else {
            assertionFailure("saved value is not \(OutSaved.self)")
            work.fail()
            return
         }


         work.success(result: (work.in, saved))
      }
      work.type = .mixer
      nextWork = WorkWrappper(work: work)

      return work
   }

   func doWeakMix<T: AnyObject>(_ value: T?, on: DispatchQueue? = nil) -> Work<Out, (Out, T)> {
      let work = Work<Out, (Out, T)>()
      work.savedResultClosure = savedResultClosure
      work.type = .weakMixer
      work.doQueue = on ?? doQueue

      weak var value = value
      work.closure = { work in
         guard
            let value = value,
            let input = work.input
         else {
            work.fail()
            return
         }

         work.success(result: (input, value))
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   func doInput<T: Any>(_ input: T?, on: DispatchQueue? = nil) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
      work.type = .input
      work.doQueue = on ?? doQueue
      work.closure = {
         guard let input = input else {
            $0.fail()
            return
         }

         $0.success(result: input)
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   func doWeakInput<T: AnyObject>(_ input: T?, on: DispatchQueue? = nil) -> Work<Out, T> {
      weak var input = input

      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
      work.type = .weakInput
      work.doQueue = on ?? doQueue
      work.closure = {
         guard let input = input else {
            $0.fail()
            return
         }

         $0.success(result: input)
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   func doInput<T>(on: DispatchQueue? = nil, _ input: @escaping () -> T?) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
      work.type = .closureInput
      work.doQueue = on ?? doQueue
      work.closure = {
         guard let input = input() else {
            $0.fail()
            return
         }
         $0.success(result: input)
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   @discardableResult
   func doSendVoidEvent(_ work: Work<Void, Void>, on: DispatchQueue? = nil) -> Work<Out, Out> {
      let newWork = Work<Out, Out>()
      newWork.savedResultClosure = savedResultClosure
      newWork.doQueue = on ?? doQueue
      newWork.closure = { [work] inWork in
         work.sendAsyncEvent()
         inWork.success(inWork.in)
      }
      nextWork = WorkWrappper(work: newWork)

      return newWork
   }

   @discardableResult
   func doSendEvent(_ work: Work<Void, Out>, on: DispatchQueue? = nil) -> Work<Out, Out> {
      let newWork = Work<Out, Out>()
      newWork.savedResultClosure = savedResultClosure
      newWork.doQueue = on ?? doQueue
      newWork.closure = { [work] inWork in
         work.sendAsyncEvent(inWork.in)
         inWork.success(inWork.in)
      }
      nextWork = WorkWrappper(work: newWork)

      return newWork
   }
}
