//
//  BaseVCModel.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 04.06.2022.
//

import UIKit

public struct VCEvent: InitProtocol {
   public var viewDidLoad: Void?
   public var updateInputAfterLoad: Void?
   public var viewWillAppear: Void?
   public var viewWillDissappear: Void?

   public var dismiss: Void?

   public var motionEnded: UIEvent.EventSubtype?
   //
   public init() {}
}

public protocol VCModelProtocol: UIViewController, Eventable where Events == VCEvent {
   var sceneModel: SceneModelProtocol { get }

   init(sceneModel: SceneModelProtocol)
}

open class BaseVCModel: UIViewController, VCModelProtocol {
   public let sceneModel: SceneModelProtocol

   public lazy var baseView: UIView = sceneModel.makeMainView()

   public var events: EventsStore = .init()

   public required init(sceneModel: SceneModelProtocol) {
      self.sceneModel = sceneModel

      super.init(nibName: nil, bundle: nil)
   }

   override public func loadView() {
      view = baseView
   }

   @available(*, unavailable)
   public required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}
