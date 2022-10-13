//
//  InitProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 17.06.2022.
//

public protocol InitProtocol {
   init()
}

public protocol InitClassProtocol: InitProtocol, AnyObject {}

public protocol BuilderProtocol: InitProtocol {
   associatedtype Builder

   var builder: Builder { get }
}

open class BaseClass: InitProtocol {
   public required init() {}
}
