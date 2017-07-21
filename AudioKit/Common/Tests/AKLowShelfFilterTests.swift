//
//  AKLowShelfFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowShelfFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowShelfFilter(input)
        input.start()
        AKTestNoEffect()
    }

    func testCutoffFrequency() {
        let input = AKOscillator()
        output = AKLowShelfFilter(input, cutoffFrequency: 100, gain: 1)
        input.start()
        AKTestMD5("6b5611186ee54e8ede60ab68f5ada69d")
    }

    func testGain() {
        let input = AKOscillator()
        output = AKLowShelfFilter(input, gain: 1)
        input.start()
        AKTestMD5("ef250915f7d4a375ef036cddd9ab2e89")
    }
}
