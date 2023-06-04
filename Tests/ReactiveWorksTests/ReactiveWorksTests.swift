@testable import ReactiveWorks
import XCTest

final class ReactiveWorksTests: XCTestCase {
   let retainer = Retainer()

   func testDoAnyWaySuccess() {
     //let expA = expectation(description: "A")
      let expB = expectation(description: "A")

      let workA = Work<String, String> {
         $0.success($0.in)
      }.retainBy(retainer)

      let workB = Work<String, String> {
         $0.success($0.in)
         expB.fulfill()
      }

      workA
         .doAsync("A")
         .doAnyway()
         .doNext(workB)

       wait(for: [expB], timeout: 1)

       XCTAssertEqual(workB.result, "A")
   }

   func testDoAnyWayFail() {
      //let expA = expectation(description: "A")
      let expB = expectation(description: "A")

      let workA = Work<String, String> {
         $0.fail()
      }.retainBy(retainer)

      let workB = Work<String, String> {
         $0.success($0.in)
         expB.fulfill()
      }

      workA
         .doAsync("A")
         .doAnyway()
         .doNext(workB)

      wait(for: [expB], timeout: 1)

      XCTAssertEqual(workB.result, "A")
   }
}
