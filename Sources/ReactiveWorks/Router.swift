//
//  Router.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 03.06.2022.
//

import UIKit

enum NavType {
    case push
    case present
    case pop
    case popToRoot
}

final class Router<Scene: InitProtocol>: RouterProtocol, Communicable {
    var eventsStore: Events = .init()

    func start() {}

    struct Events: InitProtocol {
        var push: Eventee<UIViewController>?
        var pop: Eventee<Void>?
        var popToRoot: Eventee<Void>?
        var present: Eventee<UIViewController>?
    }

    func route(_ keypath: KeyPath<Scene, SceneModelProtocol>, navType: NavType, payload: Any? = nil) {
        switch navType {
        case .push:
            sendEvent(\.push, payload: makeVC())
        case .pop:
            sendEvent(\.pop)
        case .popToRoot:
            sendEvent(\.popToRoot)
        case .present:
            sendEvent(\.present, payload: makeVC())
        }

        // local func
        func makeVC() -> UIViewController {
            let sceneModel = Scene()[keyPath: keypath]
            sceneModel.setInput(payload)
            let vc = sceneModel.makeVC()
            return vc
        }
    }
}
