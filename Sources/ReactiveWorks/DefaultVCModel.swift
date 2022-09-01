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
     // guard !isKeyboardShown else { return }

      var time = 0.0
      if isKeyboardShown == false {
         baseHeight = view.frame.size.height
         view.addGestureRecognizer(tapGesture)
         time = 0.3
      }

//      let maxY = view.subviews
//         .flatMap { $0.subviews.flatMap { $0.subviews.map { $0 } } }
//         .filter { $0 is UIButton || $0 is UITextView || $0 is UITextField }
//         .reduce(CGFloat(0)) { partialResult, button in
//            let gPoint = button.convert(button.bounds, to: self.view)
//            let maxY = gPoint.origin.y + button.frame.size.height
//            let result = partialResult < maxY
//               ? maxY
//               : partialResult
//            return result
//         }
//
//      let viewHeight = view.frame.height
      let keysHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
         .cgRectValue.height ?? 0
//      let keysTop = viewHeight - keysHeight
//
//      let diff = keysTop - maxY
//
//      if diff < 0 {

      UIView.animate(withDuration: time) {
         self.view.frame.size.height = self.baseHeight - keysHeight
         self.view.layoutIfNeeded()
      }
//      }

      isKeyboardShown = true
   }

   @objc func keyboardWillHide(notification: NSNotification) {
      guard isKeyboardShown else { return }

      view.removeGestureRecognizer(tapGesture)
      view.frame.size.height = baseHeight
      isKeyboardShown = false
   }

   @objc func hideKeyboard() {
      view.endEditing(true)
   }
}

extension UIView {
   var rootSuperview: UIView {
      var view = self
      while let s = view.superview {
         view = s
      }
      return view
   }
}
