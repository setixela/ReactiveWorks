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

open class BaseModel: NSObject, ModelProtocol {
   open func start() {
      print("Needs to override start()")
   }

   public override required init() {
      super.init()
      start()
   }
}
