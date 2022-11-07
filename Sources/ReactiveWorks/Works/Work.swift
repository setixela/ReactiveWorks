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

public protocol Cancellable {
   func cancel()
}

// MARK: - Work

public enum WorkType: String {
   case `default`
   case nextWork
   case nextClosure
   case nextUsecase
   case nextWorker
   case input
   case weakInput
   case closureInput
   case mapper
   case mixer
   case weakMixer
   case loadSaved
   case recover
   case recoverNext
   case initVoid
   case initVoidClosure
   case event
}

extension Work: CustomStringConvertible {
   public var description: String {
      "Work: \(type.rawValue), In: \(String(describing: In.Type.self)) -> Out: \(String(describing: Out.Type.self))"
   }
}

open class Work<In, Out>: Any, Finishible {
   public var type: WorkType = .default

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

   private var successStateFunc: LambdaProtocol?
   private var successStateVoidFunc: Lambda<Void>?

   private var failStateFunc: LambdaProtocol?
   private var failStateVoidFunc: Lambda<Void>?

   private var genericFail: LambdaProtocol?

   private var nextWork: WorkWrappperProtocol?
   private var voidNextWork: WorkWrappperProtocol?
   private var recoverWork: WorkWrappperProtocol?
   private var loadWork: WorkWrappperProtocol?

   private var savedResultClosure: (() -> Any)?

   private var isCancelled = false
   private var cancellables: [Cancellable] = []
   private var cancelClosure: VoidClosure?

   private var isWorking = false

   // Methods
   public init(input: In?,
               _ closure: @escaping WorkClosure<In, Out>,
               _ savedResultClosure: (() -> Any)? = nil)
   {
      self.input = input
      self.closure = closure
      self.savedResultClosure = savedResultClosure
   }

   public init(_ closure: @escaping WorkClosure<In, Out>) {
      self.closure = closure
   }

   public init(retainedBy: Retainer, _ closure: @escaping WorkClosure<In, Out>) {
      self.closure = closure
      retainedBy.retain(self)
   }

   public init(input: In? = nil) {
      self.input = input
   }

   public func success(_ result: Out) {
      success(result: result)
   }

   public func success(result: Out = ()) {
      isWorking = false

      self.result = result

      if checkCancel() { return }
      //
      voidFinisher?()
      finisher?(result)
      //
      successStateFunc?.perform(result)
      successStateVoidFunc?.perform(())
      //
      nextWork?.perform(result)
      voidNextWork?.perform(())

      isFinished = true

      if Config.isLog {
         print("\nWork Succeed! - type: \(type),\n result: \(result),\n In: \(In.self), Out: \(Out.self)\n")
      }
   }

   public func fail<T>(_ value: T = ()) {
      isWorking = false

      if checkCancel() { return }

      genericFail?.perform(value)
      recoverWork?.perform(input)
      failStateFunc?.perform(value)
      failStateVoidFunc?.perform(())

      isFinished = true

      if Config.isLog {
         print("\nWork Error! - type: \(type),\n result: \(value),\n In: \(In.self), Out: \(Out.self)\n")
      }
   }

   private func checkCancel() -> Bool {
      if isCancelled {
         isCancelled = false
         isWorking = false
         return true
      }

      return false
   }
}

extension Work: Cancellable {
   public func cancel() {
      if isWorking {
         isCancelled = true
         isWorking = false
      }
      //
      nextWork?.cancel()
      voidNextWork?.cancel()
   }
}

public extension Work {
   @discardableResult func doCancel(_ cancellable: Cancellable ...) -> Self {
      cancellables.append(contentsOf: cancellable)
      if cancelClosure == nil {
         cancelClosure = { [weak self] in
            self?.cancellables.forEach { $0.cancel() }
         }
      }
      return self
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
      successStateVoidFunc = lambda

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
      successStateFunc = lambda

      return self
   }

   @discardableResult func onFail<S>(_ delegate: ((S) -> Void)?, _ state: S) -> Self {
      let closure: GenericClosure<Void> = { [delegate] _ in
         DispatchQueue.main.async {
            delegate?(state)
         }
      }

      let lambda = Lambda(lambda: closure)
      failStateVoidFunc = lambda

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

   @discardableResult
   func onSuccess<S: AnyObject>(_ weakSelf: S, _ finisher: @escaping (S, Out) -> Void) -> Self {
      let clos = { [weak weakSelf] (result: Out) in
         guard let slf = weakSelf else { return }
         finisher(slf, result)
      }

      self.finisher = clos

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
   func onFail<S: AnyObject>(_ weakSelf: S, _ failure: @escaping (S) -> Void) -> Self {
      let clos = { [weak weakSelf] (_: Out) in
         guard let slf = weakSelf else { return }
         failure(slf)
      }

      genericFail = Lambda(lambda: clos)

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
      successStateFunc = lambda

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
      let saveClosure: () -> Out = { [weak self] in
         guard let result = self?.result else {
            fatalError()
         }
         return result
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

      newWork.type = .loadSaved
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
      successStateFunc = lambda

      return self
   }

   @discardableResult
   func onFailMixSaved<S, OutSaved>(_ delegate: ((S) -> Void)?,
                                    _ stateFunc: @escaping ((Out, OutSaved)) -> S) -> Self
   {
      let closure: GenericClosure<Out> = { [weak self, delegate] result in
         guard
            let value = self?.savedResultClosure?(),
            let saved = value as? OutSaved
         else {
            fatalError()
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
   func doNext<Out2>(_ work: Work<Out, Out2>) -> Work<Out, Out2> {
      work.savedResultClosure = savedResultClosure
      work.type = .nextWork

      nextWork = WorkWrappper<Out, Out2>(work: work)

      return work
   }

   @discardableResult
   func doRecover<Out2>(_ work: Work<Out, Out2>) -> Work<Out, Out2> {
      work.savedResultClosure = savedResultClosure
      work.type = .recoverNext

      recoverWork = WorkWrappper<Out, Out2>(work: work)
      nextWork = recoverWork

      return work
   }

   @discardableResult
   func doRecover() -> Work<In, Out> where In == Out {
      let newWork = Work<In, Out>() { [weak self] work in
         //    work.result = work.input
         // guard let result = work?.input else { fatalError() }
         guard let input = self?.unsafeInput else { fatalError() }

         work.success(result: input)
      }

      newWork.type = .recover
      newWork.savedResultClosure = savedResultClosure

      recoverWork = WorkWrappper<In, Out>(work: newWork)
      nextWork = recoverWork

      return newWork
   }

   // breaking and start void input task
   @discardableResult
   func doVoidNext<Out2>(_ work: Work<Void, Out2>) -> Work<Void, Out2> {
      work.savedResultClosure = savedResultClosure
      work.type = .initVoid

      voidNextWork = WorkWrappper<Void, Out2>(work: work)

      return work
   }

   // breaking and start void input task
   @discardableResult
   func doVoidNext<Out2>(_ closure: @escaping WorkClosure<Void, Out2>) -> Work<Void, Out2> {
      let newWork = Work<Void, Out2>(input: nil,
                                     closure,
                                     savedResultClosure)

      newWork.type = .initVoidClosure

      nextWork = WorkWrappper<Void, Out2>(work: newWork)

      return newWork
   }

   @discardableResult
   func doNext<U: UseCaseProtocol>(usecase: U) -> Work<U.In, U.Out>
      where Out == U.In
   {
      let work = usecase.work

      work.type = .nextUsecase
      work.savedResultClosure = savedResultClosure

      nextWork = WorkWrappper<U.In, U.Out>(work: work)
      return work
   }

   @discardableResult
   func doNext<Out2>(_ closure: @escaping WorkClosure<Out, Out2>) -> Work<Out, Out2> {
      let newWork = Work<Out, Out2>(input: nil,
                                    closure,
                                    savedResultClosure)

      newWork.type = .nextClosure

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
      work.type = .nextWorker
      nextWork = WorkWrappper<Worker.In, Worker.Out>(work: work)

      return work
   }

   func doMap<T>(_ mapper: @escaping MapClosure<Out, T?>) -> Work<Out, T> {
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
            work.fail()
            return
         }

         work.success(result: (input, value))
      }
      work.type = .mixer
      nextWork = WorkWrappper(work: work)

      return work
   }

   func doWeakMix<T: AnyObject>(_ value: T?) -> Work<Out, (Out, T)> {
      let work = Work<Out, (Out, T)>()
      work.savedResultClosure = savedResultClosure
      work.type = .weakMixer

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

   func doInput<T: Any>(_ input: T?) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
      work.type = .input
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

   func doWeakInput<T: AnyObject>(_ input: T?) -> Work<Out, T> {
      weak var input = input

      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
      work.type = .weakInput
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

   func doInput<T>(_ input: @escaping () -> T?) -> Work<Out, T> {
      let work = Work<Out, T>()
      work.savedResultClosure = savedResultClosure
      work.type = .closureInput
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
}

public extension Work {
   @discardableResult
   func doSync(_ input: In? = nil) -> Out? {
      cancelClosure?()
      isWorking = true
      self.input = input ?? self.input
      closure?(self)

      return result
   }

   @discardableResult
   func doSyncWithResult(_ result: Out) -> Out {
      cancelClosure?()
      isWorking = true
      success(result: result)
      return result
   }

   @discardableResult
   func doAsync(_ input: In? = nil) -> Self {
      DispatchQueue.main.async { [weak self] in
         self?.doSync(input)
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

      work.doSync(value)
   }

   public func cancel() {
      work.cancel()
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

public extension Hashable where Self: AnyObject {
   func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(self))
   }

   static func ==(lhs: Self, rhs: Self) -> Bool {
      ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
   }
}
