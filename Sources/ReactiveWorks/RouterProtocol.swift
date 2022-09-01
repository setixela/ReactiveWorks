//
//  RouterProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 03.06.2022.
//

import UIKit
public protocol NavigateProtocol {
   var nc: UINavigationController { get }

   func start()
}

public protocol RouterProtocol: NavigateProtocol{
//    associatedtype Scene: InitProtocol
//    func route(_ keypath: KeyPath<Scene, SceneModelProtocol>, navType: NavType, payload: Any?)
}
