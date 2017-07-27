//
//  AKBoosterTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 7/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBoosterTests: AKTestCase {

    func testDefault() {
        output = AKBooster(input)
        AKTestNoEffect()
    }

    func testParamters() {
        output = AKBooster(input, gain: 0.1)
        AKTestMD5("da4225703cdfcf1fc46dfb104d1824b2")
    }

    func testParamtersSetAfterInit() {
        let booster = AKBooster(input)
        booster.gain = 0.1
        output = booster
        AKTestMD5("da4225703cdfcf1fc46dfb104d1824b2")
    }

    func testGain() {
        output = AKBooster(input, gain: 0.7)
        AKTestMD5("b6e42381963b1047cb4890e6c0da29f3")
    }


}
