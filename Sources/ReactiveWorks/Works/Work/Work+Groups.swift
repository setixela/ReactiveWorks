//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

import Foundation

public protocol GroupWorkProtocol: Work<[Self.InElement], [Self.OutElement]> {
    associatedtype InElement
    associatedtype OutElement
}

public class GroupWork<InElement, OutElement>: Work<[InElement], [OutElement]>, GroupWorkProtocol {
    var count: Int { input?.count ?? 0 }
    
    public convenience init(_ inputs: In? = nil,
                on: DispatchQueue? = nil,
                work: Work<In.Element, Out.Element>) {
        self.init(inputs, on: on, work.closure)
        type = .groupWork
    }
    
    public init(_ inputs: In? = nil,
                on: DispatchQueue? = nil,
                _ workClosure: WorkClosure<In.Element, Out.Element>?)
    {
        //
        super.init(input: inputs ?? [])

        result = []
        type = .groupWorkClosure
        doQueue = on ?? doQueue

        closure = { [weak self] work in
            guard work.unsafeInput.isEmpty == false else {
                work.success([])
                return
            }

            let localWork = Work<In.Element, Out.Element>()
            localWork.doQueue = on ?? self?.doQueue
            localWork.closure = workClosure
            localWork.type = .groupLocal

            self?.performWork(localWork, index: 0) {
                work.success($0)
            }
        }
    }
    
    // MARK: - Recursive func
    
    private func performWork(_ work: Work<In.Element, Out.Element>, index: Int, callback: @escaping (Out) -> Void) {
        work
            .doAsync(unsafeInput[index])
            .onSuccess { [weak self] in
                guard let self else { return }
                
                self.result?.append($0)
                
                self.signalFunc?.perform(($0, index))
                
                if index < self.unsafeInput.count - 1 {
                    self.performWork(work, index: index + 1, callback: callback)
                } else {
                    callback(self.result ?? [])
                }
            }
            .onFail { [weak self] in
                guard let self else { return }
                
                if index < self.unsafeInput.count - 1 {
                    self.performWork(work, index: index + 1, callback: callback)
                } else {
                    callback(self.result ?? [])
                }
            }
    }
}

public extension Work {
    @discardableResult
    func onEachResult<Res>(_ signal: @escaping (Res?, Int) -> Void) -> Self where Out == [Res?] {
        let signalClosure: ((Res?, Int)) -> Void = { [weak self] tuple in
            self?.finishQueue.async {
                signal(tuple.0, tuple.1)
            }
        }
        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    @discardableResult
    func onEachResult<Res>(_ signal: @escaping (Res, Int) -> Void) -> Self where Out == [Res] {
        let signalClosure: ((Res, Int)) -> Void = { [weak self] tuple in
            self?.finishQueue.async {
                signal(tuple.0, tuple.1)
            }
        }
        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    @discardableResult func onEachResult<Res, S>(
        _ delegate: Delegate<S>?,
        _ stateFunc: @escaping ((Res?, Int)) -> S
    ) -> Self
        where Out == [Res?]
    {
        let signalClosure: ((Res?, Int)) -> Void = { [weak self, delegate] signal in
            self?.finishQueue.async {
                delegate?(stateFunc((signal.0, signal.1)))
            }
        }

        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    @discardableResult func onEachResult<Res, S>(
        _ delegate: Delegate<S>?,
        _ stateFunc: @escaping ((Res, Int)) -> S
    ) -> Self
        where Out == [Res]
    {
        let signalClosure: ((Res, Int)) -> Void = { [weak self, delegate] signal in
            self?.finishQueue.async {
                delegate?(stateFunc((signal.0, signal.1)))
            }
        }

        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    func doCompactMap<I>(on: DispatchQueue? = nil) -> Work<Out, [I]>
        where Out == [I?]
    {
        let work = Work<Out, [I]>()
        work.savedResultClosure = savedResultClosure
        work.closure = { work in
            guard let input = work.input else {
                work.fail()
                return
            }

            let result = input.compactMap { $0 }

            work.success(result: result)
        }
        work.type = .compactMapper
        work.doQueue = on ?? doQueue
        nextWork = WorkWrappper(work: work)

        return work
    }
}
