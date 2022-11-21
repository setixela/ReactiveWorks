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

   @discardableResult func title(_ value: String) -> Self {
      title = value
      return self
   }

   @discardableResult func titleColor(_ value: UIColor) -> Self {
      let textAttributes = [NSAttributedString.Key.foregroundColor: value]
      navigationController?.navigationBar.titleTextAttributes = textAttributes
      return self
   }

   @discardableResult func titleAlpha(_ value: CGFloat) -> Self {
      navigationItem.titleView?.alpha = value
      return self
   }

   @discardableResult func leftBarItems(_ value: [UIBarButtonItem]) -> Self {
      navigationItem.leftBarButtonItems = value
      return self
   }

   @discardableResult func rightBarItems(_ value: [UIBarButtonItem]) -> Self {
      navigationItem.rightBarButtonItems = value
      return self
   }

   @discardableResult func barStyle(_ value: UIBarStyle) -> Self {
      navigationController?.navigationBar.barStyle = value
      return self
   }

   @discardableResult func statusBarStyle(_ value: UIStatusBarStyle) -> Self {
      currentStatusBarStyle = value
      setNeedsStatusBarAppearanceUpdate()
      return self
   }
}
