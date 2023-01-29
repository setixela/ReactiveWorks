//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

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
