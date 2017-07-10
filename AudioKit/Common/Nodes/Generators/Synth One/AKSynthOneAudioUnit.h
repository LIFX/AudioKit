//
//  AKSynthOneAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKSynthOneAudioUnit : AKAudioUnit

@property (nonatomic) float index1;
@property (nonatomic) float index2;
@property (nonatomic) float morphBalance;
@property (nonatomic) float morph1PitchOffset;
@property (nonatomic) float morph2PitchOffset;
@property (nonatomic) float morph1Mix;
@property (nonatomic) float morph2Mix;
@property (nonatomic) float subOscMix;
@property (nonatomic) float subOscOctavesDown;
@property (nonatomic) float subOscIsSquare;
@property (nonatomic) float fmMix;
@property (nonatomic) float fmMod;
@property (nonatomic) float noiseMix;
@property (nonatomic) float lfoIndex;
@property (nonatomic) float lfoAmplitude;
@property (nonatomic) float lfoRate;
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
@property (nonatomic) float filterMix;
@property (nonatomic) float filterADSRMix;
@property (nonatomic) float isMono;
@property (nonatomic) float glide;
@property (nonatomic) float filterAttackDuration;
@property (nonatomic) float filterDecayDuration;
@property (nonatomic) float filterSustainLevel;
@property (nonatomic) float filterReleaseDuration;
@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;
- (void)stopNote:(uint8_t)note;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;
- (void)reset;

@end

