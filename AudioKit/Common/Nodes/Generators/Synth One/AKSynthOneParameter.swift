//
//  AKSynthOneParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Parameter lookup
public enum AKSynthOneParameter: Int {
    case index1 = 0, index2 = 1,
    morphBalance = 2,
    morph1PitchOffset = 3, morph2PitchOffset = 4,
    morph1Mix = 5, morph2Mix = 6,
    subOscMix = 7,
    subOscOctavesDown = 8,
    subOscIsSquare = 9,
    fmMix = 10,
    fmMod = 11,
    noiseMix = 12,
    lfoIndex = 13,
    lfoAmplitude = 14,
    lfoRate = 15,
    cutoffFrequency = 16,
    resonance = 17,
    filterMix = 18,
    filterADSRMix = 19,
    isMono = 20,
    glide = 21,
    filterAttackDuration = 22,
    filterDecayDuration = 23,
    filterSustainLevel = 24,
    filterReleaseDuration = 25,
    attackDuration = 26,
    decayDuration = 27,
    sustainLevel = 28,
    releaseDuration = 29,
    detuningOffset = 30,
    detuningMultiplier = 31
}
