//
//  Lambda.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 17.06.2022.
//

import Foundation

public typealias VoidClosure = () -> Void
public typealias GenericClosure<T> = (T) -> Void
public typealias Eventee<T> = (T) -> Void

public protocol LambdaProtocol {
   func perform<AnyType>(_ value: AnyType)
}

/// Lambda wrapper
public struct Lambda<T>: LambdaProtocol where T: Any {
   public func perform<AnyType>(_ value: AnyType) where AnyType: Any {
      guard let value = value as? T else {
         print("Lambda payloads not conform: {\(value.self)} is not {\(T.self)}")
         return
      }

      lambda(value)
   }

   let lambda: Eventee<T>
}
