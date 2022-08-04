//
//  VlerProtocol.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 28.05.2022.
//

import UIKit

final class DefaultVCModel: BaseVCModel {
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

    override func viewDidLoad() {
        super.viewDidLoad()

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

        sendEvent(\.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sendEvent(\.viewWillAppear)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sendEvent(\.viewWillDissappear)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
