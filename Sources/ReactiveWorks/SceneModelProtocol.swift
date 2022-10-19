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
   func dismiss(animated: Bool)

   var finisher: GenericClosure<Bool>? { get set }
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

   public var finisher: GenericClosure<Bool>?

   public lazy var retainer = Retainer()

   private var isDismissCalled = false

   open func start() {
      vcModel?.on(\.dismiss, self) {
         if !$0.isDismissCalled {
            $0.finisher?(false)
         }
      }
   }

   public func setInput(_ value: Any? = nil) {
      _inputValue = value
   }

   public func dismiss(animated: Bool = true) {
      isDismissCalled = true
      vcModel?.dismiss(animated: animated)
   }

   public func finishSucces() {
      finisher?(true)
      finisher = nil
   }

   public func finishCanceled() {
      finisher?(false)
      finisher = nil
   }

   deinit {
      finisher = nil
      print("DEINIT SceneModel")
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
         vcModel?.on(\.updateInputAfterLoad, self) {
            $0.send(\.input, inputValue)
         }
      }
      return view
   }
}

extension BaseSceneModel: Eventable, Assetable {
   public typealias Events = SceneEvent<Input>
}
