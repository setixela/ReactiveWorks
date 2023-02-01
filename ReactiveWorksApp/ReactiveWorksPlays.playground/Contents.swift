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

isEnabledDebugThreadNamePrint = false
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

class Eventer1: Eventable {
    struct Events: InitProtocol {
        var value: Int?
    }
    
    var events: EventsStore = .init()
    
    func start() {
        DispatchQueue.global.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            for i in 0 ... 1000 {
                self?.send(\.value, i)
            }
        }
    }
}

class Eventer2: Eventable {
    struct Events: InitProtocol {
        var value: Int?
    }
    
    var events: EventsStore = .init()
    
    func start() {
        DispatchQueue.globalBackground.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            for i in 0 ... 1000 {
                self?.send(\.value, i)
            }
        }
    }
}

class Eventer3: Eventable {
    struct Events: InitProtocol {
        var value: Int?
    }
    
    var events: EventsStore = .init()
    
    func start() {
        DispatchQueue.globalBackground.asyncAfter(deadline: .now() + 1) { [weak self] in
            for i in 0 ... 1000 {
                self?.send(\.value, i)
            }
        }
    }
}

let eventer1 = Eventer1()
let eventer2 = Eventer2()
let eventer3 = Eventer3()

let eventerWork1 = eventer1.on(\.value)
let eventerWork2 = eventer2.on(\.value)
let eventerWork3 = eventer3.on(\.value)

Work.startVoid
    .retainBy(retainer)
    .doCombineBuffered(eventerWork1, eventerWork2, eventerWork3)
    .onSuccess {
        print("Combined: \($0) - \($1) - \($2)")
    }
    .doNext { work in
        let val = work.unsafeInput
        work.success(val.0 + val.1 + val.2)
    }
    .onSuccess {
        print("Sum: ", $0)
    }

eventer1.start()
eventer2.start()
eventer3.start()

