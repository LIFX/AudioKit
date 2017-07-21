//
//  AKHighPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKHighPassButterworthFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighPassButterworthFilter(input)
        input.start()
        AKTestMD5("023c370be0234ef4069253a931789684")
    }

    func testCutoffFrequency() {
        let input = AKOscillator()
        output = AKHighPassButterworthFilter(input, cutoffFrequency: 400)
        input.start()
        AKTestMD5("941b2b21d5c2528541f28ffb810cf66f")
    }
}
