//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 04.02.2023.
//

import Foundation

public class In<I>: Work<I, Void> {
   public typealias Out<O> = Work<I, O>
}

public typealias Out<T> = Work<Void, T>

public typealias InOut<T> = Work<T, T>
