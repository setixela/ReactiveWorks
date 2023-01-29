//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

import Foundation

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
    
    func doCompactMap<Val>(on: DispatchQueue? = nil) -> Work<Out, [Val]>
    where Out == [Val?]
    {
        let work = Work<Out, [Val]>()
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
