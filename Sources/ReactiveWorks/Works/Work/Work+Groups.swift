//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

import Foundation

public class GroupWork<I, O>: Work<[I], [O]> {
    var count: Int { input?.count ?? 0 } 
    
    public init(_ inputs: In? = nil,
         on: DispatchQueue? = nil,
         _ workClosure: @escaping WorkClosure<In.Element, Out.Element>) {
        //
        super.init(input: inputs ?? [])
        
        result = []
        type = .initGroupClosure
        doQueue = on ?? doQueue
        
        closure = { [weak self] work in
            guard let self else { return }
            
            let index = 0
            let localWork = Work<In.Element, Out.Element>()
            localWork.closure = workClosure
            localWork.input = self.unsafeInput[index]
            
            performWork(localWork, index: index) {
                work.success($0)
            }
        }
        
        // MARK: - Local recursive funcs
        
        // local func
        func performWork(_ work: Work<In.Element, Out.Element>, index: Int, callback: @escaping (Out) -> Void) {
            work
                .doAsync()
                .onSuccess { [weak self] in
                    guard let self else { return }
                    
                    self.result?.append($0)
                    
                    self.signalFunc?.perform(($0, index))
                    
                    if index < self.unsafeInput.count - 1 {
                        let input = self.unsafeInput[index]
                        work.input = input
                        performWork(work, index: index + 1, callback: callback)
                    } else {
                        callback(self.result!)
                    }
                }
                .onFail {[weak self] in
                    guard let self else { return }
                    
                    if index < self.unsafeInput.count - 1 {
                        let input = self.unsafeInput[index]
                        work.input = input
                        performWork(work, index: index + 1, callback: callback)
                    } else {
                        callback(self.result!)
                    }
                }
        }
        
        // local func for optional array
        func performWork(_ work: Work<In.Element, Out.Element>, index: Int, callback: @escaping (Out) -> Void)
        where Out.Element == Any?
        {
            work
                .doAsync()
                .onSuccess { [weak self] in
                    guard let self else { return }
                    
                    self.result!.append($0)
                    self.signalFunc?.perform(($0, index))
                    
                    if index < self.unsafeInput.count - 1 {
                        let input = self.unsafeInput[index]
                        work.input = input
                        performWork(work, index: index + 1, callback: callback)
                    } else {
                        callback(self.result!)
                    }
                }
                .onFail { [weak self] in
                    guard let self else { return }
                    
                    let null = Out.Element?.none
                    
                    self.result!.append(null as Any?)
                    self.signalFunc?.perform((null, index))
                    
                    if index < self.unsafeInput.count - 1 {
                        let input = self.unsafeInput[index]
                        work.input = input
                        performWork(work, index: index + 1, callback: callback)
                    } else {
                        callback(self.result!)
                    }
                }
        }
    }
}


public extension GroupWork {
    @discardableResult
    func onEachResult(_ signal: @escaping (Out.Element?, Int) -> Void) -> Self {
        //
        let signalClosure: ((Out.Element?, Int)) -> Void = { [weak self] tuple in
            self?.finishQueue.async {
                signal(tuple.0, tuple.1)
            }
        }
        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    @discardableResult
    func onEachResult(_ signal: @escaping (Out.Element, Int) -> Void) -> Self  {
        let signalClosure: ((Out.Element, Int)) -> Void = { [weak self] tuple in
            self?.finishQueue.async {
                signal(tuple.0, tuple.1)
            }
        }
        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    @discardableResult func onEachResult<S>(
        _ delegate: Delegate<S>?,
        _ stateFunc: @escaping ((Out.Element?, Int)) -> S
    ) -> Self  {
        //
        let signalClosure: ((Out.Element?, Int)) -> Void = { [weak self, delegate] signal in
            self?.finishQueue.async {
                delegate?(stateFunc((signal.0, signal.1)))
            }
        }

        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    @discardableResult func onEachResult<S>(
        _ delegate: Delegate<S>?,
        _ stateFunc: @escaping ((Out.Element, Int)) -> S
    ) -> Self  {
        //
        let signalClosure: ((Out.Element, Int)) -> Void = { [weak self, delegate] signal in
            self?.finishQueue.async {
                delegate?(stateFunc((signal.0, signal.1)))
            }
        }

        let lambda = Lambda(lambda: signalClosure)

        signalFunc = lambda

        return self
    }

    func doCompactMap<Out2>(on: DispatchQueue? = nil) -> Work<Out, [Out2]> where Out == [Out2?] {
        //
        let work = Work<Out, [Out2]>()
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
