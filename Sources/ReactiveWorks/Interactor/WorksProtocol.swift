//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 27.10.2022.
//

import Foundation

public typealias InitAnyObject = AnyObject & InitProtocol

public protocol WorksProtocol: AnyObject {
   var retainer: Retainer { get }
}

open class BaseSceneWorks<Temp: InitAnyObject, Asset: AssetRoot>: WorksProtocol, TempStorage {
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
