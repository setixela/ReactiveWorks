//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 18.08.2023.
//

import Foundation

open class MapWork<I, O>: Work<I, O> {
    required public init() {
        fatalError()
    }

    public init(_ map: @escaping (I) -> O?) {
        super.init { work in
            if let input = work.input, let result = map(input) {
                work.success(result)
            } else {
                work.fail()
            }
        }
    }
}

public typealias MapOut<O> = MapWork<Void, O>
public typealias MapInOut<I> = MapWork<I, I>

public class MapIn<I>: MapWork<I, Void> {
    public typealias MapOut<O> = MapWork<I, O>
}
