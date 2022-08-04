//
//  Model.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 28.05.2022.
//

import Foundation

public protocol ModelProtocol: AnyObject {
   func start()
}

public class BaseModel: NSObject, ModelProtocol {
   public func start() {
      print("Needs to override start()")
   }

   override required init() {
      super.init()
      start()
   }
}
