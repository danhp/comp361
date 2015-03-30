import Foundation
import XCTest

class unitTest: XCTestCase {
    func testCombine() {
        var u1 = Unit(type: Constants.Types.Unit.Peasant)
        var u2 = Unit(type: Constants.Types.Unit.Peasant)

        u1.combine(u2)
        XCTAssert(u1.type == Constants.Types.Unit.Infantry)

        var u3 = Unit(type: Constants.Types.Unit.Peasant)
        u1.combine(u3)
        XCTAssert(u1.type == Constants.Types.Unit.Soldier)

        var u4 = Unit(type: Constants.Types.Unit.Knight)
        u1.combine(u4)
        XCTAssert(u1.type == Constants.Types.Unit.Knight)
    }
}