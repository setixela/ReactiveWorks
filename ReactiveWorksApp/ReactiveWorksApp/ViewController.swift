//
//  ViewController.swift
//  ReactiveWorksApp
//
//  Created by Aleksandr Solovyev on 30.01.2023.
//

import ReactiveWorks
import UIKit

class ViewController: UIViewController {
    let eventer1 = Eventer1()
    let eventer2 = Eventer1()
    
    lazy var eventerWork1 = eventer1.on(\.value)
    lazy var eventerWork2 = eventer2.on(\.value)
    
    let combineWork = Work<Void, Void> { $0.success() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        combineWork
            .doAsync()
            .doCombineBuffered(eventerWork1, eventerWork2)
            .onSuccess {
                print("Combined: \($0) ($1)")
                print()
            }
        
        eventer1.start()
        eventer2.start()
        // Do any additional setup after loading the view.
    }
}

class Eventer1: Eventable {
    struct Events: InitProtocol {
        var value: Int?
    }

    var events: EventsStore = .init()

    func start() {
        DispatchQueue.main.async { [weak self] in
            for i in 0 ... 10000 {
                self?.send(\.value, i)
            }
        }
    }
}

class Eventer2: Eventable {
    struct Events: InitProtocol {
        var value: String?
    }

    var events: EventsStore = .init()

    func start() {
        DispatchQueue.main.async { [weak self] in
            for i in 0 ... 10000 {
                self?.send(\.value, String(i))
            }
        }
    }
}



// eventerWork1
//    .onSuccess {
//        print("Cobine 1: \($0)")
//    }

// eventerWork2
//    .onSuccess {
//        print("Cobine 2: \($0)")
//    }



