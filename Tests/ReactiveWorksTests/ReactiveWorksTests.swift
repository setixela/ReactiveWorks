import XCTest
@testable import ReactiveWorks

final class ReactiveWorksTests: XCTestCase {
    func testViewModelUIViewReleasing() throws {

       let model = BaseViewModel(isAutoreleaseView: true)

       _ = model.view
       let view2 = model.uiView.description
       let view3 = model.uiView.description
       XCTAssertNotEqual(view2, view3)

       let model2 = BaseViewModel(isAutoreleaseView: false)
       _ = model2.view
       let view22 = model2.uiView.description
       let view23 = model2.uiView.description

       XCTAssertEqual(view22, view23)
    }
}
