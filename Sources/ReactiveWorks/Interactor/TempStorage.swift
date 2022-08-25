//
//  SceneWorks.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 11.08.2022.
//

import Foundation

public typealias InitAnyObject = AnyObject & InitProtocol

open class BaseSceneWorks<Temp: InitAnyObject, Asset: AssetRoot>: TempStorage {
   public lazy var retainer = Retainer()

   public required init() {
      UnsafeTemper.initStore(for: Temp.self)
   }

   deinit {
      UnsafeTemper.clearStore(for: Temp.self)
   }

   public static var store: Temp {
      UnsafeTemper.store(for: Temp.self)
   }
}

// MARK: - Temp single type storage

public protocol TempStorage: InitProtocol, Assetable {
   associatedtype Temp: InitAnyObject

   static var store: Temp { get }
}

// TODO: - need to change conception

enum UnsafeTemper {
   private static var storage: [String: InitAnyObject] = [:]

   static func initStore(for type: InitAnyObject.Type) {
      let key = String(reflecting: type)
      let new = type.init()

      storage[key] = new
   }

   static func store<T: InitAnyObject>(for type: T.Type) -> T {
      let key = String(reflecting: type)

      guard let value = storage[key] as? T else {
         return T()
      }

      return value
   }

   static func clearStore(for type: InitAnyObject.Type) {
      let key = String(reflecting: type)

      storage[key] = nil
   }
}
