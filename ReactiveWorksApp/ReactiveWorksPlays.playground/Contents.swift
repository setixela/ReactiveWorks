//: A UIKit based Playground for presenting user interface

import PlaygroundSupport
import ReactiveWorks
import UIKit

class MyViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black

        view.addSubview(label)
        self.view = view
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

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

isEnabledDebugThreadNamePrint = false
startWork.retainBy(retainer)
    .doAsync()
    .doInput(input)

    .doNext(groupWork())
    .onEachResult { print("Value: \($0), index: \($1)") }
    .onSuccess { print("\nAll: \($0)\n") }

    .doNext(groupFailedWork())
    .onEachResult { print("Value: \($0), index: \($1)") }
    .onSuccess { print("\nAll: \($0)\n") }

    .doNext(groupWork())
    .onEachResult { print("Value: \($0), index: \($1)") }
    .onSuccess { print("\nAll: \($0)\n") }

    .doNext(groupOptionalWork())
    .onEachResult { print("Value: \(String(describing: $0)), index: \($1)") }
    .onSuccess { print("\nAll: \($0)\n") }

    .doNext(groupOptFailWork())
    .onEachResult { print("Value: \(String(describing: $0)), index: \($1)") }
    .onSuccess { print("\nAll: \($0)\n") }

    .doNext(groupWork())
    .onEachResult { print("Value: \($0), index: \($1)") }
    .onSuccess { print("\nAll: \($0)\n") }

    .doNext(GroupWork<String, Int?> {
        guard let intVal = Int($0.unsafeInput) else { $0.fail(); return }

        if intVal % 8 == 0 {
            $0.success(intVal)
        } else {
            $0.success(nil)
        }
    })
    .onEachResult { print("Value: \(String(describing: $0)), index: \($1)") }
    .onSuccess { print("\nAll: \($0)\n") }

    .doCompactMap()
    .onSuccess { print("\nAll: \($0)\n") }
