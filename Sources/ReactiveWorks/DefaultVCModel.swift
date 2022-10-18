//
//  VlerProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 28.05.2022.
//

import UIKit

public final class DefaultVCModel: BaseVCModel {
   private lazy var tapGesture = {
      let gest = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
      gest.cancelsTouchesInView = true
      return gest
   }()

   private static var isKeyboardShown = false
   private var baseHeight: CGFloat = 0

   required init(sceneModel: SceneModelProtocol) {
      super.init(sceneModel: sceneModel)

      on(\.setTitle) { [weak self] title in
         self?.title = title
      }
      .on(\.setNavBarTintColor) { [weak self] color in
         let textAttributes = [NSAttributedString.Key.foregroundColor: color]
         self?.navigationController?.navigationBar.titleTextAttributes = textAttributes
      }
      .on(\.setTitleAlpha) { [weak self] alpha in
         self?.navigationItem.titleView?.alpha = alpha
      }
      .on(\.setLeftBarItems) { [weak self] items in
         self?.navigationItem.leftBarButtonItems = items
      }
      .on(\.setRightBarItems) { [weak self] items in
         self?.navigationItem.rightBarButtonItems = items
      }
   }

   override public func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white
      navigationController?.navigationBar.backgroundColor = .clear

      send(\.viewDidLoad)
   }

   override public func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

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

      send(\.viewWillAppear)

      baseHeight = UIView.keyWindow.frame.height
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

      send(\.viewWillDissappear)

      if isBeingDismissed {
         send(\.dismiss)
      }
   }

   @objc func keyboardWillShow(notification: NSNotification) {
      let time = 0.3

      let keysHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
         .cgRectValue.height ?? 0

      guard !DefaultVCModel.isKeyboardShown else {
         UIView.keyWindow.frame.size.height = baseHeight - keysHeight
         return
      }

      baseHeight = UIView.keyWindow.frame.size.height

      DefaultVCModel.isKeyboardShown = true
      UIView.keyWindow.addGestureRecognizer(tapGesture)
      UIView.animate(withDuration: time) {
         UIView.keyWindow.frame.size.height = self.baseHeight - keysHeight
         UIView.keyWindow.layoutIfNeeded()
         self.view.layoutIfNeeded()
      }
   }

   @objc func keyboardWillHide(notification: NSNotification) {
      guard DefaultVCModel.isKeyboardShown else { return }

      UIView.keyWindow.removeGestureRecognizer(tapGesture)
      UIView.keyWindow.frame.size.height = baseHeight
      DefaultVCModel.isKeyboardShown = false
   }

   @objc public func hideKeyboard() {
      UIView.keyWindow.removeGestureRecognizer(tapGesture)
      view.endEditing(true)
   }
}

public extension UIView {
   static var keyWindow: UIView {
      UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIView()
   }

   var rootSuperview: UIView {
      var view = self
      while let s = view.superview {
         view = s
      }
      return view
   }

   var rootSuperviewPlusOne: UIView {
      var view = self
      while let s = view.superview {
         view = s
      }
      return self
   }
}

/// Passes through all touch events to views behind it, except when the
/// touch occurs in a contained UIControl or view with a gesture
/// recognizer attached
extension UINavigationBar {
   override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
      guard nestedInteractiveViews(in: self, contain: point) else { return false }
      return super.point(inside: point, with: event)
   }

   private func nestedInteractiveViews(in view: UIView, contain point: CGPoint) -> Bool {
      if view.isPotentiallyInteractive, view.bounds.contains(convert(point, to: view)) {
         return true
      }

      for subview in view.subviews {
         if nestedInteractiveViews(in: subview, contain: point) {
            return true
         }
      }

      return false
   }
}

private extension UIView {
   var isPotentiallyInteractive: Bool {
      guard isUserInteractionEnabled else { return false }
      return (isControl || doesContainGestureRecognizer)
   }

   var isControl: Bool {
      self is UIControl
   }

   var doesContainGestureRecognizer: Bool {
      !(gestureRecognizers?.isEmpty ?? true)
   }
}
