//: A UIKit based Playground for presenting user interface

import PlaygroundSupport
import ReactiveWorks
import UIKit

final class MyViewController: UIViewController {
    private let stackView = UIStackView()

    override func loadView() {
        stackView.axis = .vertical
        stackView.backgroundColor = .white
        stackView.addArrangedSubview(.init())

        view = UIView()
        view.frame = .init(x: 0, y: 0, width: 360, height: 940)

        stackView.frame = view.bounds

        view.addSubview(stackView)
    }
}

enum State {
    case label(String)
}

extension MyViewController: StateMachine {
    func setState(_ state: State) {
        switch state {
        case let .label(text):
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .bold)
            label.text = text

            stackView.addArrangedSubview(label)
        }
    }
}

// Present the view controller in the Live View window
let vc = MyViewController()
PlaygroundPage.current.liveView = vc

let retainer = Retainer()

let singleWork = Work<Int, String> {
    $0.success(String($0.unsafeInput))
}

let singleFailedWork = Work<String, Int> {
    guard let intVal = Int($0.unsafeInput) else { $0.fail(); return }

    if intVal % 2 == 0 {
        $0.success(intVal)
    } else {
        $0.fail()
    }
}

let singleOptWork = Work<String, Int?> {
    guard let intVal = Int($0.unsafeInput) else { $0.fail(); return }

    if intVal % 4 == 0 {
        $0.success(intVal)
    } else {
        $0.success(nil)
    }
}

let singleOptFailedWork = Work<Int?, Int> {
    guard
        let intVal = $0.unsafeInput else { $0.fail(); return }

    if intVal % 4 == 0 {
        $0.success(intVal)
    } else {
        $0.fail()
    }
}

var groupWork = { GroupWork<Int, String>(work: singleWork) }
var groupFailedWork = { GroupWork<String, Int>(work: singleFailedWork) }
var groupOptionalWork = { GroupWork<String, Int?>(work: singleOptWork) }
var groupOptFailWork = { GroupWork<Int?, Int>(work: singleOptFailedWork) }

let input = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

let startWork = Work<Void, Void>() { $0.success() }

isEnabledDebugThreadNamePrint = true
let setState = vc.stateDelegate

startWork.retainBy(retainer)
    .doAsync()
    .doInput(input)

    .doNext(groupWork())
    .onEachResult(setState) { .label("Value: \($0), index: \($1)") }
    .onSuccess(setState) { allResult($0) }

    .doNext(groupFailedWork())
    .onEachResult(setState) { .label("Value: \($0), index: \($1)") }
    .onSuccess(setState) { allResult($0) }

    .doNext(groupWork())
    .onEachResult(setState) { .label("Value: \($0), index: \($1)") }
    .onSuccess(setState) { allResult($0) }

    .doNext(groupOptionalWork())
    .onEachResult(setState) { .label("Value: \(String(describing: $0)), index: \($1)") }
    .onSuccess(setState) { allResult($0) }

    .doNext(groupOptFailWork())
    .onEachResult(setState) { .label("Value: \($0), index: \($1)") }
    .onSuccess(setState) { allResult($0) }

    .doNext(groupWork())
    .onEachResult(setState) { .label("Value: \($0), index: \($1)") }
    .onSuccess(setState) { allResult($0) }

    .doNext(GroupWork<String, Int?> {
        guard let intVal = Int($0.unsafeInput) else { $0.fail(); return }

        if intVal % 8 == 0 {
            $0.success(intVal)
        } else {
            $0.success(nil)
        }
    })
    .onEachResult(setState) { .label("Value: \(String(describing: $0)), index: \($1)") }
    .onSuccess(setState) { allResult($0) }

    .doCompactMap()
    .onSuccess(setState) { allResult($0) }

func allResult(_ anyres: Any) -> [State] { [
    .label("----------------"),
    .label("All: \(anyres)"),
    .label("----------------"),
] }
