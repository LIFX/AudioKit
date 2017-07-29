//
//  AKSynthOneAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKSynthOneAudioUnit.h"
#import "AKSynthOneDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKSynthOneAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKSynthOneDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
    AUHostMusicalContextBlock _musicalContext;
}
@synthesize parameterTree = _parameterTree;

- (NSArray *)parameters {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:49];
    for (int i = 0; i < 49; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel.p[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

- (void)setParameters:(NSArray *)parameters {
    float params[49] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i = 0; i < parameters.count; i++) {
        params[i] = [parameters[i] floatValue];
    }
    _kernel.setParameters(params);
}

- (BOOL)isSetUp { return _kernel.resetted; }
- (void)stopNote:(uint8_t)note { _kernel.stopNote(note); }
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity { _kernel.startNote(note, velocity); }
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency {
    _kernel.startNote(note, velocity, frequency);
}

- (void)setupWaveform:(UInt32)waveform size:(int)size {
    _kernel.setupWaveform(waveform, (uint32_t)size);
}

- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index {
    _kernel.setWaveformValue(waveform, index, value);
}

- (void) reset {
    _kernel.reset();
}

- (void)createParameters {

    standardGeneratorSetup(SynthOne)
    
    AUParameter *index1AU =                [AUParameter parameter:@"index1"                name:@"Index 1"                 address:index1                min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *index2AU =                [AUParameter parameter:@"index2"                name:@"Index 2"                 address:index2                min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morphBalanceAU =          [AUParameter parameter:@"morphBalance"          name:@"Morph Balance"           address:morphBalance          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph1SemitoneOffsetAU =  [AUParameter parameter:@"morph1SemitoneOffset"  name:@"Morph 1 Semitone Offset" address:morph1SemitoneOffset  min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph2SemitoneOffsetAU =  [AUParameter parameter:@"morph2SemitoneOffset"  name:@"Morph 2 Semitone Offset" address:morph2SemitoneOffset  min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph1VolumeAU =          [AUParameter parameter:@"morph1Volume"          name:@"Morph 1 Volume"          address:morph1Volume          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *morph2VolumeAU =          [AUParameter parameter:@"morph2Volume"          name:@"Morph 2 Volume"          address:morph2Volume          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *subVolumeAU =             [AUParameter parameter:@"subVolume"             name:@"Sub Volume"              address:subVolume             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *subOctaveDownAU =         [AUParameter parameter:@"subOctaveDown"         name:@"Sub Octave Down"         address:subOctaveDown         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *subIsSquareAU =           [AUParameter parameter:@"subIsSquare"           name:@"Sub Is Square"           address:subIsSquare           min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *fmVolumeAU =              [AUParameter parameter:@"fmVolume"              name:@"FM Volume"               address:fmVolume              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *fmAmountAU =              [AUParameter parameter:@"fmAmount"              name:@"FM Amont"                address:fmAmount              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *noiseVolumeAU =           [AUParameter parameter:@"noiseVolume"           name:@"Noise Volume"            address:noiseVolume           min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo1IndexAU =              [AUParameter parameter:@"lfo1Index"              name:@"LFO 1 Index"               address:lfo1Index              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo1AmplitudeAU =          [AUParameter parameter:@"lfo1Amplitude"          name:@"LFO 1 Amplitude"           address:lfo1Amplitude          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo1RateAU =               [AUParameter parameter:@"lfo1Rate"               name:@"LFO 1 Rate"                address:lfo1Rate               min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *cutoffAU =                [AUParameter parameter:@"cutoff"                name:@"Cutoff"                  address:cutoff                min:0.0 max:22000 unit:kAudioUnitParameterUnit_Hertz];
    AUParameter *resonanceAU =             [AUParameter parameter:@"resonance"             name:@"Resonance"               address:resonance             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterMixAU =             [AUParameter parameter:@"filterMix"             name:@"Filter Mix"              address:filterMix             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterADSRMixAU =         [AUParameter parameter:@"filterADSRMix"         name:@"Filter ADSR Mix"         address:filterADSRMix         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *isMonoAU =                [AUParameter parameter:@"isMono"                name:@"Is Mono"                 address:isMono                min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *glideAU =                 [AUParameter parameter:@"glide"                 name:@"Glide"                   address:glide                 min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterAttackDurationAU =  [AUParameter parameter:@"filterAttackDuration"  name:@"Filter Attack Duration"  address:filterAttackDuration  min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterDecayDurationAU =   [AUParameter parameter:@"filterDecayDuration"   name:@"Filter Decay Duration"   address:filterDecayDuration   min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterSustainLevelAU =    [AUParameter parameter:@"filterSustainLevel"    name:@"Filter Sustain Level"    address:filterSustainLevel    min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *filterReleaseDurationAU = [AUParameter parameter:@"filterReleaseDuration" name:@"Filter Release Duration" address:filterReleaseDuration min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *attackDurationAU =        [AUParameter parameter:@"attackDuration"        name:@"Attack Duration"         address:attackDuration        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *decayDurationAU =         [AUParameter parameter:@"decayDuration"         name:@"Decay Duration"          address:decayDuration         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *sustainLevelAU =          [AUParameter parameter:@"sustainLevel"          name:@"Sustain Level"           address:sustainLevel          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *releaseDurationAU =       [AUParameter parameter:@"releaseDuration"       name:@"Release Duration"        address:releaseDuration       min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *detuningOffsetAU =        [AUParameter parameter:@"detuningOffset"        name:@"Detuning Offset"         address:detuningOffset        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *detuningMultiplierAU =    [AUParameter parameter:@"detuningMultiplier"    name:@"Detuning Multiplier"     address:detuningMultiplier    min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *masterVolumeAU =          [AUParameter parameter:@"masterVolume"          name:@"Master Volume"           address:masterVolume          min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *bitCrushDepthAU =         [AUParameter parameter:@"bitCrushDepth"         name:@"Bit Depth"               address:bitCrushDepth         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *bitCrushSampleRateAU =    [AUParameter parameter:@"bitCrushSampleRate"    name:@"Sample Rate"             address:bitCrushSampleRate    min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *autoPanOnAU =             [AUParameter parameter:@"autoPanOn"             name:@"Auto Pan On"             address:autoPanOn             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *autoPanFrequencyAU =      [AUParameter parameter:@"autoPanFrequency"      name:@"Auto Pan Frequency"      address:autoPanFrequency      min:0.0 max:10.0  unit:kAudioUnitParameterUnit_Hertz];
    AUParameter *reverbOnAU =              [AUParameter parameter:@"reverbOn"              name:@"Reverb On"               address:reverbOn              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *reverbFeedbackAU =        [AUParameter parameter:@"reverbFeedback"        name:@"Reverb Feedback"         address:reverbFeedback        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *reverbHighPassAU =        [AUParameter parameter:@"reverbHighPass"        name:@"Reverb HighPass"         address:reverbHighPass        min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Hertz];
    AUParameter *reverbMixAU =             [AUParameter parameter:@"reverbMix"             name:@"Reverb Mix"              address:reverbMix             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayOnAU =               [AUParameter parameter:@"delayOn"               name:@"Delay On"                address:delayOn               min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayFeedbackAU =         [AUParameter parameter:@"delayFeedback"         name:@"Delay Feedback"          address:delayFeedback         min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayTimeAU =             [AUParameter parameter:@"delayTime"             name:@"Delay Time"              address:delayTime             min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *delayMixAU =              [AUParameter parameter:@"delayMix"              name:@"Delay Mix"               address:delayMix              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo2IndexAU =              [AUParameter parameter:@"lfo2Index"              name:@"LFO 2 Index"               address:lfo2Index              min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo2AmplitudeAU =          [AUParameter parameter:@"lfo2Amplitude"          name:@"LFO 2 Amplitude"           address:lfo2Amplitude          min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *lfo2RateAU =               [AUParameter parameter:@"lfo2Rate"               name:@"LFO 2 Rate"                address:lfo2Rate               min:0.0 max:1.0   unit:kAudioUnitParameterUnit_Generic];
    AUParameter *cutoffLFOAU =               [AUParameter parameter:@"cutoffLFO"               name:@"Cutoff LFO"                address:cutoffLFO               min:0.0 max:2.0   unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    index1AU.value = 0;
    index2AU.value = 0;
    morphBalanceAU.value = 0.5;
    morph1SemitoneOffsetAU.value = 0;
    morph2SemitoneOffsetAU.value = 0;
    morph1VolumeAU.value = 1;
    morph2VolumeAU.value = 1;
    subVolumeAU.value = 0;
    subOctaveDownAU.value = 1;
    subIsSquareAU.value = 0;
    fmVolumeAU.value = 0;
    fmAmountAU.value = 0;
    noiseVolumeAU.value = 0;
    lfo1IndexAU.value = 0;
    lfo1AmplitudeAU.value = 1;
    lfo1RateAU.value = 0;
    cutoffAU.value = 1000;
    resonanceAU.value = 0.5;
    filterMixAU.value = 1;
    filterADSRMixAU.value = 0.5;
    isMonoAU.value = 0;
    glideAU.value = 0;
    filterAttackDurationAU.value = 0.1;
    filterDecayDurationAU.value = 0.1;
    filterSustainLevelAU.value = 1.0;
    filterReleaseDurationAU.value = 0.1;
    attackDurationAU.value = 0.1;
    decayDurationAU.value = 0.1;
    sustainLevelAU.value = 1.0;
    releaseDurationAU.value = 0.1;
    detuningOffsetAU.value = 0.0;
    detuningMultiplierAU.value = 1.0;
    masterVolumeAU.value = 0.8;
    bitCrushDepthAU.value = 24;
    bitCrushSampleRateAU.value = 44100;
    autoPanOnAU.value = 0;
    autoPanFrequencyAU.value = 0;
    reverbOnAU.value = 0;
    reverbFeedbackAU.value = 0;
    reverbHighPassAU.value = 1000;
    reverbMixAU.value = 0;
    delayOnAU.value = 0;
    delayFeedbackAU.value = 0;
    delayTimeAU.value = 0;
    delayMixAU.value = 0;
    lfo2IndexAU.value = 0;
    lfo2AmplitudeAU.value = 1;
    lfo2RateAU.value = 0;
    cutoffLFOAU.value = 1;


    _kernel.setParameter(index1, index1AU.value);
    _kernel.setParameter(index2, index2AU.value);
    _kernel.setParameter(morphBalance, morphBalanceAU.value);
    _kernel.setParameter(morph1SemitoneOffset, morph1SemitoneOffsetAU.value);
    _kernel.setParameter(morph2SemitoneOffset, morph2SemitoneOffsetAU.value);
    _kernel.setParameter(morph1Volume, morph1VolumeAU.value);
    _kernel.setParameter(morph2Volume, morph2VolumeAU.value);
    _kernel.setParameter(subVolume, subVolumeAU.value);
    _kernel.setParameter(subOctaveDown, subOctaveDownAU.value);
    _kernel.setParameter(subIsSquare, subIsSquareAU.value);
    _kernel.setParameter(fmVolume, fmVolumeAU.value);
    _kernel.setParameter(fmAmount, fmAmountAU.value);
    _kernel.setParameter(noiseVolume, noiseVolumeAU.value);
    _kernel.setParameter(lfo1Index, lfo1IndexAU.value);
    _kernel.setParameter(lfo1Amplitude, lfo1AmplitudeAU.value);
    _kernel.setParameter(lfo1Rate, lfo1RateAU.value);
    _kernel.setParameter(cutoff, cutoffAU.value);
    _kernel.setParameter(resonance, resonanceAU.value);
    _kernel.setParameter(filterMix, filterMixAU.value);
    _kernel.setParameter(filterADSRMix, filterADSRMixAU.value);
    _kernel.setParameter(isMono, isMonoAU.value);
    _kernel.setParameter(glide, glideAU.value);
    _kernel.setParameter(filterAttackDuration, filterAttackDurationAU.value);
    _kernel.setParameter(filterDecayDuration, filterDecayDurationAU.value);
    _kernel.setParameter(filterSustainLevel, filterSustainLevelAU.value);
    _kernel.setParameter(filterReleaseDuration, filterReleaseDurationAU.value);
    _kernel.setParameter(attackDuration, attackDurationAU.value);
    _kernel.setParameter(decayDuration, decayDurationAU.value);
    _kernel.setParameter(sustainLevel, sustainLevelAU.value);
    _kernel.setParameter(releaseDuration, releaseDurationAU.value);
    _kernel.setParameter(detuningOffset, detuningOffsetAU.value);
    _kernel.setParameter(detuningMultiplier, detuningMultiplierAU.value);
    _kernel.setParameter(masterVolume, masterVolumeAU.value);
    _kernel.setParameter(bitCrushDepth, bitCrushDepthAU.value);
    _kernel.setParameter(bitCrushSampleRate, bitCrushSampleRateAU.value);
    _kernel.setParameter(autoPanOn, autoPanOnAU.value);
    _kernel.setParameter(autoPanFrequency, autoPanFrequencyAU.value);
    _kernel.setParameter(reverbOn, reverbOnAU.value);
    _kernel.setParameter(reverbFeedback, reverbFeedbackAU.value);
    _kernel.setParameter(reverbHighPass, reverbHighPassAU.value);
    _kernel.setParameter(reverbMix, reverbMixAU.value);
    _kernel.setParameter(delayOn, delayOnAU.value);
    _kernel.setParameter(delayFeedback, delayFeedbackAU.value);
    _kernel.setParameter(delayTime, delayTimeAU.value);
    _kernel.setParameter(delayMix, delayMixAU.value);
    _kernel.setParameter(lfo2Index, lfo2IndexAU.value);
    _kernel.setParameter(lfo2Amplitude, lfo2AmplitudeAU.value);
    _kernel.setParameter(lfo2Rate, lfo2RateAU.value);
    _kernel.setParameter(cutoffLFO, cutoffLFOAU.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        index1AU,
        index2AU,
        morphBalanceAU,
        morph1SemitoneOffsetAU,
        morph2SemitoneOffsetAU,
        morph1VolumeAU,
        morph2VolumeAU,
        subVolumeAU,
        subOctaveDownAU,
        subIsSquareAU,
        fmVolumeAU,
        fmAmountAU,
        noiseVolumeAU,
        lfo1IndexAU,
        lfo1AmplitudeAU,
        lfo1RateAU,
        cutoffAU,
        resonanceAU,
        filterMixAU,
        filterADSRMixAU,
        isMonoAU,
        glideAU,
        filterAttackDurationAU,
        filterDecayDurationAU,
        filterSustainLevelAU,
        filterReleaseDurationAU,
        attackDurationAU,
        decayDurationAU,
        sustainLevelAU,
        releaseDurationAU,
        detuningOffsetAU,
        detuningMultiplierAU,
        masterVolumeAU,
        bitCrushDepthAU,
        bitCrushSampleRateAU,
        autoPanOnAU,
        autoPanFrequencyAU,
        reverbOnAU,
        reverbFeedbackAU,
        reverbHighPassAU,
        reverbMixAU,
        delayOnAU,
        delayFeedbackAU,
        delayTimeAU,
        delayMixAU,
        lfo2IndexAU,
        lfo2AmplitudeAU,
        lfo2RateAU,
        cutoffLFOAU
    ]];

    parameterTreeBlock(SynthOne)
}

AUAudioUnitGeneratorOverrides(SynthOne)

@end


