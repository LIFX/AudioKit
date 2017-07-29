//
//  AKSynthOneDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"
#import <vector>

static inline double pow2(double x) {
    return x * x;
}

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

enum {
    index1 = 0,
    index2 = 1,
    morphBalance = 2,
    morph1SemitoneOffset = 3,
    morph2SemitoneOffset = 4,
    morph1Volume = 5,
    morph2Volume = 6,
    subVolume = 7,
    subOctaveDown = 8,
    subIsSquare = 9,
    fmVolume = 10,
    fmAmount = 11,
    noiseVolume = 12,
    lfo1Index = 13,
    lfo1Amplitude = 14,
    lfo1Rate = 15,
    cutoff = 16,
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
    detuningMultiplier = 31,
    masterVolume = 32,
    bitCrushDepth = 33,
    bitCrushSampleRate = 34,
    autoPanOn = 35,
    autoPanFrequency = 36,
    reverbOn = 37,
    reverbFeedback = 38,
    reverbHighPass = 39,
    reverbMix = 40,
    delayOn = 41,
    delayFeedback = 42,
    delayTime = 43,
    delayMix = 44,
    lfo2Index = 45,
    lfo2Amplitude = 46,
    lfo2Rate = 47,
    cutoffLFO = 48,
    resonanceLFO = 49,
    oscMixLFO = 50,
    sustainLFO = 51,
    index1LFO = 52,
    index2LFO = 53,
    fmLFO = 54,
    detuneLFO = 55,
    filterEnvLFO = 56,
    pitchLFO = 57,
    bitcrushLFO = 58,
    autopanLFO = 59

};

class AKSynthOneDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Types
    struct NoteState {
        NoteState* next;
        NoteState* prev;
        int baseNote = 0;
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
            baseNote = noteNumber;
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                oscmorph1->freq = (float)noteToHz(noteNumber + (int)kernel->p[morph1SemitoneOffset]);
                oscmorph1->amp = (float)pow2(velocity / 127.);
                oscmorph2->freq = (float)noteToHz(noteNumber + (int)kernel->p[morph2SemitoneOffset]);
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
            float extraMultiplier;

            if (kernel->p[pitchLFO] == 1) {
                extraMultiplier = 1 + 0.1 * kernel->lfo1 * kernel->p[lfo1Amplitude];
            } else if (kernel->p[pitchLFO] == 2) {
                extraMultiplier = 1 + 0.1 * kernel->lfo2 * kernel->p[lfo2Amplitude];
            } else {
                extraMultiplier = 1.0;
            }


            float originalFrequency1 = (float)noteToHz(baseNote + (int)kernel->p[morph1SemitoneOffset]);
            oscmorph1->freq *= kernel->detuningMultiplierSmooth * extraMultiplier;
            oscmorph1->freq = clamp(oscmorph1->freq, 0.0f, 22050.0f);



            if (kernel->p[index1LFO] == 1) {
                oscmorph1->wtpos = fmax(0, kernel->p[index1] + kernel->lfo1 * kernel->p[lfo1Amplitude]);
            } else if (kernel->p[index1LFO] == 2) {
                oscmorph1->wtpos = fmax(0, kernel->p[index1] + kernel->lfo2 * kernel->p[lfo2Amplitude]);
            } else {
                oscmorph1->wtpos = kernel->p[index1];
            }

            
            float originalFrequency2 = (float)noteToHz(baseNote + (int)kernel->p[morph2SemitoneOffset]);
            oscmorph2->freq *= kernel->detuningMultiplierSmooth * extraMultiplier;


            if (kernel->p[detuneLFO] == 1) {
                oscmorph2->freq += kernel->p[detuningOffset] * (1 + kernel->lfo1 * kernel->p[lfo1Amplitude]);
            } else if (kernel->p[detuneLFO] == 2) {
                oscmorph2->freq += kernel->p[detuningOffset] * (1 + kernel->lfo2 * kernel->p[lfo2Amplitude]);
            } else {
                oscmorph2->freq += kernel->p[detuningOffset];
            }
            oscmorph2->freq = clamp(oscmorph2->freq, 0.0f, 22050.0f);

            if (kernel->p[index2LFO] == 1) {
                oscmorph2->wtpos = fmax(0, kernel->p[index2] + kernel->lfo1 * kernel->p[lfo1Amplitude]);
            } else if (kernel->p[index2LFO] == 2) {
                oscmorph2->wtpos = fmax(0, kernel->p[index2] + kernel->lfo2 * kernel->p[lfo2Amplitude]);
            } else {
                oscmorph2->wtpos = kernel->p[index2];
            }

            float originalFrequencySub = subOsc->freq;
            subOsc->freq *= kernel->detuningMultiplierSmooth / (2.0 *
            (1.0 + kernel->p[subOctaveDown])) * extraMultiplier;
            
            float originalFrequencyFM = fmOsc->freq;
            fmOsc->freq *= kernel->detuningMultiplierSmooth * extraMultiplier;


            if (kernel->p[pitchLFO] == 1) {
                extraMultiplier = 1 + 0.1 * kernel->lfo1 * kernel->p[lfo1Amplitude];
            } else if (kernel->p[pitchLFO] == 2) {
                extraMultiplier = 1 + 0.1 * kernel->lfo2 * kernel->p[lfo2Amplitude];
            } else {
                extraMultiplier = 1.0;
            }
            if (kernel->p[fmLFO] == 1) {
                fmOsc->indx = kernel->p[fmAmount] * (1 + kernel->lfo1) * kernel->p[lfo1Amplitude];
            } else if (kernel->p[fmLFO] == 2) {
                fmOsc->indx = kernel->p[fmAmount] * (1 +kernel->lfo2) * kernel->p[lfo2Amplitude];
            } else {
                fmOsc->indx = kernel->p[fmAmount];
            }

            adsr->atk = (float)kernel->p[attackDuration];
            adsr->dec = (float)kernel->p[decayDuration];

            if (kernel->p[sustainLFO] == 1) {
                adsr->sus = (float)kernel->p[sustainLevel] * (float)(1 - ((1 + kernel->lfo1) / 2.0) * kernel->p[lfo1Amplitude]);
            } else if (kernel->p[sustainLFO] == 2) {
                adsr->sus = (float)kernel->p[sustainLevel] * (float)(1 - ((1 + kernel->lfo2) / 2.0) * kernel->p[lfo2Amplitude]);
            } else {
                adsr->sus = (float)kernel->p[sustainLevel];
            }

            fadsr->atk = (float)kernel->p[filterAttackDuration];
            fadsr->dec = (float)kernel->p[filterDecayDuration];
            fadsr->sus = (float)kernel->p[filterSustainLevel];
            fadsr->rel = (float)kernel->p[filterReleaseDuration];

            if (kernel->p[oscMixLFO] == 1) {
                morphCrossFade->pos = kernel->morphBalanceSmooth + kernel->lfo1 * kernel->p[lfo1Amplitude];
            } else if (kernel->p[oscMixLFO] == 2) {
                morphCrossFade->pos = kernel->morphBalanceSmooth + kernel->lfo2 * kernel->p[lfo2Amplitude];
            } else {
                morphCrossFade->pos = kernel->morphBalanceSmooth;
            }

            filterCrossFade->pos = kernel->p[filterMix];

            if (kernel->p[resonanceLFO] == 1) {
                moog->res = kernel->resonanceSmooth * (1 - ((1 + kernel->lfo1) / 2.0) * kernel->p[lfo1Amplitude]);
            } else if (kernel->p[resonanceLFO] == 2) {
                moog->res = kernel->resonanceSmooth * (1 - ((1 + kernel->lfo2) / 2.0) * kernel->p[lfo2Amplitude]);
            } else {
                moog->res = kernel->resonanceSmooth;
            }

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

                if (kernel->p[cutoffLFO] == 1) {
                    moog->freq = kernel->cutoffSmooth * (1 - ((1 + kernel->lfo1) / 2.0) * kernel->p[lfo1Amplitude]);
                } else if (kernel->p[cutoffLFO] == 2) {
                    moog->freq = kernel->cutoffSmooth * (1 - ((1 + kernel->lfo2) / 2.0) * kernel->p[lfo2Amplitude]);
                } else {
                    moog->freq = kernel->cutoffSmooth;
                }
                moog->freq = moog->freq - moog->freq * kernel->p[filterADSRMix] * (1.0 - filter);
                
                if (moog->freq < 0.0) {
                    moog->freq = 0.0;
                }
                
                sp_oscmorph_compute(kernel->sp, oscmorph1, nil, &oscmorph1_out);
                oscmorph1_out *= kernel->p[morph1Volume];
                sp_oscmorph_compute(kernel->sp, oscmorph2, nil, &oscmorph2_out);
                oscmorph2_out *= kernel->p[morph2Volume];
                sp_crossfade_compute(kernel->sp, morphCrossFade, &oscmorph1_out, &oscmorph2_out, &osc_morph_out);
                sp_osc_compute(kernel->sp, subOsc, nil, &subOsc_out);
                if (kernel->p[subIsSquare]) {
                    if (subOsc_out > 0) {
                        subOsc_out = kernel->p[subVolume];
                    } else {
                        subOsc_out = -kernel->p[subVolume];
                    }
                } else {
                    subOsc_out *= kernel->p[subVolume] * 2.0; // the 2.0 is to match square's volume
                }
                sp_fosc_compute(kernel->sp, fmOsc, nil, &fmOsc_out);
                fmOsc_out *= kernel->p[fmVolume];
                sp_noise_compute(kernel->sp, noise, nil, &noise_out);
                noise_out *= kernel->p[noiseVolume];
                
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
        AKSoundpipeKernel::init(_channels, _sampleRate);
        sp_ftbl_create(sp, &sine, 2048);
        sp_gen_sine(sp, sine);

        sp_phasor_create(&lfo1Phasor);
        sp_phasor_init(sp, lfo1Phasor, 0);
        sp_phasor_create(&lfo2Phasor);
        sp_phasor_init(sp, lfo2Phasor, 0);

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
        
        sp_bitcrush_create(&bitcrush);
        sp_bitcrush_init(sp, bitcrush);

        sp_osc_create(&panOscillator);
        sp_osc_init(sp, panOscillator, sine, 0.0);
        sp_pan2_create(&pan);
        sp_pan2_init(sp, pan);

        sp_smoothdelay_create(&delayL);
        sp_smoothdelay_create(&delayR);
        sp_smoothdelay_create(&delayRR);
        sp_smoothdelay_create(&delayFillIn);

        sp_smoothdelay_init(sp, delayL, 5.0, 512);
        sp_smoothdelay_init(sp, delayR, 5.0, 512);
        sp_smoothdelay_init(sp, delayRR, 5.0, 512);
        sp_smoothdelay_init(sp, delayFillIn, 5.0, 512);

        sp_crossfade_create(&delayCrossfadeL);
        sp_crossfade_create(&delayCrossfadeR);
        sp_crossfade_init(sp, delayCrossfadeL);
        sp_crossfade_init(sp, delayCrossfadeR);

        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
        sp_buthp_create(&buthpL);
        sp_buthp_init(sp, buthpL);
        sp_buthp_create(&buthpR);
        sp_buthp_init(sp, buthpR);
        sp_crossfade_create(&revCrossfadeL);
        sp_crossfade_create(&revCrossfadeR);
        sp_crossfade_init(sp, revCrossfadeL);
        sp_crossfade_init(sp, revCrossfadeR);

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

        playingNotesCount = 0;
        resetted = true;
    }

    void startNote(int note, int velocity) {
        noteStates[note].noteOn(note, velocity);
    }
    void startNote(int note, int velocity, float frequency) {
        noteStates[note].noteOn(note, velocity, frequency);
    }

    void stopNote(int note) {
        noteStates[note].noteOn(note, 0);
    }
//    standardBankKernelFunctions()

    void setParameters(float params[]) {
        for (int i = 0; i < 60; i++) {
            p[i] = params[i];
        }
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        p[address] = value; //clamp(value, -100000.0f, 100000.0f);
    }

    AUValue getParameter(AUParameterAddress address) {
        return p[address];
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
    }

    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override { \
        if (midiEvent.length != 3) return; \
        uint8_t status = midiEvent.data[0] & 0xF0; \
        switch (status) { \
            case 0x80 : {  \
                uint8_t note = midiEvent.data[1]; \
                if (note > 127) break; \
                noteStates[note].noteOn(note, 0); \
                break; \
            } \
            case 0x90 : {  \
                uint8_t note = midiEvent.data[1]; \
                uint8_t veloc = midiEvent.data[2]; \
                if (note > 127 || veloc > 127) break; \
                noteStates[note].noteOn(note, veloc); \
                break; \
            } \
            case 0xB0 : { \
                uint8_t num = midiEvent.data[1]; \
                if (num == 123) { \
                    NoteState* noteState = playingNotes; \
                    while (noteState) { \
                        noteState->clear(); \
                        noteState = noteState->next; \
                    } \
                    playingNotes = nullptr; \
                    playingNotesCount = 0; \
                } \
                break; \
            } \
        } \
    }

    void handleTempoSetting(float currentTempo) {
        if (currentTempo != tempo) {
//            setParameter(cutoff, currentTempo);
            tempo = currentTempo;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] = 0.0f;
            outR[i] = 0.0f;
        }
        
        if (p[isMono] == 1) {
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

        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {

            lfo1Phasor->freq = p[lfo1Rate];
            lfo2Phasor->freq = p[lfo2Rate];
            sp_phasor_compute(sp, lfo1Phasor, nil, &lfo1);
            sp_phasor_compute(sp, lfo2Phasor, nil, &lfo2);

            if (lfo1Shape == 0) { // Sine
                lfo1 = sin(lfo1 * M_PI * 2.0);
            } else if (lfo1Shape == 1) { // Square
                if (lfo1 > 0.5) {
                    lfo1 = 1.0;
                } else {
                    lfo1 = -1.0;
                }
            } else if (lfo1Shape == 2) { // Saw
                lfo1 = (lfo1- 0.5) * 2.0;
            } else if (lfo1Shape == 3) { // Reversed Saw
                lfo1 = (0.5 - lfo1) * 2.0;
            }

            if (lfo2Shape == 0) { // Sine
                lfo2 = sin(lfo2 * M_PI * 2.0);
            } else if (lfo2Shape == 1) { // Square
                if (lfo2 > 0.5) {
                    lfo2 = 1.0;
                } else {
                    lfo2 = -1.0;
                }
            } else if (lfo2Shape == 2) { // Saw
                lfo2 = (lfo2- 0.5) * 2.0;
            } else if (lfo2Shape == 3) { // Reversed Saw
                lfo2 = (0.5 - lfo2) * 2.0;
            }



            sp_port_compute(sp, multiplierPort, &(p[detuningMultiplier]), &detuningMultiplierSmooth);
            sp_port_compute(sp, balancePort, &(p[morphBalance]), &morphBalanceSmooth);
            sp_port_compute(sp, cutoffPort, &(p[cutoff]), &cutoffSmooth);
            sp_port_compute(sp, resonancePort, &(p[resonance]), &resonanceSmooth);
            float synthOut = outL[i];

            float bitCrushOut = 0.0;

            if (p[bitcrushLFO] == 1) {
                bitcrush->srate = p[bitCrushSampleRate] * (1 - ((1 + lfo1) / 2.0) * p[lfo1Amplitude]);
            } else if (p[bitcrushLFO] == 2) {
                bitcrush->srate = p[bitCrushSampleRate] * (1 - ((1 + lfo2) / 2.0) * p[lfo2Amplitude]);
            } else {
                bitcrush->srate = p[bitCrushSampleRate];
            }
            bitcrush->bitdepth = p[bitCrushDepth];
            sp_bitcrush_compute(sp, bitcrush, &synthOut, &bitCrushOut);

            float panL = 0.0;
            float panR = 0.0;

            float panValue = 0.0;
            panOscillator->freq = p[autoPanFrequency];
            panOscillator->amp = p[autoPanOn];
            sp_osc_compute(sp, panOscillator, nil, &panValue);
            pan->pan = panValue;
            sp_pan2_compute(sp, pan, &bitCrushOut, &panL, &panR);

            float delayOutL = 0.0;
            float delayOutR = 0.0;
            float delayOutRR = 0.0;
            float delayFillInOut = 0.0;

            delayL->del = p[delayTime];
            delayR->del = p[delayTime];
            delayRR->del = p[delayTime]/2.0;
            delayFillIn->del = p[delayTime]/2.0;
            delayL->feedback = p[delayFeedback];
            delayR->feedback = p[delayFeedback];

            sp_smoothdelay_compute(sp, delayL, &panL, &delayOutL);
            sp_smoothdelay_compute(sp, delayR, &panR, &delayOutR);
            sp_smoothdelay_compute(sp, delayFillIn, &panR, &delayFillInOut);
            sp_smoothdelay_compute(sp, delayRR, &delayOutR, &delayOutRR);

            delayOutRR += delayFillInOut;

            float mixedDelayL = 0.0;
            float mixedDelayR = 0.0;
            delayCrossfadeL->pos = p[delayMix] * p[delayOn];
            delayCrossfadeR->pos = p[delayMix] * p[delayOn];
            sp_crossfade_compute(sp, delayCrossfadeL, &panL, &delayOutL, &mixedDelayL);
            sp_crossfade_compute(sp, delayCrossfadeR, &panR, &delayOutRR, &mixedDelayR);


            float revOutL = 0.0;
            float revOutR = 0.0;
//            revsc->lpfreq = p[reverbCutoff];
            revsc->feedback = p[reverbFeedback];
            
            sp_revsc_compute(sp, revsc, &mixedDelayL, &mixedDelayR, &revOutL, &revOutR);

            float butOutL = 0.0;
            float butOutR = 0.0;

            buthpL->freq = p[reverbHighPass];
            buthpR->freq = p[reverbHighPass];
            sp_buthp_compute(sp, buthpL, &revOutL, &butOutL);
            sp_buthp_compute(sp, buthpL, &revOutL, &butOutL);


            float finalOutL = 0.0;
            float finalOutR = 0.0;
            revCrossfadeL->pos = p[reverbMix] * p[reverbOn];
            revCrossfadeR->pos = p[reverbMix] * p[reverbOn];
            sp_crossfade_compute(sp, revCrossfadeL, &mixedDelayL, &butOutL, &finalOutL);
            sp_crossfade_compute(sp, revCrossfadeR, &mixedDelayR, &butOutR, &finalOutR);

            outL[i] = finalOutL * p[masterVolume];
            outR[i] = finalOutR * p[masterVolume];
//            outL[i] *= 0.5f;
//            outR[i] *= 0.5f;
        }
    }
    

    // MARK: Member Variables

private:
    std::vector<NoteState> noteStates;
    
    sp_ftbl *ft_array[4];
    UInt32 tbl_size = 4096;

    sp_phasor *lfo1Phasor;
    sp_phasor *lfo2Phasor;

    sp_ftbl *sine;

    sp_bitcrush *bitcrush;

    sp_pan2 *pan;
    sp_osc *panOscillator;

    sp_smoothdelay *delayL;
    sp_smoothdelay *delayR;
    sp_smoothdelay *delayRR;
    sp_smoothdelay *delayFillIn;

    sp_crossfade *delayCrossfadeL;
    sp_crossfade *delayCrossfadeR;

    sp_revsc *revsc;
    sp_buthp *buthpL;
    sp_buthp *buthpR;
    sp_crossfade *revCrossfadeL;
    sp_crossfade *revCrossfadeR;

    sp_port *midiNotePort;
    float midiNote = 0.0;
    float midiNoteSmooth = 0.0;
    
    sp_port *multiplierPort;
    sp_port *balancePort;
    sp_port *cutoffPort;
    sp_port *resonancePort;

    float tempo = 0.0;
public:

    bool resetted = false;

    float p[60] = {
        0, // index1
        0, // index2
        0.5, // morphBalance
        0, // morph1SemitoneOffset
        0, // morph2SemitoneOffset
        1, // morph1Volume
        1, // morph2Volume
        0, // subVolume
        0, // subOctaveDown
        0, // subIsSquare
        0, // fmVolume
        0, // fmAmount
        0, // noiseMix
        0, // lfo1Index
        1, // lfo1Amplitude
        0, // lfo1Rate
        1000, // cutoff
        0.5, // resonance
        0.5, // filterMix
        0.5, // filterADSRMix
        0, // isMono
        0, // glide
        0.1, // filterAttackDuration
        0.1, // filterDecayDuration
        1, // filterSustainLevel
        0.1, // filterReleaseDuration
        0.1, // attackDuration
        0.1, // decayDuration
        0.1, // sustainLevel
        0.1, // releaseDuration
        0, // detuningOffset
        1, // detuningMultiplier
        0.8, // masterVolume
        24, // bitDepth
        44100, // sampleRate
        0, // autoPanOn
        0, // autoPanFrequency
        0, // reverbOn
        0, // reverbFeedback
        1000, // reverbHighPass
        0, // reverbMix
        0, // delayOn
        0, // delayTime
        0, // delayFeedback
        0, // delayMix
        0, // lfo2Index
        1, // lfo2Amplitude
        0, // lfo2Rate
        0, // cutoffLFO
        0, // resonanceLFO
        0, // oscMixLFO
        0, // sustainLFO
        0, // index1LFO
        0, // index2LFO
        0, // fmLFO
        0, // detuneLFO
        0, // filterEnvLFO
        0, // pitchLFO
        0, // bitcrushLFO
        0 // autoPanLFO
    };

    // Ported values
    float morphBalanceSmooth = 0.5666;
    float detuningMultiplierSmooth = 1.66;
    float cutoffSmooth = 1666;
    float resonanceSmooth = 0.5;

    float lfo1 = 0.0;
    float lfo2 = 0.0;
    float lfo1Shape = 0;
    float lfo2Shape = 0;

    NoteState* playingNotes = nullptr;
    int playingNotesCount = 0;

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
};

