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
                            work: Work<In.Element, Out.Element>,
                            on: DispatchQueue? = nil)
    {
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

public extension Work {
    @discardableResult
    func doCombine<In1, In2, Out1, Out2>(_ work1: Work<In1, Out1>, _ work2: Work<In2, Out2>, on: DispatchQueue? = nil)
        -> Work<Void, (Out1, Out2)>
    {
        let newWork = Work<Void, (Out1, Out2)>(input: nil)
        newWork.savedResultClosure = savedResultClosure
        newWork.type = .combine
        newWork.doQueue = on ?? doQueue
        newWork.closure = { [weak work1, weak work2] work in
            guard let work1, let work2 else { work.fail(); return }

            var result1: Out1?
            var result2: Out2?
            work1
                .onSuccess {
                    result1 = $0
                    if result2 != nil {
                        work.success((result1!, result2!))
                        result1 = nil
                        result2 = nil
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }

            work2
                .onSuccess {
                    result2 = $0
                    if result1 != nil {
                        work.success((result1!, result2!))
                        result1 = nil
                        result2 = nil
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }
        }
        nextWork = WorkWrappper<Void, (Out1, Out2)>(work: newWork)

        return newWork
    }

    @discardableResult
    func doCombine<In1, In2, In3, Out1, Out2, Out3>(_ work1: Work<In1, Out1>,
                                                    _ work2: Work<In2, Out2>,
                                                    _ work3: Work<In3, Out3>,
                                                    on: DispatchQueue? = nil)
        -> Work<Void, (Out1, Out2, Out3)>
    {
        let newWork = Work<Void, (Out1, Out2, Out3)>(input: nil)
        newWork.savedResultClosure = savedResultClosure
        newWork.type = .combine
        newWork.doQueue = on ?? doQueue
        newWork.closure = { [weak work1, weak work2, weak work3] work in
            guard let work1, let work2, let work3 else { work.fail(); return }

            var result1: Out1?
            var result2: Out2?
            var result3: Out3?
            work1
                .onSuccess {
                    result1 = $0
                    if result2 != nil, result3 != nil {
                        work.success((result1!, result2!, result3!))
                        result1 = nil
                        result2 = nil
                        result3 = nil
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }

            work2
                .onSuccess {
                    result2 = $0
                    if result1 != nil, result3 != nil {
                        work.success((result1!, result2!, result3!))
                        result1 = nil
                        result2 = nil
                        result3 = nil
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }

            work3
                .onSuccess {
                    result3 = $0
                    if result1 != nil, result2 != nil {
                        work.success((result1!, result2!, result3!))
                        result1 = nil
                        result2 = nil
                        result3 = nil
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }
        }
        nextWork = WorkWrappper<Void, (Out1, Out2, Out3)>(work: newWork)

        return newWork
    }

    @discardableResult
    func doCombineBuffered<In1, In2, Out1, Out2>(_ work1: Work<In1, Out1>, _ work2: Work<In2, Out2>, on: DispatchQueue? = nil)
        -> Work<Void, (Out1, Out2)>
    {
        let newWork = Work<Void, (Out1, Out2)>(input: nil)
        newWork.savedResultClosure = savedResultClosure
        newWork.type = .combineBuffered
        newWork.doQueue = on ?? doQueue
        newWork.closure = { [weak work1, weak work2] work in
            guard let work1, let work2 else { work.fail(); return }

            var result1: [Out1] = []
            var result2: [Out2] = []

            work1
                .onSuccess {
                    result1.append($0)
                    if !result2.isEmpty {
                        let res1 = result1.removeFirst()
                        let res2 = result2.removeFirst()
                        work.success((res1, res2))
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }

            work2
                .onSuccess {
                    result2.append($0)
                    if !result1.isEmpty {
                        let res1 = result1.removeFirst()
                        let res2 = result2.removeFirst()
                        work.success((res1, res2))
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }
        }
        nextWork = WorkWrappper<Void, (Out1, Out2)>(work: newWork)

        return newWork
    }

    @discardableResult
    func doCombineBuffered<In1, In2, In3, Out1, Out2, Out3>(_ work1: Work<In1, Out1>,
                                                            _ work2: Work<In2, Out2>,
                                                            _ work3: Work<In3, Out3>,
                                                            on: DispatchQueue? = nil)
        -> Work<Void, (Out1, Out2, Out3)>
    {
        let newWork = Work<Void, (Out1, Out2, Out3)>(input: nil)
        newWork.savedResultClosure = savedResultClosure
        newWork.type = .combineBuffered
        newWork.doQueue = on ?? doQueue
        newWork.closure = { [weak work1, weak work2, weak work3] work in
            guard let work1, let work2, let work3 else { work.fail(); return }

            var result1: [Out1] = []
            var result2: [Out2] = []
            var result3: [Out3] = []

            work1
                .onSuccess {
                    result1.append($0)
                    if !result2.isEmpty, !result3.isEmpty {
                        let res1 = result1.removeFirst()
                        let res2 = result2.removeFirst()
                        let res3 = result3.removeFirst()

                        work.success((res1, res2, res3))
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }

            work2
                .onSuccess {
                    result2.append($0)
                    if !result1.isEmpty, !result3.isEmpty {
                        let res1 = result1.removeFirst()
                        let res2 = result2.removeFirst()
                        let res3 = result3.removeFirst()

                        work.success((res1, res2, res3))
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }

            work3
                .onSuccess {
                    result3.append($0)
                    if !result1.isEmpty, !result2.isEmpty {
                        let res1 = result1.removeFirst()
                        let res2 = result2.removeFirst()
                        let res3 = result3.removeFirst()

                        work.success((res1, res2, res3))
                        work.isFinished = false
                    }
                }
                .onFail { work.fail() }
        }
        nextWork = WorkWrappper<Void, (Out1, Out2, Out3)>(work: newWork)

        return newWork
    }

//   static var startVoid: Work<Void, Void> {
//        let work = Work<Void, Void>.init {
//            $0.success()
//        }
//        return work.doAsync()
//    }
}

public extension Work where In == Void, Out == Void {
    static var startVoid: Work<Void, Void> {
        let work = Work<Void, Void>.init {
            $0.success()
        }
        return work.doAsync()
    }
}
