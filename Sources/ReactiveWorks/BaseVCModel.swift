//
//  BaseVCModel.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 04.06.2022.
//

import UIKit

public struct VCEvent: InitProtocol {
   public var viewDidLoad: Eventee<Void>?
   public var viewWillAppear: Eventee<Void>?
   public var viewWillDissappear: Eventee<Void>?

   // setup
   public var setTitle: Eventee<String>?
   public var setLeftBarItems: Eventee<[UIBarButtonItem]>?
   public var setRightBarItems: Eventee<[UIBarButtonItem]>?

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
   public required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}
