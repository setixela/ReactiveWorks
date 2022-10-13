//
//  Scene.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 28.05.2022.
//

import UIKit

public protocol SceneModelProtocol: ModelProtocol {
   func makeVC() -> UIViewController
   func makeMainView() -> UIView
   func setInput(_ value: Any?)

   var finisher: Work<Bool, Bool>? { get set }
}

public protocol SceneModel: SceneModelProtocol {
   associatedtype VCModel: VCModelProtocol
   associatedtype MainViewModel: ViewModelProtocol

   var vcModel: VCModel? { get set }
   var mainVM: MainViewModel { get }
}

public struct SceneEvent<Input>: InitProtocol {
   public var input: Input?
   public var finished: Void?

   public init() {}
}

public protocol Assetable {
   associatedtype Asset: AssetRoot

   typealias Design = Asset.Design
   typealias Service = Asset.Service
   typealias Scene = Asset.Scene
   typealias Text = Asset.Design.Text
}

open class BaseSceneModel<
   VCModel: VCModelProtocol,
   MainViewModel: ViewModelProtocol,
   Asset: AssetRoot,
   Input
>: NSObject, SceneModel {

   private var _inputValue: Any?

   public lazy var mainVM = MainViewModel()

   public weak var vcModel: VCModel?

   public var inputValue: Input? { _inputValue as? Input }

   public var events: EventsStore = .init()

   public var finisher: Work<Bool, Bool>?

   public lazy var retainer = Retainer()

   open func start() {}

   public func setInput(_ value: Any? = nil) {
      _inputValue = value
   }

   deinit {
      finisher = nil
   }
}

public extension BaseSceneModel {
   func makeVC() -> UIViewController {
      let model = VCModel(sceneModel: self)
      vcModel = model
      return model
   }

   func makeMainView() -> UIView {
      let view = mainVM.uiView
      start()
      if let inputValue {
         send(\.input, inputValue)
      }
      return view
   }
}

extension BaseSceneModel: Eventable, Assetable {
   public typealias Events = SceneEvent<Input>
}
