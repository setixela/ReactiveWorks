//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

// MARK: - Result with states

public extension Work {
    @discardableResult func onSuccess<S>(_ delegate: Delegate<S>?,
                                         _ stateFunc: @escaping (Out) -> S) -> Self
    {
        let closure: GenericClosure<Out> = { [weak self, delegate] result in
            self?.finishQueue.async {
                delegate?(stateFunc(result))
            }
        }
        
        let lambda = Lambda(lambda: closure)
        successStateFunc = lambda
        
        return self
    }
    
    @discardableResult func onFail<S>(_ delegate: Delegate<S>?, _ state: S) -> Self {
        let closure: GenericClosure<Void> = { [weak self, delegate] _ in
            self?.finishQueue.async {
                delegate?(state)
            }
        }
        
        let lambda = Lambda(lambda: closure)
        failStateVoidFunc = lambda
        
        return self
    }
    
    @discardableResult func onFail<S, T>(_ delegate: Delegate<S>?,
                                         _ stateFunc: @escaping (T) -> S) -> Self
    {
        let closure: GenericClosure<T> = { [weak self, delegate] failValue in
            self?.finishQueue.async {
                delegate?(stateFunc(failValue))
            }
        }
        
        let lambda = Lambda(lambda: closure)
        failStateFunc = lambda
        
        return self
    }
}

// MARK: - Variadic states

public extension Work {
    @discardableResult func onSuccess<S>(_ delegate: Delegate<S>?, _ states: S...) -> Self {
        let closure: GenericClosure<Void> = { [weak self, delegate] _ in
            self?.finishQueue.async {
                states.forEach {
                    delegate?($0)
                }
            }
        }
        
        let lambda = Lambda(lambda: closure)
        successStateVoidFunc = lambda
        
        return self
    }
    
    @discardableResult func onSuccess<S>(_ delegate: Delegate<S>?,
                                         _ stateFunc: @escaping (Out) -> [S]) -> Self
    {
        let closure: GenericClosure<Out> = { [weak self, delegate] result in
            self?.finishQueue.async {
                stateFunc(result).forEach {
                    delegate?($0)
                }
            }
        }
        
        let lambda = Lambda(lambda: closure)
        successStateFunc = lambda
        
        return self
    }
    
    @discardableResult func onSuccess<S>(_ delegate: Delegate<S>?,
                                         _ stateFunc: @escaping (Out, ((S) -> Void)?) -> Void) -> Self
    {
        let closure: GenericClosure<Out> = { [weak self, delegate] result in
            self?.finishQueue.async {
                stateFunc(result, delegate)
            }
        }
        
        let lambda = Lambda(lambda: closure)
        successStateFunc = lambda
        
        return self
    }
    
    @discardableResult func onFail<S>(_ delegate: Delegate<S>?, _ states: S...) -> Self {
        let closure: GenericClosure<Void> = { [weak self, delegate] _ in
            self?.finishQueue.async {
                states.forEach {
                    delegate?($0)
                }
            }
        }
        
        let lambda = Lambda(lambda: closure)
        failStateVoidFunc = lambda
        
        return self
    }
    
    @discardableResult func onFail<S, T>(_ delegate: Delegate<S>?,
                                         _ stateFunc: @escaping (T) -> [S]) -> Self
    {
        let closure: GenericClosure<T> = { [weak self, delegate] failValue in
            self?.finishQueue.async {
                stateFunc(failValue).forEach {
                    delegate?($0)
                }
            }
        }
        
        let lambda = Lambda(lambda: closure)
        failStateFunc = lambda
        
        return self
    }
    
    @discardableResult func onFail<S, T>(_ delegate: Delegate<S>?,
                                         _ stateFunc: @escaping (T, ((S) -> Void)?) -> Void) -> Self
    {
        let closure: GenericClosure<T> = { [weak self, delegate] failValue in
            self?.finishQueue.async {
                stateFunc(failValue, delegate)
            }
        }
        
        let lambda = Lambda(lambda: closure)
        failStateFunc = lambda
        
        return self
    }
}

public extension Work {
    @discardableResult
    func onSuccessMixSaved<S, OutSaved>(_ delegate: Delegate<S>?,
                                        _ stateFunc: @escaping ((Out, OutSaved)) -> S) -> Self
    {
        let closure: GenericClosure<Out> = { [weak self, delegate] result in
            guard let savedResultClosure = self?.savedResultClosure else {
                assertionFailure("savedResultClosure is nil")
                return
            }
            
            let savedValue = savedResultClosure()
            
            guard let saved = savedValue as? OutSaved else {
                assertionFailure("saved value is not \(OutSaved.self)")
                return
            }
            
            self?.finishQueue.async {
                delegate?(stateFunc((result, saved)))
            }
        }
        
        let lambda = Lambda(lambda: closure)
        successStateFunc = lambda
        
        return self
    }
    
    @discardableResult
    func onFailMixSaved<S, OutSaved>(_ delegate: Delegate<S>?,
                                     _ stateFunc: @escaping ((Out, OutSaved)) -> S) -> Self
    {
        let closure: GenericClosure<Out> = { [weak self, delegate] result in
            guard let savedResultClosure = self?.savedResultClosure else {
                assertionFailure("savedResultClosure is nil")
                return
            }
            
            let savedValue = savedResultClosure()
            
            guard let saved = savedValue as? OutSaved else {
                assertionFailure("saved value is not \(OutSaved.self)")
                return
            }
            
            self?.finishQueue.async {
                delegate?(stateFunc((result, saved)))
            }
        }
        
        let lambda = Lambda(lambda: closure)
        failStateFunc = lambda
        
        return self
    }
}
