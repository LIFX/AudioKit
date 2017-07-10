//
//  AKSynthOneDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKBankDSPKernel.hpp"

enum {
    index1Address = 0,
    index2Address = 1,
    morphBalanceAddress = 2,
    morph1PitchOffsetAddress = 3,
    morph2PitchOffsetAddress = 4,
    morph1MixAddress = 5,
    morph2MixAddress = 6,
    subOscMixAddress = 7,
    subOscOctavesDownAddress = 8,
    subOscIsSquareAddress = 9,
    fmMixAddress = 10,
    fmModAddress = 11,
    noiseMixAddress = 12,
    lfoIndexAddress = 13,
    lfoAmplitudeAddress = 14,
    lfoRateAddress = 15,
    cutoffFrequencyAddress = 16,
    resonanceAddress = 17,
    filterMixAddress = 18,
    filterADSRMixAddress = 19,
    isMonoAddress = 20,
    glideAddress = 21,
    filterAttackDurationAddress = 22,
    filterDecayDurationAddress = 23,
    filterSustainLevelAddress = 24,
    filterReleaseDurationAddress = 25,
    attackDurationAddress = 26,
    decayDurationAddress = 27,
    sustainLevelAddress = 28,
    releaseDurationAddress = 29,
    detuningOffsetAddress = 30,
    detuningMultiplierAddress = 31
};

class AKSynthOneDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
public:
    // MARK: Types
    struct NoteState {
        NoteState* next;
        NoteState* prev;
        AKSynthOneDSPKernel* kernel;
        
        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;
        
        float internalGate = 0;
        float amp = 0;
        float filter = 0;
        
        sp_adsr *adsr;
        sp_adsr *fadsr;
        sp_oscmorph *oscmorph1;
        sp_oscmorph *oscmorph2;
        sp_crossfade *morphCrossFade;
        sp_osc *subOsc;
        sp_fosc *fmOsc;
        
        sp_noise *noise;
        
        sp_moogladder *moog;
        sp_crossfade *filterCrossFade;
        
        void init() {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->sp, adsr);
            sp_adsr_create(&fadsr);
            sp_adsr_init(kernel->sp, fadsr);
            
            sp_oscmorph_create(&oscmorph1);
            sp_oscmorph_init(kernel->sp, oscmorph1, kernel->ft_array, 4, 0);
            oscmorph1->freq = 0;
            oscmorph1->amp = 0;
            oscmorph1->wtpos = 0;
            
            sp_oscmorph_create(&oscmorph2);
            sp_oscmorph_init(kernel->sp, oscmorph2, kernel->ft_array, 4, 0);
            oscmorph2->freq = 0;
            oscmorph2->amp = 0;
            oscmorph2->wtpos = 0;
            
            sp_crossfade_create(&morphCrossFade);
            sp_crossfade_init(kernel->sp, morphCrossFade);
            
            sp_crossfade_create(&filterCrossFade);
            sp_crossfade_init(kernel->sp, filterCrossFade);
            
            sp_osc_create(&subOsc);
            sp_osc_init(kernel->sp, subOsc, kernel->sine, 0.0);
            
            sp_fosc_create(&fmOsc);
            sp_fosc_init(kernel->sp, fmOsc, kernel->sine);
            
            sp_noise_create(&noise);
            sp_noise_init(kernel->sp, noise);
            
            sp_moogladder_create(&moog);
            sp_moogladder_init(kernel->sp, moog);
        }
        

        void clear() {
            stage = stageOff;
            amp = 0;
        }
        
        // linked list management
        void remove() {
            if (prev) prev->next = next;
            else kernel->playingNotes = next;
            
            if (next) next->prev = prev;
            
            //prev = next = nullptr; Had to remove due to a click, potentially bad
            
            --kernel->playingNotesCount;
            sp_oscmorph_destroy(&oscmorph1);
            sp_oscmorph_destroy(&oscmorph2);
            sp_crossfade_destroy(&morphCrossFade);
            sp_crossfade_destroy(&filterCrossFade);
            sp_noise_destroy(&noise);
            sp_osc_destroy(&subOsc);
            sp_fosc_destroy(&fmOsc);
            sp_moogladder_destroy(&moog);
        }
        
        void add() {
            init();
            prev = nullptr;
            next = kernel->playingNotes;
            if (next) next->prev = this;
            kernel->playingNotes = this;
            ++kernel->playingNotesCount;
        }
        
        void noteOn(int noteNumber, int velocity) {
            noteOn(noteNumber, velocity, (float)noteToHz(noteNumber));
        }
        
        void noteOn(int noteNumber, int velocity, float frequency) {
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                oscmorph1->freq = (float)noteToHz(noteNumber + (int)kernel->morph1PitchOffset);
                oscmorph1->amp = (float)pow2(velocity / 127.);
                oscmorph2->freq = (float)noteToHz(noteNumber + (int)kernel->morph2PitchOffset);
                oscmorph2->amp = (float)pow2(velocity / 127.);
                subOsc->freq = (float)noteToHz(noteNumber);
                subOsc->amp = (float)pow2(velocity / 127.);
                
                fmOsc->freq = (float)noteToHz(noteNumber);
                fmOsc->amp = (float)pow2(velocity / 127.);
                
                noise->amp = (float)pow2(velocity / 127.);
                stage = stageOn;
                internalGate = 1;
            }
        }
        
        
        void run(int frameCount, float *outL, float *outR)
        {
            float originalFrequency1 = oscmorph1->freq;
            oscmorph1->freq *= kernel->detuningMultiplierSmooth;
            oscmorph1->freq += kernel->detuningOffset;
            NSLog(@"dm: %g", kernel->detuningMultiplierSmooth);
            oscmorph1->freq = clamp(oscmorph1->freq, 0.0f, 22050.0f);
            oscmorph1->wtpos = kernel->index1;
            
            float originalFrequency2 = oscmorph2->freq;
            oscmorph2->freq *= kernel->detuningMultiplierSmooth;
            oscmorph2->freq += kernel->detuningOffset;
            oscmorph2->freq = clamp(oscmorph2->freq, 0.0f, 22050.0f);
            oscmorph2->wtpos = kernel->index2;
            
            float originalFrequencySub = subOsc->freq;
            subOsc->freq *= kernel->detuningMultiplierSmooth / (1.0 + kernel->subOscOctavesDown);
            
            float originalFrequencyFM = fmOsc->freq;
            fmOsc->freq *= kernel->detuningMultiplierSmooth;
            fmOsc->indx = kernel->fmMod;
            
            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;
            
            fadsr->atk = (float)kernel->filterAttackDuration;
            fadsr->dec = (float)kernel->filterDecayDuration;
            fadsr->sus = (float)kernel->filterSustainLevel;
            fadsr->rel = (float)kernel->filterReleaseDuration;
            
            morphCrossFade->pos = kernel->morphBalanceSmooth;
            filterCrossFade->pos = kernel->filterMix;
            moog->res = kernel->resonanceSmooth;
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float oscmorph1_out = 0;
                float oscmorph2_out = 0;
                float osc_morph_out = 0;
                float subOsc_out = 0;
                float fmOsc_out = 0;
                float noise_out = 0;
                float filterOut = 0;
                float finalOut = 0;
                sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);
                sp_adsr_compute(kernel->sp, fadsr, &internalGate, &filter);
                
                //                filter *= kernel->filterADSRMix;
                
                moog->freq = kernel->cutoffFrequencySmooth + kernel->lfoOutput; // basic frequency
                moog->freq = moog->freq - moog->freq * kernel->filterADSRMix * (1.0 - filter);
                
                if (moog->freq < 0.0) {
                    moog->freq = 0.0;
                }
                
                sp_oscmorph_compute(kernel->sp, oscmorph1, nil, &oscmorph1_out);
                oscmorph1_out *= kernel->morph1Mix;
                sp_oscmorph_compute(kernel->sp, oscmorph2, nil, &oscmorph2_out);
                oscmorph2_out *= kernel->morph2Mix;
                sp_crossfade_compute(kernel->sp, morphCrossFade, &oscmorph1_out, &oscmorph2_out, &osc_morph_out);
                sp_osc_compute(kernel->sp, subOsc, nil, &subOsc_out);
                if (kernel->subOscIsSquare) {
                    if (subOsc_out > 0) {
                        subOsc_out = kernel->subOscMix;
                    } else {
                        subOsc_out = -kernel->subOscMix;
                    }
                } else {
                    subOsc_out *= kernel->subOscMix * 2.0; // the 2.0 is to match square's volume
                }
                sp_fosc_compute(kernel->sp, fmOsc, nil, &fmOsc_out);
                fmOsc_out *= kernel->fmMix;
                sp_noise_compute(kernel->sp, noise, nil, &noise_out);
                noise_out *= kernel->noiseMix;
                
                float synthOut = amp * (osc_morph_out + subOsc_out + fmOsc_out + noise_out);
                
                sp_moogladder_compute(kernel->sp, moog, &synthOut, &filterOut);
                sp_crossfade_compute(kernel->sp, filterCrossFade, &synthOut, &filterOut, &finalOut);
                
                *outL++ += finalOut;
                *outR++ += finalOut;
                
            }
            oscmorph1->freq = originalFrequency1;
            oscmorph2->freq = originalFrequency2;
            subOsc->freq = originalFrequencySub;
            fmOsc->freq = originalFrequencyFM;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }
        
    };

    // MARK: Member Functions

    AKSynthOneDSPKernel() {
        noteStates.resize(128);
        for (NoteState& state : noteStates) {
            state.kernel = this;
        }
    }

    void init(int _channels, double _sampleRate) override {
        AKBankDSPKernel::init(_channels, _sampleRate);
        sp_ftbl_create(sp, &sine, 2048);
        sp_gen_sine(sp, sine);
        
        sp_phasor_create(&lfo);
        sp_phasor_init(sp, lfo, 0);
        
        sp_port_create(&midiNotePort);
        sp_port_init(sp, midiNotePort, 0.0);
        
        sp_port_create(&multiplierPort);
        sp_port_init(sp, multiplierPort, 0.02);
        sp_port_create(&balancePort);
        sp_port_init(sp, balancePort, 0.1);
        sp_port_create(&cutoffPort);
        sp_port_init(sp, cutoffPort, 0.05);
        sp_port_create(&resonancePort);
        sp_port_init(sp, resonancePort, 0.05);
    }
    
    void setupMono() {
        
        sp_adsr_create(&adsr);
        sp_adsr_init(sp, adsr);
        sp_adsr_create(&fadsr);
        sp_adsr_init(sp, fadsr);
        
        sp_oscmorph_create(&oscmorph1);
        sp_oscmorph_init(sp, oscmorph1, ft_array, 4, 0);
        oscmorph1->freq = 0;
        oscmorph1->amp = 0;
        oscmorph1->wtpos = 0;
        
        sp_oscmorph_create(&oscmorph2);
        sp_oscmorph_init(sp, oscmorph2, ft_array, 4, 0);
        oscmorph2->freq = 0;
        oscmorph2->amp = 0;
        oscmorph2->wtpos = 0;
        
        sp_crossfade_create(&morphCrossFade);
        sp_crossfade_init(sp, morphCrossFade);
        
        sp_crossfade_create(&filterCrossFade);
        sp_crossfade_init(sp, filterCrossFade);
        
        sp_osc_create(&subOsc);
        sp_osc_init(sp, subOsc, sine, 0.0);
        
        sp_fosc_create(&fmOsc);
        sp_fosc_init(sp, fmOsc, sine);
        
        sp_noise_create(&noise);
        sp_noise_init(sp, noise);
        
        sp_moogladder_create(&moog);
        sp_moogladder_init(sp, moog);
        
        isMonoSetup = true;
        
    }
    
    void setupWaveform(uint32_t waveform, uint32_t size) {
        tbl_size = size;
        sp_ftbl_create(sp, &ft_array[waveform], tbl_size);
    }
    
    void setWaveformValue(uint32_t waveform, uint32_t index, float value) {
        ft_array[waveform]->tbl[index] = value;
    }
    
    void reset() {
        for (NoteState& state : noteStates) {
            state.clear();
        }
        playingNotes = nullptr;
        index1Ramper.reset();
        AKBankDSPKernel::reset();
    }
    
    standardBankKernelFunctions()
    
    void setIndex1(float value) {
        index1 = clamp(value, 0.0f, 1.0f);
        index1Ramper.setImmediate(index1);
    }
    
    void setIndex2(float value) {
        index2 = clamp(value, 0.0f, 1.0f);
        index2Ramper.setImmediate(index2);
    }
    
    void setMorphBalance(float value) {
        morphBalance = clamp(value, 0.0f, 1.0f);
        morphBalanceRamper.setImmediate(morphBalance);
    }
    
    void setMorph1PitchOffset(float value) {
        morph1PitchOffset = clamp(value, 0.0f, 1.0f);
        morph1PitchOffsetRamper.setImmediate(morph1PitchOffset);
    }
    
    void setMorph2PitchOffset(float value) {
        morph2PitchOffset = clamp(value, 0.0f, 1.0f);
        morph2PitchOffsetRamper.setImmediate(morph2PitchOffset);
    }
    
    void setMorph1Mix(float value) {
        morph1Mix = clamp(value, 0.0f, 1.0f);
        morph1MixRamper.setImmediate(morph1Mix);
    }
    
    void setMorph2Mix(float value) {
        morph2Mix = clamp(value, 0.0f, 1.0f);
        morph2MixRamper.setImmediate(morph2Mix);
    }
    
    void setSubOscMix(float value) {
        subOscMix = clamp(value, 0.0f, 1.0f);
        subOscMixRamper.setImmediate(subOscMix);
    }
    
    void setSubOscOctavesDown(float value) {
        subOscOctavesDown = clamp(value, 0.0f, 1.0f);
        subOscOctavesDownRamper.setImmediate(subOscOctavesDown);
    }
    
    void setSubOscIsSquare(float value) {
        subOscIsSquare = clamp(value, 0.0f, 1.0f);
        subOscIsSquareRamper.setImmediate(subOscIsSquare);
    }
    
    void setFmMix(float value) {
        fmMix = clamp(value, 0.0f, 1.0f);
        fmMixRamper.setImmediate(fmMix);
    }
    
    void setFmMod(float value) {
        fmMod = clamp(value, 0.0f, 1.0f);
        fmModRamper.setImmediate(fmMod);
    }
    
    void setNoiseMix(float value) {
        noiseMix = clamp(value, 0.0f, 1.0f);
        noiseMixRamper.setImmediate(noiseMix);
    }
    
    void setLfoIndex(float value) {
        lfoIndex = clamp(value, 0.0f, 1.0f);
        lfoIndexRamper.setImmediate(lfoIndex);
    }
    
    void setLfoAmplitude(float value) {
        lfoAmplitude = clamp(value, 0.0f, 1.0f);
        lfoAmplitudeRamper.setImmediate(lfoAmplitude);
    }
    
    void setLfoRate(float value) {
        lfoRate = clamp(value, 0.0f, 1.0f);
        lfoRateRamper.setImmediate(lfoRate);
    }
    
    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 0.0f, 22000.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }
    
    void setResonance(float value) {
        resonance = clamp(value, 0.0f, 1.0f);
        resonanceRamper.setImmediate(resonance);
    }
    
    void setFilterMix(float value) {
        filterMix = clamp(value, 0.0f, 1.0f);
        filterMixRamper.setImmediate(filterMix);
    }
    
    void setFilterADSRMix(float value) {
        filterADSRMix = clamp(value, 0.0f, 1.0f);
        filterADSRMixRamper.setImmediate(filterADSRMix);
    }
    
    void setIsMono(float value) {
        isMono = clamp(value, 0.0f, 1.0f);
        isMonoRamper.setImmediate(isMono);
    }
    
    void setGlide(float value) {
        glide = clamp(value, 0.0f, 1.0f);
        glideRamper.setImmediate(glide);
    }
    
    void setFilterAttackDuration(float value) {
        filterAttackDuration = clamp(value, 0.0f, 1.0f);
        filterAttackDurationRamper.setImmediate(filterAttackDuration);
    }
    
    void setFilterDecayDuration(float value) {
        filterDecayDuration = clamp(value, 0.0f, 1.0f);
        filterDecayDurationRamper.setImmediate(filterDecayDuration);
    }
    
    void setFilterSustainLevel(float value) {
        filterSustainLevel = clamp(value, 0.0f, 1.0f);
        filterSustainLevelRamper.setImmediate(filterSustainLevel);
    }
    
    void setFilterReleaseDuration(float value) {
        filterReleaseDuration = clamp(value, 0.0f, 1.0f);
        filterReleaseDurationRamper.setImmediate(filterReleaseDuration);
    }
        

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
                
            case index1Address:
                index1Ramper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            standardBankSetParameters()
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {

            case index1Address:
                return index1Ramper.getUIValue();
            standardBankGetParameters()
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
                
            case index1Address:
                index1Ramper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
            standardBankStartRamps()
        }
    }
    
    standardHandleMIDI()

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;
        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] = 0.0f;
            outR[i] = 0.0f;
        }
        
        if (isMono == 1) {
            NSLog(@"WARNING IS MONO");
            if (isMonoSetup == false) {
                setupMono();
            }
            
            //monoRun(frameCount, outL, outR);
            
        } else {
            
            NoteState* noteState = playingNotes;
            while (noteState) {
                noteState->run(frameCount, outL, outR);
                noteState = noteState->next;
            }
        }
        
        lfo->freq = lfoRate;
        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            sp_phasor_compute(sp, lfo, nil, &lfoOutput);
            
            if (lfoShape == 0) {
                lfoOutput = sin(lfoOutput * M_PI * 2.0);
            } else if (lfoShape == 1) {
                if (lfoOutput > 0.5) {
                    lfoOutput = 1.0;
                } else {
                    lfoOutput = -1.0;
                }
            } else if (lfoShape == 2) {
                lfoOutput = (lfoOutput - 0.5) * 2.0;
            } else if (lfoShape == 3) {
                lfoOutput = (0.5 - lfoOutput) * 2.0;
            }
            
            lfoOutput *= lfoAmplitude;
            
//            sp_port_compute(sp, multiplierPort, &detuningMultiplier, &detuningMultiplierSmooth);
//            sp_port_compute(sp, balancePort, &morphBalance, &morphBalanceSmooth);
//            sp_port_compute(sp, cutoffPort, &cutoffFrequency, &cutoffFrequencySmooth);
//            sp_port_compute(sp, resonancePort, &resonance, &resonanceSmooth);
            
            outL[i] *= 0.5f;
            outR[i] *= 0.5f;
        }
    }
    

    // MARK: Member Variables

private:
    std::vector<NoteState> noteStates;
    
    sp_ftbl *ft_array[4];
    UInt32 tbl_size = 4096;
    
    sp_ftbl *sine;
    sp_phasor *lfo;
    float lfoOutput = 0.0;
    
    sp_port *midiNotePort;
    float midiNote = 0.0;
    float midiNoteSmooth = 0.0;
    
    sp_port *multiplierPort;
    sp_port *balancePort;
    sp_port *cutoffPort;
    sp_port *resonancePort;

public:
    float index1 = 2.666;
    float index2 = 1.666;
    
    float morphBalance = 0.5666;
    float morphBalanceSmooth = 0.5666;
    float morph1PitchOffset = 0.666;
    float morph2PitchOffset = 7.666;
    
    float morph1Mix = 0.666;
    float morph2Mix = 0.666;
    float subOscMix = 0.666;
    float subOscOctavesDown = 1.0;
    bool  subOscIsSquare = false;
    float fmMix = 0.666;
    float fmMod = 0.666;
    float noiseMix = 0.666;
    
    float attackDuration = 0.1;
    float decayDuration = 0.1;
    float sustainLevel = 0.1666;
    float releaseDuration = 0.1;
    
    float detuningOffset = 66.6;
    float detuningMultiplier = 1.66;
    float detuningMultiplierSmooth = 1.66;
    
    float lfoIndex = 0.666;
    float lfoAmplitude = 666;
    float lfoRate = 6.666;
    int lfoShape = 0;
    float cutoffFrequency = 1666;
    float cutoffFrequencySmooth = 1666;
    float resonance = 0.66;
    float resonanceSmooth = 0.5;
    float filterMix = 0.666;
    float filterADSRMix = 0.666;
    
    
    int isMono = 0;
    float glide = 0.0;
    
    float filterAttackDuration = 0.1666;
    float filterDecayDuration = 0.1666;
    float filterSustainLevel = 0.666;
    float filterReleaseDuration = 0.666;
    
    NoteState* playingNotes = nullptr;
    int playingNotesCount = 0;
    bool resetted = false;
    
    // MONO Stuff
    
    bool isMonoSetup = false;
    
    float internalGate = 0;
    float amp = 0;
    float filter = 0;
    
    sp_adsr *adsr;
    sp_adsr *fadsr;
    sp_oscmorph *oscmorph1;
    sp_oscmorph *oscmorph2;
    sp_crossfade *morphCrossFade;
    sp_osc *subOsc;
    sp_fosc *fmOsc;
    
    sp_noise *noise;
    
    sp_moogladder *moog;
    sp_crossfade *filterCrossFade;
    
    bool notesHeld = false;
    
    ParameterRamper index1Ramper = 0.0;
    ParameterRamper index2Ramper = 0.0;
    ParameterRamper morphBalanceRamper = 0.5;
    ParameterRamper morph1PitchOffsetRamper = 0.0;
    ParameterRamper morph2PitchOffsetRamper = 0.0;
    ParameterRamper morph1MixRamper = 1.0;
    ParameterRamper morph2MixRamper = 1.0;
    ParameterRamper subOscMixRamper = 0.0;
    ParameterRamper subOscOctavesDownRamper = 0.0;
    ParameterRamper subOscIsSquareRamper = 0.0;
    ParameterRamper fmMixRamper = 0.0;
    ParameterRamper fmModRamper = 0.0;
    ParameterRamper noiseMixRamper = 0.0;
    ParameterRamper lfoIndexRamper = 0.0;
    ParameterRamper lfoAmplitudeRamper = 0.0;
    ParameterRamper lfoRateRamper = 0.0;
    ParameterRamper cutoffFrequencyRamper = 0.0;
    ParameterRamper resonanceRamper = 0.0;
    ParameterRamper filterMixRamper = 0.0;
    ParameterRamper filterADSRMixRamper = 0.0;
    ParameterRamper isMonoRamper = 0.0;
    ParameterRamper glideRamper = 0.0;
    ParameterRamper filterAttackDurationRamper = 0.1;
    ParameterRamper filterDecayDurationRamper = 0.1;
    ParameterRamper filterSustainLevelRamper = 1.0;
    ParameterRamper filterReleaseDurationRamper = 0.1;
    ParameterRamper attackDurationRamper = 0.1;
    ParameterRamper decayDurationRamper = 0.10;
    ParameterRamper sustainLevelRamper = 1.0;
    ParameterRamper releaseDurationRamper = 0.1;
    ParameterRamper detuningOffsetRamper = 0.0;
    ParameterRamper detuningMultiplierParameterRamper = 1.0;
};

