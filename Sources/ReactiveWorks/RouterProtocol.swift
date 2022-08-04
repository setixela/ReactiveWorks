//
//  RouterProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 03.06.2022.
//

protocol RouterProtocol: ModelProtocol, InitProtocol {
    associatedtype Scene: InitProtocol
    func route(_ keypath: KeyPath<Scene, SceneModelProtocol>, navType: NavType, payload: Any?)
}
