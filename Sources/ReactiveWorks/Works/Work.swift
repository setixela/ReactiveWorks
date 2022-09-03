//
//  AsyncWork.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 30.07.2022.
//

import CoreGraphics
import Foundation

// MARK: - Aliases

public typealias WorkClosure<In, Out> = (Work<In, Out>) -> Void
public typealias MapClosure<In, Out> = (In) -> Out

public typealias VoidWork<Out> = Work<Void, Out>
public typealias StringWork<Out> = Work<String, Out>
public typealias IntWork<Out> = Work<Int, Out>
public typealias CGFloatWork<Out> = Work<CGFloat, Out>

public protocol Finishible {
   var isFinished: Bool { get }
}

// MARK: - Work

open class Work<In, Out>: Any, Finishible {
   public var input: In?

   public var unsafeInput: In {
      guard let input = input else {
         fatalError()
      }

      return input
   }

   public var result: Out?

   public var closure: WorkClosure<In, Out>?

   public private(set) var isFinished = false

   // Private
   private var finisher: ((Out) -> Void)?
   private var voidFinisher: VoidClosure?

   private var succesStateFunc: LambdaProtocol?
   private var failStateFunc: LambdaProtocol?
   private var genericFail: LambdaProtocol?

   private var nextWork: WorkWrappperProtocol?
   private var breakinNextWork: WorkWrappperProtocol?
   private var nextFailWork: WorkWrappperProtocol?
   private var recoverWork: WorkWrappperProtocol?
   private var loadWork: WorkWrappperProtocol?

   private var savedResultClosure: (() -> Any?)?

   // Methods
   public init(input: In?,
               _ closure: @escaping WorkClosure<In, Out>,
               _ savedResultClosure: (() -> Any?)? = nil)
   {
      self.input = input
      self.closure = closure
      self.savedResultClosure = savedResultClosure
   }

   public init(_ closure: @escaping WorkClosure<In, Out>) {
      self.closure = closure
   }

   public init(input: In? = nil) {
      self.input = input
   }

   public func success(result: Out) {
      self.result = result

      voidFinisher?()
      finisher?(result)
      succesStateFunc?.perform(result)
      nextWork?.perform(result)
      breakinNextWork?.perform(())
      recoverWork?.perform(result)

      isFinished = true
   }

   public func fail<T>(_ value: T) {
      failStateFunc?.perform(value)
      nextFailWork?.perform(value)
      genericFail?.perform(value)
      recoverWork?.perform(value)

      isFinished = true
   }
}

public extension Work {
   @discardableResult func onSuccess<S>(_ delegate: ((S) -> Void)?, _ state: S) -> Self {
      let closure: GenericClosure<Void> = { [delegate] _ in
         DispatchQueue.main.async {
            delegate?(state)
         }
      }

      let lambda = Lambda(lambda: closure)
      succesStateFunc = lambda

      return self
   }

   @discardableResult func onSuccess<S>(_ delegate: ((S) -> Void)?,
                                        _ stateFunc: @escaping (Out) -> S) -> Self
   {
      let closure: GenericClosure<Out> = { [delegate] result in
         DispatchQueue.main.async {
            delegate?(stateFunc(result))
         }
      }

      let lambda = Lambda(lambda: closure)
      succesStateFunc = lambda

      return self
   }

   @discardableResult func onFail<S>(_ delegate: ((S) -> Void)?, _ state: S) -> Self {
      let closure: GenericClosure<Void> = { [delegate] _ in
         DispatchQueue.main.async {
            delegate?(state)
         }
      }

      let lambda = Lambda(lambda: closure)
      failStateFunc = lambda

      return self
   }

   @discardableResult func onFail<S, T>(_ delegate: ((S) -> Void)?,
                                        _ stateFunc: @escaping (T) -> S) -> Self
   {
      let closure: GenericClosure<T> = { [delegate] failValue in
         DispatchQueue.main.async {
            delegate?(stateFunc(failValue))
         }
      }

      let lambda = Lambda(lambda: closure)
      failStateFunc = lambda

      return self
   }
}

public extension Work {
   @discardableResult
   func onSuccess(_ finisher: @escaping (Out) -> Void) -> Self {
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

   @discardableResult
   func onSuccessMixSaved<OutSaved>(_ stateFunc: @escaping (Out, OutSaved) -> Void) -> Self {
      let closure: GenericClosure<Out> = { [weak self] result in
         guard
            let saved = self?.savedResultClosure?(),
            let saved = saved as? OutSaved
         else {
            fatalError()
         }

         DispatchQueue.main.async {
            stateFunc(result, saved)
         }
      }

      let lambda = Lambda(lambda: closure)
      succesStateFunc = lambda

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

public extension Work {
   func doSaveResult() -> Self {
      let saveClosure: () -> Out? = { [weak self] in
         self?.result
      }

      savedResultClosure = saveClosure

      return self
   }

   func doLoadResult<OutSaved>() -> Work<Out, OutSaved> {
      let newWork = Work<Out, OutSaved>() { [weak self] work in
         guard let saved = self?.savedResultClosure?() as? OutSaved else {
            fatalError()
         }

         work.success(result: saved)
      }

      newWork.savedResultClosure = savedResultClosure

      nextWork = WorkWrappper<Out, OutSaved>(work: newWork)

      return newWork
   }
}

public extension Work {
   @discardableResult
   func onSuccessMixSaved<S, OutSaved>(_ delegate: ((S) -> Void)?,
                                       _ stateFunc: @escaping ((Out, OutSaved)) -> S) -> Self
   {
      let closure: GenericClosure<Out> = { [weak self, delegate] result in
         guard
            let saved = self?.savedResultClosure?(),
            let saved = saved as? OutSaved
         else {
            fatalError()
         }

         DispatchQueue.main.async {
            delegate?(stateFunc((result, saved)))
         }
      }

      let lambda = Lambda(lambda: closure)
      succesStateFunc = lambda

      return self
   }

   @discardableResult
   func onFailMixSaved<S, OutSaved>(_ delegate: ((S) -> Void)?,
                                    _ stateFunc: @escaping ((Out, OutSaved)) -> S) -> Self
   {
      let closure: GenericClosure<Out> = { [weak self, delegate] result in
         guard
            let saved = self?.savedResultClosure?()
         else {
            return
         }

         guard
            let saved = saved as? OutSaved
         else {
            return
         }

         DispatchQueue.main.async {
            delegate?(stateFunc((result, saved)))
         }
      }

      let lambda = Lambda(lambda: closure)
      failStateFunc = lambda

      return self
   }
}

// exte
public extension Work {
   @discardableResult
   func doNext<Out2>(work: Work<Out, Out2>) -> Work<Out, Out2> {
      work.savedResultClosure = savedResultClosure

      nextWork = WorkWrappper<Out, Out2>(work: work)

      return work
   }

   @discardableResult
   func doNext<Out2>(_ work: Work<Out, Out2>) -> Work<Out, Out2> {
      work.savedResultClosure = savedResultClosure

      nextWork = WorkWrappper<Out, Out2>(work: work)

      return work
   }

   @discardableResult
   func doRecover<Out2>(_ work: Work<Out, Out2>) -> Work<Out, Out2> {
      work.savedResultClosure = savedResultClosure

      recoverWork = WorkWrappper<Out, Out2>(work: work)

      return work
   }

   @discardableResult
   func doRecover() -> Work<In, Out> {
      let newWork = Work<In, Out>() { [weak self] work in
         guard let input = self?.input as? Out else { fatalError() }

         work.success(result: input)
      }

      newWork.savedResultClosure = savedResultClosure

      recoverWork = WorkWrappper<In, Out>(work: newWork)

      return newWork
   }

   // breaking and start void input task
   @discardableResult
   func doVoidNext<Out2>(_ work: Work<Void, Out2>) -> Work<Void, Out2> {
      work.savedResultClosure = savedResultClosure

      breakinNextWork = WorkWrappper<Void, Out2>(work: work)

      return work
   }

   @discardableResult
   func doNext<U: UseCaseProtocol>(usecase: U) -> Work<U.In, U.Out>
      where Out == U.In
   {
      let work = usecase.work
      work.savedResultClosure = savedResultClosure

      nextWork = WorkWrappper<U.In, U.Out>(work: work)
      return work
   }

   @discardableResult
   func doNext<Out2>(_ closure: @escaping WorkClosure<Out, Out2>) -> Work<Out, Out2> {
      let newWork = Work<Out, Out2>(input: nil,
                                    closure,
                                    savedResultClosure)

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

      let work = Work<Worker.In, Worker.Out>(input: input,
                                             worker.doAsync(work:),
                                             savedResultClosure)
      nextWork = WorkWrappper<Worker.In, Worker.Out>(work: work)

      return work
   }

   func doMap<T>(_ mapper: @escaping MapClosure<Out, T?>) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
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

   func doMix<T: Any>(_ value: T?) -> Work<Out, (Out, T)> {
      let work = Work<Out, (Out, T)>()
      work.savedResultClosure = savedResultClosure
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

   func doWeakMix<T: AnyObject>(_ value: T?) -> Work<Out, (Out, T)> {
      let work = Work<Out, (Out, T)>()
      work.savedResultClosure = savedResultClosure
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

   func doInput<T: Any>(_ input: T?) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
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

   func doWeakInput<T: AnyObject>(_ input: T?) -> Work<Out, T> {
      weak var input = input

      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
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

   func doInput<T>(_ input: @escaping () -> T?) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
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
         fatalError()
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
      cleanIfNeeded()
      retained.update(with: some)
      if retained.count > 100 {
         log("100")
      }
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

public extension Hashable where Self: AnyObject {
   func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(self))
   }

   static func ==(lhs: Self, rhs: Self) -> Bool {
      ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
   }
}
