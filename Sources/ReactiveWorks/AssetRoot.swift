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
   associatedtype Design: DesignRoot

   associatedtype Router: InitProtocol

   typealias Asset = Self
   typealias Text = Design.Text
}

public extension AssetRoot {
   static var scene: Scene { .init() }
   static var service: Service { .init() }
   static var design: Design { .init() }

   static var text: Text { .init() }

   static var router: Router { .init() }
}

public protocol DesignRoot: InitProtocol {
   associatedtype Text: InitProtocol
   associatedtype Color: InitProtocol
   associatedtype Icon: InitProtocol
   associatedtype Font: InitProtocol
   associatedtype Label: InitProtocol
   associatedtype Button: InitProtocol

   associatedtype State: InitProtocol

   associatedtype Params: InitProtocol
}
