//
//  AKToneFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKToneFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKToneFilter(input)
        input.start()
        AKTestMD5("4f3b1309e39beed48f9e6b9bff0c401c")
    }

    func testHalfPowerPoint() {
        let input = AKOscillator()
        output = AKToneFilter(input, halfPowerPoint: 599)
        input.start()
        AKTestMD5("2b984096830ec4cc3ac8a81877eb7379")
    }
}
