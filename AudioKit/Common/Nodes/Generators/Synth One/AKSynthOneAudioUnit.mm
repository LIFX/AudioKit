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
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:32];
    for (int i = 0; i < 32; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel.parameters[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

- (void)setParameters:(NSArray *)parameters {
    float params[32] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i = 0; i < parameters.count; i++) {
        params[i] =[parameters[i] floatValue];
    }
    _kernel.setParameters(params);
}

standardBankFunctions()

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
    standardBankParameters()
    
    AUParameter *index1AUParameter =
    [AUParameter parameter:@"index1"
                      name:@"Index 1"
                   address:index1Address
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *index2AUParameter =
    [AUParameter parameter:@"index2"
                      name:@"Index 2"
                   address:index2Address
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *morphBalanceAUParameter =
    [AUParameter parameter:@"morphBalance"
                      name:@"Morph Balance"
                   address:morphBalanceAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *morph1PitchOffsetAUParameter =
    [AUParameter parameter:@"morph1PitchOffset"
                      name:@"Morph 1 Pitch Offset"
                   address:morph1PitchOffsetAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *morph2PitchOffsetAUParameter =
    [AUParameter parameter:@"morph2PitchOffset"
                      name:@"Morph 2 Pitch Offset"
                   address:morph2PitchOffsetAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *morph1MixAUParameter =
    [AUParameter parameter:@"morph1Mix"
                      name:@"Morph 1 Mix"
                   address:morph1MixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *morph2MixAUParameter =
    [AUParameter parameter:@"morph2Mix"
                      name:@"Morph 2 Mix"
                   address:morph2MixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *subOscMixAUParameter =
    [AUParameter parameter:@"subOscMix"
                      name:@"Sub Osc Mix"
                   address:subOscMixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *subOscOctavesDownAUParameter =
    [AUParameter parameter:@"subOscOctavesDown"
                      name:@"Sub Osc Octaves Down"
                   address:subOscOctavesDownAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *subOscIsSquareAUParameter =
    [AUParameter parameter:@"subOscIsSquare"
                      name:@"Sub Osc Is Square"
                   address:subOscIsSquareAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *fmMixAUParameter =
    [AUParameter parameter:@"fmMix"
                      name:@"FM Mix"
                   address:fmMixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *fmModAUParameter =
    [AUParameter parameter:@"fmMod"
                      name:@"FM Mod"
                   address:fmModAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *noiseMixAUParameter =
    [AUParameter parameter:@"noiseMix"
                      name:@"Noise Mix"
                   address:noiseMixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *lfoIndexAUParameter =
    [AUParameter parameter:@"lfoIndex"
                      name:@"LFO Index"
                   address:lfoIndexAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *lfoAmplitudeAUParameter =
    [AUParameter parameter:@"lfoAmplitude"
                      name:@"LFO Amplitude"
                   address:lfoAmplitudeAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *lfoRateAUParameter =
    [AUParameter parameter:@"lfoRate"
                      name:@"LFO Rate"
                   address:lfoRateAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *cutoffFrequencyAUParameter =
    [AUParameter parameter:@"cutoffFrequency"
                      name:@"Cutoff Frequency"
                   address:cutoffFrequencyAddress
                       min:0.0
                       max:22000
                      unit:kAudioUnitParameterUnit_Hertz];
    
    AUParameter *resonanceAUParameter =
    [AUParameter parameter:@"resonance"
                      name:@"Resonance"
                   address:resonanceAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *filterMixAUParameter =
    [AUParameter parameter:@"filterMix"
                      name:@"Filter Mix"
                   address:filterMixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *filterADSRMixAUParameter =
    [AUParameter parameter:@"filterADSRMix"
                      name:@"Filter ADSR Mix"
                   address:filterADSRMixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *isMonoAUParameter =
    [AUParameter parameter:@"isMono"
                      name:@"Is Mono"
                   address:isMonoAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *glideAUParameter =
    [AUParameter parameter:@"glide"
                      name:@"Glide"
                   address:glideAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *filterAttackDurationAUParameter =
    [AUParameter parameter:@"filterAttackDuration"
                      name:@"Filter Attack Duration"
                   address:filterAttackDurationAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *filterDecayDurationAUParameter =
    [AUParameter parameter:@"filterDecayDuration"
                      name:@"Filter Decay Duration"
                   address:filterDecayDurationAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *filterSustainLevelAUParameter =
    [AUParameter parameter:@"filterSustainLevel"
                      name:@"Filter Sustain Level"
                   address:filterSustainLevelAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *filterReleaseDurationAUParameter =
    [AUParameter parameter:@"filterReleaseDuration"
                      name:@"Filter Release Duration"
                   address:filterReleaseDurationAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    // Initialize the parameter values.
    index1AUParameter.value = 0;
    index2AUParameter.value = 0;
    morphBalanceAUParameter.value = 0.5;
    morph1PitchOffsetAUParameter.value = 0;
    morph2PitchOffsetAUParameter.value = 0;
    morph1MixAUParameter.value = 1;
    morph2MixAUParameter.value = 1;
    subOscMixAUParameter.value = 0;
    subOscOctavesDownAUParameter.value = 1;
    subOscIsSquareAUParameter.value = 0;
    fmMixAUParameter.value = 0;
    fmModAUParameter.value = 0;
    noiseMixAUParameter.value = 0;
    lfoIndexAUParameter.value = 0;
    lfoAmplitudeAUParameter.value = 1;
    lfoRateAUParameter.value = 1;
    cutoffFrequencyAUParameter.value = 1000;
    resonanceAUParameter.value = 0.5;
    filterMixAUParameter.value = 1;
    filterADSRMixAUParameter.value = 0.5;
    isMonoAUParameter.value = 0;
    glideAUParameter.value = 0;
    filterAttackDurationAUParameter.value = 0.1;
    filterDecayDurationAUParameter.value = 0.1;
    filterSustainLevelAUParameter.value = 1.0;
    filterReleaseDurationAUParameter.value = 0.1;

    _kernel.setParameter(index1Address, index1AUParameter.value);
    _kernel.setParameter(index2Address, index2AUParameter.value);
    _kernel.setParameter(morphBalanceAddress, morphBalanceAUParameter.value);
    _kernel.setParameter(morph1PitchOffsetAddress, morph1PitchOffsetAUParameter.value);
    _kernel.setParameter(morph2PitchOffsetAddress, morph2PitchOffsetAUParameter.value);
    _kernel.setParameter(morph1MixAddress, morph1MixAUParameter.value);
    _kernel.setParameter(morph2MixAddress, morph2MixAUParameter.value);
    _kernel.setParameter(subOscMixAddress, subOscMixAUParameter.value);
    _kernel.setParameter(subOscOctavesDownAddress, subOscOctavesDownAUParameter.value);
    _kernel.setParameter(subOscIsSquareAddress, subOscIsSquareAUParameter.value);
    _kernel.setParameter(fmMixAddress, fmMixAUParameter.value);
    _kernel.setParameter(fmModAddress, fmModAUParameter.value);
    _kernel.setParameter(noiseMixAddress, noiseMixAUParameter.value);
    _kernel.setParameter(lfoIndexAddress, lfoIndexAUParameter.value);
    _kernel.setParameter(lfoAmplitudeAddress, lfoAmplitudeAUParameter.value);
    _kernel.setParameter(lfoRateAddress, lfoRateAUParameter.value);
    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);
    _kernel.setParameter(resonanceAddress, resonanceAUParameter.value);
    _kernel.setParameter(filterMixAddress, filterMixAUParameter.value);
    _kernel.setParameter(filterADSRMixAddress, filterADSRMixAUParameter.value);
    _kernel.setParameter(isMonoAddress, isMonoAUParameter.value);
    _kernel.setParameter(glideAddress, glideAUParameter.value);
    _kernel.setParameter(filterAttackDurationAddress, filterAttackDurationAUParameter.value);
    _kernel.setParameter(filterDecayDurationAddress, filterDecayDurationAUParameter.value);
    _kernel.setParameter(filterSustainLevelAddress, filterSustainLevelAUParameter.value);
    _kernel.setParameter(filterReleaseDurationAddress, filterReleaseDurationAUParameter.value);
    _kernel.setParameter(attackDurationAddress, attackDurationAUParameter.value);
    _kernel.setParameter(decayDurationAddress, decayDurationAUParameter.value);
    _kernel.setParameter(sustainLevelAddress, sustainLevelAUParameter.value);
    _kernel.setParameter(releaseDurationAddress, releaseDurationAUParameter.value);
    _kernel.setParameter(detuningOffsetAddress, detuningOffsetAUParameter.value);
    _kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        index1AUParameter,
        index2AUParameter,
        morphBalanceAUParameter,
        morph1PitchOffsetAUParameter,
        morph2PitchOffsetAUParameter,
        morph1MixAUParameter,
        morph2MixAUParameter,
        subOscMixAUParameter,
        subOscOctavesDownAUParameter,
        subOscIsSquareAUParameter,
        fmMixAUParameter,
        fmModAUParameter,
        noiseMixAUParameter,
        lfoIndexAUParameter,
        lfoAmplitudeAUParameter,
        lfoRateAUParameter,
        cutoffFrequencyAUParameter,
        resonanceAUParameter,
        filterMixAUParameter,
        filterADSRMixAUParameter,
        isMonoAUParameter,
        glideAUParameter,
        filterAttackDurationAUParameter,
        filterDecayDurationAUParameter,
        filterSustainLevelAUParameter,
        filterReleaseDurationAUParameter,
        attackDurationAUParameter,
        decayDurationAUParameter,
        sustainLevelAUParameter,
        releaseDurationAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];

    parameterTreeBlock(SynthOne)
}

AUAudioUnitGeneratorOverrides(SynthOne)

@end


