//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

import Foundation

public extension Work {
    @discardableResult
    func onSuccess(_ finisher: @escaping (Out) -> Void) -> Self {
        self.finisher.append({ [weak self] value in
            self?.finishQueue.async {
                finisher(value)
            }
        })
        
        return self
    }
    
    @discardableResult
    func onSuccess<S: AnyObject>(_ weakSelf: S, _ finisher: @escaping (S, Out) -> Void) -> Self {
        let clos = { [weak weakSelf, weak self] (result: Out) in
            guard let slf = weakSelf else { return }
            self?.finishQueue.async {
                finisher(slf, result)
            }
        }
        
        self.finisher.append(clos)
        
        return self
    }
    
    @discardableResult
    func onSuccess<S: AnyObject>(_ weakSelf: S, _ finisher: @escaping (S) -> Void) -> Self {
        let clos = { [weak weakSelf, weak self] in
            guard let slf = weakSelf else { return }
            
            self?.finishQueue.async {
                finisher(slf)
            }
        }
        
        voidFinisher.append(clos)
        
        return self
    }
    
    @discardableResult func onSuccess(_ voidFinisher: @escaping () -> Void) -> Self {
        self.voidFinisher.append({ [weak self] in
            self?.finishQueue.async {
                voidFinisher()
            }
        })
        
        return self
    }
    
    @discardableResult func onFail<T>(_ failure: @escaping GenericClosure<T>) -> Self {
        genericFail.append(Lambda(lambda: failure))
        
        return self
    }
    
    @discardableResult
    func onFail<S: AnyObject>(_ weakSelf: S, _ failure: @escaping (S) -> Void) -> Self {
        let clos = { [weak weakSelf] (_: Out) in
            guard let slf = weakSelf else { return }
            failure(slf)
        }
        
        genericFail.append(Lambda(lambda: clos))
        
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
            
            self?.finishQueue.async {
                stateFunc(result, saved)
            }
        }
        
        let lambda = Lambda(lambda: closure)
        successStateFunc.append(lambda)
        
        return self
    }
}