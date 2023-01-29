//
//  AsyncWork.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 30.07.2022.
//

/*

 This looks like a class for managing asynchronous tasks in a Swift program. The Work class appears to be a generic class that takes two type parameters, In and Out, which represent the input type and output type for a given task. The class has several properties, such as type, input, result, and closure, as well as several methods for handling the success or failure of a task and chaining tasks together. The class also conforms to the Finishible and Cancellable protocols, which suggest that it has functionality for determining whether a task is finished and for cancelling a task. It's not clear from the code snippet what the specific use case for this class is, but it seems to be designed to provide a flexible and organized way to manage asynchronous tasks in a Swift program.

 */

import CoreGraphics
import Foundation

// MARK: - Aliases

public typealias WorkClosure<In, Out> = (Work<In, Out>) -> Void
public typealias MapClosure<In, Out> = (In) -> Out

public typealias StringWork<Out> = Work<String, Out>
public typealias IntWork<Out> = Work<Int, Out>
public typealias CGFloatWork<Out> = Work<CGFloat, Out>

public typealias Delegate<S> = (S) -> Void

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
    case compactMapper
    case mixer
    case weakMixer
    case loadSaved
    case recover
    case recoverNext
    case initVoid
    case initVoidClosure
    case event
    case anywayVoid
    case anywayClosure
    case anywayInput
    case initGroupClosure
    case initOptionalGroupClosure
    case signal
}

extension Work: CustomStringConvertible {
    public var description: String {
        "Work: \(type.rawValue), In: \(String(describing: In.Type.self)) -> Out: \(String(describing: Out.Type.self))"
    }
}

public protocol WorkProtocol {
    associatedtype In
    associatedtype Out
}

open class Work<In, Out>: Any, WorkProtocol, Finishible {
    public internal(set) var type: WorkType = .default

    public internal(set) var input: In?

    public var unsafeInput: In {
        guard let input = input else {
            fatalError()
        }

        return input
    }

    public var result: Out?

    public var closure: WorkClosure<In, Out>?

    public internal(set) var isFinished = false
    public internal(set) var isCancelled = false

    // Private
    var finisher: ((Out) -> Void)?
    var voidFinisher: VoidClosure?

    var signalFunc: LambdaProtocol?

    var successStateFunc: LambdaProtocol?
    var successStateVoidFunc: Lambda<Void>?

    var failStateFunc: LambdaProtocol?
    var failStateVoidFunc: Lambda<Void>?

    var genericFail: LambdaProtocol?

    var nextWork: WorkWrappperProtocol?
    var voidNextWork: WorkWrappperProtocol?
    var recoverWork: WorkWrappperProtocol?
    var loadWork: WorkWrappperProtocol?
    var anywayWork: WorkWrappperProtocol?

    var savedResultClosure: (() -> Any)?

    var cancellables: [Cancellable] = []
    var cancelClosure: VoidClosure?

    var isWorking = false

    public internal(set) var doQueue: DispatchQueue?
    public internal(set) lazy var finishQueue = DispatchQueue.main

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
        //
        anywayWork?.perform(())

        isFinished = true

        if Config.isLog {
            print("\nWork Succeed! - type: \(type),\n result: \(result),\n In: \(In.self), Out: \(Out.self)\n")
        }
    }

    public func fail<T>(_ value: T = ()) {
        #if DEBUG
            print("Thread: \(Thread.current)")
        #endif

        isWorking = false

        if checkCancel() { return }

        genericFail?.perform(value)
        recoverWork?.perform(input)
        failStateFunc?.perform(value)
        failStateVoidFunc?.perform(())
        anywayWork?.perform(())

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

    func doLoadResult<OutSaved>(on: DispatchQueue? = nil) -> Work<Out, OutSaved> {
        let newWork = Work<Out, OutSaved>() { [weak self] work in
            guard let savedResultClosure = self?.savedResultClosure else {
                assertionFailure("savedResultClosure is nil")
                work.fail()
                return
            }

            let savedValue = savedResultClosure()

            guard let saved = savedValue as? OutSaved else {
                assertionFailure("saved value is not \(OutSaved.self)")
                work.fail()
                return
            }

            work.success(result: saved)
        }

        newWork.type = .loadSaved
        newWork.savedResultClosure = savedResultClosure
        newWork.doQueue = on ?? doQueue

        nextWork = WorkWrappper<Out, OutSaved>(work: newWork)

        return newWork
    }
}

public extension Work {
    @discardableResult
    func doSync(_ input: In? = nil) -> Out? {
        cancelClosure?()
        isWorking = true
        isCancelled = false
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
    func doAsync(_ input: In? = nil, on: DispatchQueue? = nil) -> Self {
        (on ?? doQueue ?? .main).async { [weak self] in
            #if DEBUG
                print("Thread: \(Thread.current)")
            #endif
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

extension Work: Hashable {}

public extension Hashable where Self: AnyObject {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
