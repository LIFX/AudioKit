//
//  AKFMOscillatorBankTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 7/21/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFMOscillatorBankTests: AKTestCase {

    var inputBank: AKFMOscillatorBank!

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0

        afterStart = {
            self.inputBank.play(noteNumber: 60, velocity: 120)
            self.inputBank.play(noteNumber: 64, velocity: 110)
            self.inputBank.play(noteNumber: 67, velocity: 100)
        }
    }

    func testAttackDuration() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), attackDuration: 0.123)
        output = inputBank
        AKTestMD5("27d7352154c2abbe3f00a7f66aa1a2ae")
    }

    func testCarrierMultiplier() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), carrierMultiplier: 1.1)
        output = inputBank
        AKTestMD5("04f54473a8adb63d75bd6f7e7f670736")
    }

    func testDecayDuration() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), decayDuration: 0.234)
        output = inputBank
        AKTestMD5("221a728592f2aab5f0b174eb6ce4fcae")
    }

    func testDefault() {
        inputBank = AKFMOscillatorBank()
        output = inputBank
        AKTestMD5("b06c09a1f2da0383337362b724a73d8e")
    }

    func testDetuningMultiplier() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), detuningMultiplier: 1.1)
        output = inputBank
        AKTestMD5("40b7cf906b465a90292cf031659cdb53")
    }

    func testDetuningOffset() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), detuningOffset: 1)
        output = inputBank
        AKTestMD5("75062f8f0b460b7cd99c3562276a5074")
    }

    func testModulatingMultiplier() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), modulatingMultiplier: 1.2)
        output = inputBank
        AKTestMD5("07831f95ab5e7cab6db3cdfe4c01bfa6")
    }

    func testModulationIndex() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), modulationIndex:  1.3)
        output = inputBank
        AKTestMD5("0cdbe4e0546a81e0ac1ab929c71cf864")
    }

    func testParameters() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square),
                                       carrierMultiplier: 1.1,
                                       modulatingMultiplier: 1.2,
                                       modulationIndex:  1.3,
                                       attackDuration: 0.123,
                                       decayDuration: 0.234,
                                       sustainLevel: 0.345,
                                       detuningOffset: 1,
                                       detuningMultiplier: 1.1)
        output = inputBank
        AKTestMD5("ccec3f3a959e59a84867a0b95bfed237")
    }

    func testSustainLevel() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("af8765a1937447caed4461e30fdea889")
    }

    func testWaveform() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square))
        output = inputBank
        AKTestMD5("0c0d418d740c1cc53a9afd232122bb44")
    }
}
