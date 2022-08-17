//
//  AsyncWork.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 30.07.2022.
//

import Foundation
import SwiftUI

// MARK: - Aliases

public typealias WorkClosure<In, Out> = (Work<In, Out>) -> Void
public typealias MapClosure<In, Out> = (In) -> Out

// MARK: - Work

open class Work<In, Out>: Any {
   public var input: In?

   public var unsafeInput: In {
      guard let input = input else {
         fatalError()
      }

      return input
   }

   public var result: Out?

   public var closure: WorkClosure<In, Out>?

   // Private
   private var finisher: ((Out) -> Void)?
   private var voidFinisher: VoidClosure?
   private var genericFail: LambdaProtocol?
   private var nextWork: WorkWrappperProtocol?
   private var onAnyResultVoidClosure: VoidClosure?

   // Methods
   public init(input: In?, _ closure: @escaping WorkClosure<In, Out>) {
      self.input = input
      self.closure = closure
   }

   public init(_ closure: @escaping WorkClosure<In, Out>) {
      self.closure = closure
   }

   public init(input: In? = nil) {
      self.input = input
   }

   public func success(result: Out) {
      self.result = result

      onAnyResultVoidClosure?()
      voidFinisher?()
      finisher?(result)
      nextWork?.perform(result)
   }

   public func failThenNext<T>(_ value: T) {
      onAnyResultVoidClosure?()
      genericFail?.perform(value)
      nextWork?.perform(value)
   }

   public func fail<T>(_ value: T) {
      onAnyResultVoidClosure?()
      genericFail?.perform(value)
   }
}

public extension Work {
   @discardableResult func onSuccess(_ finisher: @escaping (Out) -> Void) -> Self {
      self.finisher = finisher

      return self
   }

   @discardableResult func onSuccess(_ voidFinisher: @escaping () -> Void) -> Self {
      self.voidFinisher = voidFinisher

      return self
   }

   @discardableResult func onFail<T>(_ failure: @escaping GenericClosure<T>) -> Self {
      genericFail = Lambda(lambda: failure)

      return self
   }

   @discardableResult func doNext(_ closure: @escaping VoidClosure) -> Self {
      onAnyResultVoidClosure = closure

      return self
   }
}

public extension Work {
   @discardableResult
   func retainBy(_ retainer: Retainer?) -> Self {
      retainer?.retain(self)
      return self
   }
}

// exte
public extension Work {
   @discardableResult
   func doNext<Out2>(work: Work<Out, Out2>) -> Work<Out, Out2> {
      nextWork = WorkWrappper<Out, Out2>(work: work)

      return work
   }

   @discardableResult
   func doNext<U: UseCaseProtocol>(usecase: U) -> Work<U.In, U.Out>
      where Out == U.In
   {
      let work = usecase.work
      nextWork = WorkWrappper<U.In, U.Out>(work: work)
      return work
   }

   @discardableResult
   func doNext<Out2>(_ closure: @escaping WorkClosure<Out, Out2>) -> Work<Out, Out2> {
      let newWork = Work<Out, Out2>(input: nil, closure)
      nextWork = WorkWrappper<Out, Out2>(work: newWork)

      return newWork
   }

   @discardableResult
   func doNext<Worker>(worker: Worker?, input: Worker.In? = nil)
      -> Work<Worker.In, Worker.Out>
      where Worker: WorkerProtocol, Out == Worker.In
   {
      guard let worker = worker else {
         fatalError()
         // return .init()
      }

      let work = Work<Worker.In, Worker.Out>(input: input, worker.doAsync(work:))
      nextWork = WorkWrappper<Worker.In, Worker.Out>(work: work)

      return work
   }

   @discardableResult
   func doMap<T>(_ mapper: @escaping MapClosure<Out, T?>) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.closure = { work in
         guard let input = work.input else {
            work.fail(())
            return
         }

         guard let result = mapper(input) else {
            work.fail(())
            return
         }

         work.success(result: result)
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   @discardableResult
   func doMix<T: Any>(_ value: T?) -> Work<Out, (Out, T)> {
      let work = Work<Out, (Out, T)>()
      work.closure = { work in
         guard
            let value = value,
            let input = work.input
         else {
            work.fail(())
            return
         }

         work.success(result: (input, value))
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   @discardableResult
   func doWeakMix<T: AnyObject>(_ value: T?) -> Work<Out, (Out, T)> {
      let work = Work<Out, (Out, T)>()
      weak var value = value
      work.closure = { work in
         guard
            let value = value,
            let input = work.input
         else {
            work.fail(())
            return
         }

         work.success(result: (input, value))
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   @discardableResult
   func doInput<T: Any>(_ input: T?) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.closure = {
         guard let input = input else {
            $0.fail(())
            return
         }

         $0.success(result: input)
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   @discardableResult
   func doWeakInput<T: AnyObject>(_ input: T?) -> Work<Out, T> {
      weak var input = input

      let work = Work<Out, T>()
      work.closure = {
         guard let input = input else {
            $0.fail(())
            return
         }

         $0.success(result: input)
      }
      nextWork = WorkWrappper(work: work)

      return work
   }

   @discardableResult
   func doInput<T>(_ input: @escaping () -> T?) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.closure = {
         guard let input = input() else {
            $0.fail(())
            return
         }
         $0.success(result: input)
      }
      nextWork = WorkWrappper(work: work)

      return work
   }
}

public extension Work {
   @discardableResult
   func doSync() -> Out {
      closure?(self)

      return result ?? { fatalError() }()
   }

   @discardableResult
   func doSync(_ input: In?) -> Out {
      self.input = input
      closure?(self)

      return result ?? { fatalError() }()
   }

   @discardableResult
   func doAsync() -> Self {
      DispatchQueue.main.async { [weak self] in
         guard let self = self else { return }

         self.closure?(self)
      }
      return self
   }

   @discardableResult
   func doAsync(_ input: In?) -> Self {
      self.input = input
      DispatchQueue.main.async { [weak self] in
         guard let self = self else { return }

         self.closure?(self)
      }
      return self
   }
}

extension Work {
   private func clean() {
      finisher = nil
      nextWork = nil
      genericFail = nil
   }
}

// MARK: - Erasing Work Wrapper

public protocol WorkWrappperProtocol {
   func perform<AnyType>(_ value: AnyType)
}

public struct WorkWrappper<T, U>: WorkWrappperProtocol where T: Any, U: Any {
   public func perform<AnyType>(_ value: AnyType) where AnyType: Any {
      guard
         let value = value as? T
      else {
         print("Lambda payloads not conform: {\(value)} is not {\(T.self)}")
         return
      }

      work.input = value

      guard let closure = work.closure else {
         return
      }

      closure(work)
   }

   let work: Work<T, U>
}

extension Work: Hashable {}

public final class Retainer {
   private lazy var retained: Set<AnyHashable> = []

   public init() {}

   public func retain(_ some: AnyHashable) {
      retained.update(with: some)
   }

   deinit {
      retained.removeAll()
   }
}

public extension Hashable where Self: AnyObject {
   func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(self))
   }

   static func ==(lhs: Self, rhs: Self) -> Bool {
      ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
   }
}
