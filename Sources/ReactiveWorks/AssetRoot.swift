//
//  AssetRoot.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 04.08.2022.
//

import Foundation

public protocol AssetRoot {
   associatedtype Scene: InitProtocol
   associatedtype Service: InitProtocol
   associatedtype Design: InitProtocol
   associatedtype Text: InitProtocol
   associatedtype Router: InitProtocol

   typealias Asset = Self
}

public extension AssetRoot {
   static var scene: Scene { .init() }
   static var service: Service { .init() }
   static var design: Design { .init() }
   static var text: Text { .init() }
   static var router: Router { .init() }
}
