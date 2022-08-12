//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 07.08.2022.
//

import Foundation
import UIKit

// MARK: - Right combos

open class Combos<S: SCP>: BaseViewModel<UIStackView>
{
   public let models: S = .init()

   private var isConfigured = false

   @discardableResult
   public func set<M>(_ keypath: KeyPath<S, M>, closure: GenericClosure<M>) -> Self
   {
      let model = models[keyPath: keypath]
      closure(model)
      return self
   }
}

public extension Combos
{
   @discardableResult func setMain<M>(_ setMain: GenericClosure<M>) -> Self where S == SComboM<M>
   {
      setMain(models.main)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   // right

   @discardableResult func setMain<M, R>(
      _ setMain: GenericClosure<M>,
      setRight: GenericClosure<R>) -> Self where S == SComboMR<M, R>
   {
      setMain(models.main)
      setRight(models.right)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, R, R2>(
      _ setMain: GenericClosure<M>,
      setRight: GenericClosure<R>,
      setRight2: GenericClosure<R2>) -> Self where S == SComboMRR<M, R, R2>
   {
      setMain(models.main)
      setRight(models.right)
      setRight2(models.right2)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, R, D>(
      _ setMain: GenericClosure<M>,
      setRight: GenericClosure<R>,
      setDown: GenericClosure<D>) -> Self where S == SComboMRD<M, R, D>
   {
      setMain(models.main)
      setRight(models.right)
      setDown(models.down)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, R, R2, D>(
      _ setMain: GenericClosure<M>,
      setRight: GenericClosure<R>,
      setRight2: GenericClosure<R2>,
      setDown: GenericClosure<D>) -> Self where S == SComboMRRD<M, R, R2, D>
   {
      setMain(models.main)
      setRight(models.right)
      setRight2(models.right2)
      setDown(models.down)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, R, D, R2>(
      _ setMain: GenericClosure<M>,
      setRight: GenericClosure<R>,
      setDown: GenericClosure<D>,
      setRight2: GenericClosure<R2>) -> Self where S == SComboMRDR<M, R, D, R2>
   {
      setMain(models.main)
      setRight(models.right)
      setDown(models.down)
      setRight2(models.right2)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, R, D, D2>(
      _ setMain: GenericClosure<M>,
      setRight: GenericClosure<R>,
      setDown: GenericClosure<D>,
      setDown2: GenericClosure<D2>) -> Self where S == SComboMRDD<M, R, D, D2>
   {
      setMain(models.main)
      setRight(models.right)
      setDown(models.down)
      setDown2(models.down2)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   // down

   @discardableResult func setMain<M, D>(
      _ setMain: GenericClosure<M>,
      setDown: GenericClosure<D>) -> Self where S == SComboMD<M, D>
   {
      setMain(models.main)
      setDown(models.down)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, D, R>(
      _ setMain: GenericClosure<M>,
      setDown: GenericClosure<D>,
      setRight: GenericClosure<R>) -> Self where S == SComboMDR<M, D, R>
   {
      setMain(models.main)
      setDown(models.down)
      setRight(models.right)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, D, D2>(
      _ setMain: GenericClosure<M>,
      setDown: GenericClosure<D>,
      setDown2: GenericClosure<D2>) -> Self where S == SComboMDD<M, D, D2>
   {
      setMain(models.main)
      setDown(models.down)
      setDown2(models.down2)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, D, D2, R>(
      _ setMain: GenericClosure<M>,
      setDown: GenericClosure<D>,
      setDown2: GenericClosure<D2>,
      setRight: GenericClosure<R>) -> Self where S == SComboMDDR<M, D, D2, R>
   {
      setMain(models.main)
      setDown(models.down)
      setDown2(models.down2)
      setRight(models.right)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, D, R, D2>(
      _ setMain: GenericClosure<M>,
      setDown: GenericClosure<D>,
      setRight: GenericClosure<R>,
      setDown2: GenericClosure<D2>) -> Self where S == SComboMDRD<M, D, R, D2>
   {
      setMain(models.main)
      setDown(models.down)
      setRight(models.right)
      setDown2(models.down2)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }

   @discardableResult func setMain<M, D, R, R2>(
      _ setMain: GenericClosure<M>,
      setDown: GenericClosure<D>,
      setRight: GenericClosure<R>,
      setRight2: GenericClosure<R2>) -> Self where S == SComboMDRR<M, D, R, R2>
   {
      setMain(models.main)
      setDown(models.down)
      setRight(models.right)
      setRight2(models.right2)
      if !isConfigured
      {
         configure()
         isConfigured = true
      }
      return self
   }
}
