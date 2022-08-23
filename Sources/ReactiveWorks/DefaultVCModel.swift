//
//  VlerProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 28.05.2022.
//

import UIKit

public final class DefaultVCModel: BaseVCModel {
   required init(sceneModel: SceneModelProtocol) {
      super.init(sceneModel: sceneModel)

      onEvent(\.setTitle) { [weak self] title in
         self?.title = title
      }
      .onEvent(\.setLeftBarItems) { [weak self] items in
         self?.navigationItem.leftBarButtonItems = items
      }
      .onEvent(\.setRightBarItems) { [weak self] items in
         self?.navigationItem.rightBarButtonItems = items
      }
   }

   override public func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white

      NotificationCenter.default.addObserver(
         self,
         selector: #selector(self.keyboardWillShow),
         name: UIResponder.keyboardWillShowNotification,
         object: nil)
      NotificationCenter.default.addObserver(
         self,
         selector: #selector(self.keyboardWillHide),
         name: UIResponder.keyboardWillHideNotification,
         object: nil)
      navigationController?.navigationBar.isUserInteractionEnabled = false
      sendEvent(\.viewDidLoad)

   }

   override public func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      navigationController?.navigationBar.isUserInteractionEnabled = false
      navigationController?.navigationBar.backgroundColor = .clear

      sendEvent(\.viewWillAppear)
   }

   override public func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)

      sendEvent(\.viewWillDissappear)
   }

   @objc func keyboardWillShow(notification: NSNotification) {
      if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
         if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardSize.height / 3.5
         }
      }
   }

   @objc func keyboardWillHide(notification: NSNotification) {
      if self.view.frame.origin.y != 0 {
         self.view.frame.origin.y = 0
      }
   }
}
