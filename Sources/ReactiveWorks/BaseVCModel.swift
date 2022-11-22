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
   //
   var currentStatusBarStyle: UIStatusBarStyle? { get set }
   var currentBarStyle: UIBarStyle? { get set }
   var currentBarTintColor: UIColor? { get set }
   var currentTitleColor: UIColor? { get set }
   var currentBarTranslucent: Bool? { get set }
   var currentBarBackColor: UIColor? { get set }
   var currentTitleAlpha: CGFloat? { get set }

   init(sceneModel: SceneModelProtocol)
}

open class BaseVCModel: UIViewController, VCModelProtocol {


   public let sceneModel: SceneModelProtocol

   public lazy var baseView: UIView = sceneModel.makeMainView()

   public var events: EventsStore = .init()

   public var currentStatusBarStyle: UIStatusBarStyle?
   public var currentBarStyle: UIBarStyle?
   public var currentBarTintColor: UIColor?
   public var currentTitleColor: UIColor?
   public var currentBarTranslucent: Bool?
   public var currentBarBackColor: UIColor?
   public var currentTitleAlpha: CGFloat?

   override open var preferredStatusBarStyle: UIStatusBarStyle {
      currentStatusBarStyle ?? .default
   }

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
