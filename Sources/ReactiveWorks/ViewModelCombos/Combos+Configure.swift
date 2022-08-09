//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 09.08.2022.
//

import Foundation
import UIKit

private extension Combos
{
   func configureRightStart()
   {
      view.axis = .horizontal
   }

   func configureDownStart()
   {
      view.axis = .vertical
   }

   // makers
   var vertical: UIStackView
   {
      let stack = UIStackView()
      stack.axis = .vertical
      return stack
   }

   var horizontal: UIStackView
   {
      let stack = UIStackView()
      stack.axis = .horizontal
      return stack
   }
}

extension Combos
{
   func configure<M>() where S == SComboM<M>
   {
      configureDownStart()
      view.addArrangedSubview(models.main.uiView)
   }

   // right

   // M R _
   // _ _ _
   // _ _ _
   func configure<M, R>() where S == SComboMR<M, R>
   {
      configureRightStart()
      view.addArrangedSubview(models.main.uiView)
      view.addArrangedSubview(models.right.uiView)
   }

   // M R R
   // _ _ _
   // _ _ _
   func configure<M, R, R2>() where S == SComboMRR<M, R, R2>
   {
      configureRightStart()
      view.addArrangedSubview(models.main.uiView)
      view.addArrangedSubview(models.right.uiView)
      view.addArrangedSubview(models.right2.uiView)
   }

   // M R _
   // _ D _
   // _ _ _
   func configure<M, R, D>() where S == SComboMRD<M, R, D>
   {
      configureRightStart()
      view.addArrangedSubview(models.main.uiView)
      let vert = vertical
      vert.addArrangedSubview(models.right.uiView)
      vert.addArrangedSubview(models.down.uiView)
      view.addArrangedSubview(vert)
   }

   // M R R
   // _ _ D
   // _ _ _
   func configure<M, R, R2, D>() where S == SComboMRRD<M, R, R2, D>
   {
      configureRightStart()
      view.addArrangedSubview(models.main.uiView)
      view.addArrangedSubview(models.right.uiView)
      let vert = vertical
      vert.addArrangedSubview(models.right2.uiView)
      vert.addArrangedSubview(models.down.uiView)
      view.addArrangedSubview(vert)
   }

   // M R R
   // _ D _
   // _ _ _
   func configure<M, R, D, R2>() where S == SComboMRDR<M, R, D, R2>
   {
      configureRightStart()
      view.addArrangedSubview(models.main.uiView)
      let vert = vertical
      vert.addArrangedSubview(models.right.uiView)
      vert.addArrangedSubview(models.down.uiView)
      view.addArrangedSubview(vert)
      view.addArrangedSubview(models.right2.uiView)
   }

   // M R _
   // _ D _
   // _ D _
   func configure<M, R, D, D2>() where S == SComboMRDD<M, R, D, D2>
   {
      configureRightStart()
      view.addArrangedSubview(models.main.uiView)
      let vert = vertical
      vert.addArrangedSubview(models.right.uiView)
      vert.addArrangedSubview(models.down.uiView)
      vert.addArrangedSubview(models.down2.uiView)
      view.addArrangedSubview(vert)
   }

   // down

   // M _ _
   // D _ _
   // _ _ _
   func configure<M, D>() where S == SComboMD<M, D>
   {
      configureDownStart()
      view.addArrangedSubview(models.main.uiView)
      view.addArrangedSubview(models.down.uiView)
   }

   // M _ _
   // D R _
   // _ _ _
   func configure<M, D, R>() where S == SComboMDR<M, D, R>
   {
      configureDownStart()
      view.addArrangedSubview(models.main.uiView)
      let horz = horizontal
      horz.addArrangedSubview(models.down.uiView)
      horz.addArrangedSubview(models.right.uiView)
      view.addArrangedSubview(horz)
   }

   // M _ _
   // D _ _
   // D _ _
   func configure<M, D, D2>() where S == SComboMDD<M, D, D2>
   {
      configureDownStart()
      view.addArrangedSubview(models.main.uiView)
      view.addArrangedSubview(models.down.uiView)
      view.addArrangedSubview(models.down2.uiView)
   }

   // M _ _
   // D _ _
   // D R _
   func configure<M, D, D2, R>() where S == SComboMDDR<M, D, D2, R>
   {
      configureDownStart()
      view.addArrangedSubview(models.main.uiView)
      view.addArrangedSubview(models.down.uiView)
      let horz = horizontal
      horz.addArrangedSubview(models.down2.uiView)
      horz.addArrangedSubview(models.right.uiView)
      view.addArrangedSubview(horz)

   }

   // M _ _
   // D R _
   // D _ _
   func configure<M, D, R, D2>() where S == SComboMDRD<M, D, R, D2>
   {
      configureDownStart()
      view.addArrangedSubview(models.main.uiView)
      let horz = horizontal
      horz.addArrangedSubview(models.down.uiView)
      horz.addArrangedSubview(models.right.uiView)
      view.addArrangedSubview(horz)
      view.addArrangedSubview(models.down2.uiView)
   }

   // M _ _
   // D R R
   // _ _ _
   func configure<M, D, R, R2>() where S == SComboMDRR<M, D, R, R2>
   {
      configureDownStart()
      view.addArrangedSubview(models.main.uiView)
      let horz = horizontal
      horz.addArrangedSubview(models.down.uiView)
      horz.addArrangedSubview(models.right.uiView)
      horz.addArrangedSubview(models.right2.uiView)
      view.addArrangedSubview(horz)
   }
}
