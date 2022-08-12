//
//  UseCaseProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import Foundation

public protocol UseCaseProtocol {
   associatedtype In
   associatedtype Out

   var work: Work<In, Out> { get }
}

