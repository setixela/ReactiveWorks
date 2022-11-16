//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 16.11.2022.
//

import UIKit

public extension VCModelProtocol {
   @discardableResult func clearBackButton() -> Self {
      navigationController?.navigationBar.topItem?.backBarButtonItem
      = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

      return self
   }

   @discardableResult func titleModel(_ value: UIViewModel) -> Self {
      navigationItem.titleView = value.uiView
      return self
   }
}
