//
//  VlerProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 28.05.2022.
//

import UIKit

public final class DefaultVCModel: BaseVCModel {
   private lazy var tapGesture = UITapGestureRecognizer(target: self,
                                                        action: #selector(hideKeyboard))

   private var isKeyboardShown = false
   private var baseHeight: CGFloat = 0

   required init(sceneModel: SceneModelProtocol) {
      super.init(sceneModel: sceneModel)

      onEvent(\.setTitle) { [weak self] title in
         self?.title = title
      }
      .onEvent(\.setNavBarTintColor) { [weak self] color in
         let textAttributes = [NSAttributedString.Key.foregroundColor: color]
         self?.navigationController?.navigationBar.titleTextAttributes = textAttributes
      }
      .onEvent(\.setTitleAlpha) { [weak self] alpha in
         self?.navigationItem.titleView?.alpha = alpha
      }
      .onEvent(\.setLeftBarItems) { [weak self] items in
         self?.navigationItem.leftBarButtonItems = items
      }
      .onEvent(\.setRightBarItems) { [weak self] items in
         self?.navigationItem.rightBarButtonItems = items
      }
      .onEvent(\.dismiss) { [weak self] in
         self?.dismiss(animated: true)
      }
   }

   override public func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white

      navigationController?.navigationBar.isUserInteractionEnabled = false
      sendEvent(\.viewDidLoad)
   }

   override public func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      navigationController?.navigationBar.isUserInteractionEnabled = false
      navigationController?.navigationBar.backgroundColor = .clear

      NotificationCenter.default.addObserver(
         self,
         selector: #selector(keyboardWillShow),
         name: UIResponder.keyboardWillShowNotification,
         object: view.window)
      NotificationCenter.default.addObserver(
         self,
         selector: #selector(keyboardWillHide),
         name: UIResponder.keyboardWillHideNotification,
         object: view.window)

      sendEvent(\.viewWillAppear)
   }

   override public func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)

      NotificationCenter.default.removeObserver(
         self,
         name: UIResponder.keyboardWillShowNotification,
         object: view.window)
      NotificationCenter.default.removeObserver(
         self,
         name: UIResponder.keyboardWillHideNotification,
         object: view.window)

      hideKeyboard()

      sendEvent(\.viewWillDissappear)
   }

   @objc func keyboardWillShow(notification: NSNotification) {

      var time = 0.0
      if isKeyboardShown == false {
         baseHeight = view.frame.size.height
         view.addGestureRecognizer(tapGesture)
         time = 0.3
      }

      let keysHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
         .cgRectValue.height ?? 0

      UIView.animate(withDuration: time) {
         self.view.rootSuperview.frame.size.height = self.baseHeight - keysHeight
         self.view.layoutIfNeeded()
         self.view.rootSuperview.layoutIfNeeded()
      }

      isKeyboardShown = true
   }

   @objc func keyboardWillHide(notification: NSNotification) {
      guard isKeyboardShown else { return }

      view.removeGestureRecognizer(tapGesture)
      view.rootSuperview.frame.size.height = baseHeight
      isKeyboardShown = false
   }

    @objc public func hideKeyboard() {
      view.endEditing(true)
   }
}

public extension UIView {
   var rootSuperview: UIView {
      var view = self
      while let s = view.superview {
         view = s
      }
      return view
   }
}
