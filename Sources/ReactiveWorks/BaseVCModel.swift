//
//  BaseVCModel.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 04.06.2022.
//

import UIKit

public struct VCEvent: InitProtocol {
   public var viewDidLoad: Event<Void>?
   public var viewWillAppear: Event<Void>?
   public var viewWillDissappear: Event<Void>?

   // setup
   public var setTitle: Event<String>?
   public var setLeftBarItems: Event<[UIBarButtonItem]>?
   public var setRightBarItems: Event<[UIBarButtonItem]>?

   //
   public init() {}
}

public protocol VCModelProtocol: UIViewController, Communicable where Events == VCEvent {
   var sceneModel: SceneModelProtocol { get }

   init(sceneModel: SceneModelProtocol)
}

open class BaseVCModel: UIViewController, VCModelProtocol {
   public let sceneModel: SceneModelProtocol

   public lazy var baseView: UIView = sceneModel.makeMainView()

   public var eventsStore: VCEvent = .init()

   public required init(sceneModel: SceneModelProtocol) {
      self.sceneModel = sceneModel

      super.init(nibName: nil, bundle: nil)
   }

   override public func loadView() {
      view = baseView
   }

   @available(*, unavailable)
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}
