//
//  AKAmplitudeEnvelopeTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKAmplitudeEnvelopeTests: AKTestCase {

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input)
        input.start()
        AKTestMD5("bfaf1f674bd86c1e45fdac3b96e96fe8")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input, attackDuration: 0.1234, decayDuration: 0.234, sustainLevel: 0.345)
        input.start()
        AKTestMD5("9a788f314cdfd0cb8834837246b7b2d9")
    }

    func testAttack() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input, attackDuration: 0.1234)
        input.start()
        AKTestMD5("6d1bd9d118a9a51accb1a8d077ba3b8f")
    }

    func testDecay() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input, decayDuration: 0.234, sustainLevel: 0.345)
        input.start()
        AKTestMD5("1723f29dc04272525bdfe6cce82a7179")
    }

    func testSustain() {
        let input = AKOscillator()
        output = AKAmplitudeEnvelope(input, sustainLevel: 0.345)
        input.start()
        AKTestMD5("47820ec698e568481eff7e744f21657f")
    }

    // Release is not tested at this time since there is no sample accurate way to define release point

}
