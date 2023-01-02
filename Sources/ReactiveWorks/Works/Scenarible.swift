//
//  Scenario.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 16.08.2022.
//

public protocol Scenarible: AnyObject {
    var scenario: Scenario { get }
}

public protocol Scenarible2: Scenarible {
    var scenario2: Scenario { get }
}

public protocol Scenarible3: Scenarible2 {
    var scenario3: Scenario { get }
}

// MARK: - Scenario protocol and base scenario

public protocol Scenario {
    func start()
}

public protocol ScenarioParams {
    associatedtype Asset: AssetRoot
    associatedtype ScenarioInputEvents: Any
    associatedtype ScenarioModelState: Any
    associatedtype ScenarioWorks: Any
}

open class BaseParamsScenario<Params: ScenarioParams>: BaseScenario<
    Params.ScenarioInputEvents,
    Params.ScenarioModelState,
    Params.ScenarioWorks
> {}

open class BaseScenario<Events, State, Works>: Scenario {
    public var works: Works
    public var events: Events

    public var setState: (State) -> Void = { _ in
        assertionFailure("stateDelegate (setState:) did not injected into Scenario")
    }

    public required init(works: Works, stateDelegate: ((State) -> Void)?, events: Events) {
        self.events = events
        self.works = works
        if let setStateFunc = stateDelegate {
            setState = setStateFunc
        }
    }

    open func start() {}
}
