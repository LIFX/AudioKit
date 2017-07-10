//
//  AKSynthOne.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Pulse-Width Modulating Oscillator Bank
///
open class AKSynthOne: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKSynthOneAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "aks1")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?
    
    fileprivate var waveformArray = [AKTable]()
    
    fileprivate var index1Parameter: AUParameter?
    fileprivate var index2Parameter: AUParameter?
    fileprivate var morphBalanceParameter: AUParameter?
    fileprivate var morph1PitchOffsetParameter: AUParameter?
    fileprivate var morph2PitchOffsetParameter: AUParameter?
    fileprivate var morph1MixParameter: AUParameter?
    fileprivate var morph2MixParameter: AUParameter?
    fileprivate var subOscMixParameter: AUParameter?
    fileprivate var subOscOctavesDownParameter: AUParameter?
    fileprivate var subOscIsSquareParameter: AUParameter?
    fileprivate var fmMixParameter: AUParameter?
    fileprivate var fmModParameter: AUParameter?
    fileprivate var noiseMixParameter: AUParameter?
    fileprivate var lfoIndexParameter: AUParameter?
    fileprivate var lfoAmplitudeParameter: AUParameter?
    fileprivate var lfoRateParameter: AUParameter?
    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?
    fileprivate var filterMixParameter: AUParameter?
    fileprivate var filterADSRMixParameter: AUParameter?
    fileprivate var isMonoParameter: AUParameter?
    fileprivate var glideParameter: AUParameter?
    fileprivate var filterAttackDurationParameter: AUParameter?
    fileprivate var filterDecayDurationParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseDurationParameter: AUParameter?
    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?
    fileprivate var detuningOffsetParameter: AUParameter?
    fileprivate var detuningMultiplierParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }
    open dynamic var index1: Double = 0 {
        willSet {
            if index1 != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        index1Parameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.index1 = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var index2: Double = 0 {
        willSet {
            if index2 != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        index2Parameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.index2 = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var morphBalance: Double = 0.5 {
        willSet {
            if morphBalance != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        morphBalanceParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.morphBalance = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var morph1PitchOffset: Double = 0 {
        willSet {
            if morph1PitchOffset != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        morph1PitchOffsetParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.morph1PitchOffset = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var morph2PitchOffset: Double = 0 {
        willSet {
            if morph2PitchOffset != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        morph2PitchOffsetParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.morph2PitchOffset = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var morph1Mix: Double = 1 {
        willSet {
            if morph1Mix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        morph1MixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.morph1Mix = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var morph2Mix: Double = 1 {
        willSet {
            if morph2Mix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        morph2MixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.morph2Mix = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var subOscMix: Double = 0 {
        willSet {
            if subOscMix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        subOscMixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.subOscMix = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var subOscOctavesDown: Double = 1 {
        willSet {
            if subOscOctavesDown != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        subOscOctavesDownParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.subOscOctavesDown = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var subOscIsSquare: Bool = false {
        willSet {
            if subOscIsSquare != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        subOscIsSquareParameter?.setValue(Float(newValue ? Float(1) : Float(0)), originator: existingToken)
                    }
                } else {
                    internalAU?.subOscIsSquare = newValue ? Float(1) : Float(0)
                }
            }
        }
    }
    
    open dynamic var fmMix: Double = 0 {
        willSet {
            if fmMix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        fmMixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.fmMix = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var fmMod: Double = 0 {
        willSet {
            if fmMod != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        fmModParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.fmMod = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var noiseMix: Double = 0 {
        willSet {
            if noiseMix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        noiseMixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.noiseMix = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var lfoIndex: Double = 0 {
        willSet {
            if lfoIndex != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        lfoIndexParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.lfoIndex = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var lfoAmplitude: Double = 1 {
        willSet {
            if lfoAmplitude != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        lfoAmplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.lfoAmplitude = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var lfoRate: Double = 1 {
        willSet {
            if lfoRate != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        lfoRateParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.lfoRate = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var cutoffFrequency: Double = 1000 {
        willSet {
            if cutoffFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        cutoffFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.cutoffFrequency = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var resonance: Double = 0.5 {
        willSet {
            if resonance != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        resonanceParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.resonance = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var filterMix: Double = 1 {
        willSet {
            if filterMix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        filterMixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterMix = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var filterADSRMix: Double = 0.5 {
        willSet {
            if filterADSRMix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        filterADSRMixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterADSRMix = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var isMono: Bool = false {
        willSet {
            if isMono != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        isMonoParameter?.setValue(Float(newValue ? Float(1) : Float(0)), originator: existingToken)
                    }
                } else {
                    internalAU?.isMono = newValue ? Float(1) : Float(0)
                }
            }
        }
    }
    
    open dynamic var glide: Double = 0 {
        willSet {
            if glide != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        glideParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.glide = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var filterAttackDuration: Double = 0.1 {
        willSet {
            if filterAttackDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        filterAttackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterAttackDuration = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var filterDecayDuration: Double = 0.1 {
        willSet {
            if filterDecayDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        filterDecayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterDecayDuration = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var filterSustainLevel: Double = 1 {
        willSet {
            if filterSustainLevel != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        filterSustainLevelParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterSustainLevel = Float(newValue)
                }
            }
        }
    }
    
    open dynamic var filterReleaseDuration: Double = 0.1 {
        willSet {
            if filterReleaseDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        filterReleaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterReleaseDuration = Float(newValue)
                }
            }
        }
    }
    
    /// Attack time
    open dynamic var attackDuration: Double = 0.1 {
        willSet {
            if attackDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        attackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.attackDuration = Float(newValue)
                }
            }
        }
    }
    /// Decay time
    open dynamic var decayDuration: Double = 0.1 {
        willSet {
            if decayDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        decayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.decayDuration = Float(newValue)
                }
            }
        }
    }
    /// Sustain Level
    open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        sustainLevelParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.sustainLevel = Float(newValue)
                }
            }
        }
    }
    /// Release time
    open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            if releaseDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        releaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.releaseDuration = Float(newValue)
                }
            }
        }
    }

    /// Frequency offset in Hz.
    open dynamic var detuningOffset: Double = 0 {
        willSet {
            if detuningOffset != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        detuningOffsetParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.detuningOffset = Float(newValue)
                }
            }
        }
    }

    /// Frequency detuning multiplier
    open dynamic var detuningMultiplier: Double = 1 {
        willSet {
            if detuningMultiplier != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        detuningMultiplierParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.detuningMultiplier = Float(newValue)
                }
            }
        }
    }

    // MARK: - Initialization

    /// Initialize the synth with defaults
    public convenience override init() {
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)])
    }

    /// Initialize this synth
    ///
    /// - Parameters:
    ///   - waveformArray:      An array of 4 waveforms
    ///
    public init(waveformArray: [AKTable]) {
        
        self.waveformArray = waveformArray
        
        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            
            for (i, waveform) in waveformArray.enumerated() {
                self?.internalAU?.setupWaveform(UInt32(i), size: Int32(UInt32(waveform.count)))
                for (j, sample) in waveform.enumerated() {
                    self?.internalAU?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        index1Parameter = tree["index1"]
        index2Parameter = tree["index2"]
        morphBalanceParameter = tree["morphBalance"]
        morph1PitchOffsetParameter = tree["morph1PitchOffset"]
        morph2PitchOffsetParameter = tree["morph2PitchOffset"]
        morph1MixParameter = tree["morph1Mix"]
        morph2MixParameter = tree["morph2Mix"]
        subOscMixParameter = tree["subOscMix"]
        subOscOctavesDownParameter = tree["subOscOctavesDown"]
        subOscIsSquareParameter = tree["subOscIsSquare"]
        fmMixParameter = tree["fmMix"]
        fmModParameter = tree["fmMod"]
        noiseMixParameter = tree["noiseMix"]
        lfoIndexParameter = tree["lfoIndex"]
        lfoAmplitudeParameter = tree["lfoAmplitude"]
        lfoRateParameter = tree["lfoRate"]
        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]
        filterMixParameter = tree["filterMix"]
        filterADSRMixParameter = tree["filterADSRMix"]
        isMonoParameter = tree["isMono"]
        glideParameter = tree["glide"]
        filterAttackDurationParameter = tree["filterAttackDuration"]
        filterDecayDurationParameter = tree["filterDecayDuration"]
        filterSustainLevelParameter = tree["filterSustainLevel"]
        filterReleaseDurationParameter = tree["filterReleaseDuration"]
        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]
        detuningOffsetParameter = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.index1Parameter?.address {
                    self?.index1 = Double(value)
                } else if address == self?.index2Parameter?.address {
                    self?.index2 = Double(value)
                } else if address == self?.morphBalanceParameter?.address {
                    self?.morphBalance = Double(value)
                } else if address == self?.morph1PitchOffsetParameter?.address {
                    self?.morph1PitchOffset = Double(value)
                } else if address == self?.morph2PitchOffsetParameter?.address {
                    self?.morph2PitchOffset = Double(value)
                } else if address == self?.morph1MixParameter?.address {
                    self?.morph1Mix = Double(value)
                } else if address == self?.morph2MixParameter?.address {
                    self?.morph2Mix = Double(value)
                } else if address == self?.subOscMixParameter?.address {
                    self?.subOscMix = Double(value)
                } else if address == self?.subOscOctavesDownParameter?.address {
                    self?.subOscOctavesDown = Double(value)
                } else if address == self?.subOscIsSquareParameter?.address {
                    self?.subOscIsSquare = Double(value) > 0.5 ? true : false
                } else if address == self?.fmMixParameter?.address {
                    self?.fmMix = Double(value)
                } else if address == self?.fmModParameter?.address {
                    self?.fmMod = Double(value)
                } else if address == self?.noiseMixParameter?.address {
                    self?.noiseMix = Double(value)
                } else if address == self?.lfoIndexParameter?.address {
                    self?.lfoIndex = Double(value)
                } else if address == self?.lfoAmplitudeParameter?.address {
                    self?.lfoAmplitude = Double(value)
                } else if address == self?.lfoRateParameter?.address {
                    self?.lfoRate = Double(value)
                } else if address == self?.cutoffFrequencyParameter?.address {
                    self?.cutoffFrequency = Double(value)
                } else if address == self?.resonanceParameter?.address {
                    self?.resonance = Double(value)
                } else if address == self?.filterMixParameter?.address {
                    self?.filterMix = Double(value)
                } else if address == self?.filterADSRMixParameter?.address {
                    self?.filterADSRMix = Double(value)
                } else if address == self?.isMonoParameter?.address {
                    self?.isMono = Double(value) > 0.5 ? true : false
                } else if address == self?.glideParameter?.address {
                    self?.glide = Double(value)
                } else if address == self?.filterAttackDurationParameter?.address {
                    self?.filterAttackDuration = Double(value)
                } else if address == self?.filterDecayDurationParameter?.address {
                    self?.filterDecayDuration = Double(value)
                } else if address == self?.filterSustainLevelParameter?.address {
                    self?.filterSustainLevel = Double(value)
                } else if address == self?.filterReleaseDurationParameter?.address {
                    self?.filterReleaseDuration = Double(value)
                } else if address == self?.attackDurationParameter?.address {
                    self?.attackDuration = Double(value)
                } else if address == self?.decayDurationParameter?.address {
                    self?.decayDuration = Double(value)
                } else if address == self?.sustainLevelParameter?.address {
                    self?.sustainLevel = Double(value)
                } else if address == self?.releaseDurationParameter?.address {
                    self?.releaseDuration = Double(value)
                } else if address == self?.detuningOffsetParameter?.address {
                    self?.detuningOffset = Double(value)
                } else if address == self?.detuningMultiplierParameter?.address {
                    self?.detuningMultiplier = Double(value)
                }
            }
        })
//        internalAU?.index1 = Float(index1)
//        internalAU?.index2 = Float(index2)
//        internalAU?.morphBalance = Float(morphBalance)
//        internalAU?.morph1PitchOffset = Float(morph1PitchOffset)
//        internalAU?.morph2PitchOffset = Float(morph2PitchOffset)
//        internalAU?.morph1Mix = Float(morph1Mix)
//        internalAU?.morph2Mix = Float(morph2Mix)
//        internalAU?.subOscMix = Float(subOscMix)
//        internalAU?.subOscOctavesDown = Float(subOscOctavesDown)
//        internalAU?.subOscIsSquare = Float(subOscIsSquare ? Float(1) : Float(0))
//        internalAU?.fmMix = Float(fmMix)
//        internalAU?.fmMod = Float(fmMod)
//        internalAU?.noiseMix = Float(noiseMix)
//        internalAU?.lfoIndex = Float(lfoIndex)
//        internalAU?.lfoAmplitude = Float(lfoAmplitude)
//        internalAU?.lfoRate = Float(lfoRate)
//        internalAU?.cutoffFrequency = Float(cutoffFrequency)
//        internalAU?.resonance = Float(resonance)
//        internalAU?.filterMix = Float(filterMix)
//        internalAU?.filterADSRMix = Float(filterADSRMix)
//        internalAU?.isMono = Float(isMono ? Float(1) : Float(0))
//        internalAU?.glide = Float(glide)
//        internalAU?.filterAttackDuration = Float(filterAttackDuration)
//        internalAU?.filterDecayDuration = Float(filterDecayDuration)
//        internalAU?.filterSustainLevel = Float(filterSustainLevel)
//        internalAU?.filterReleaseDuration = Float(filterReleaseDuration)
//        internalAU?.attackDuration = Float(attackDuration)
//        internalAU?.decayDuration = Float(decayDuration)
//        internalAU?.sustainLevel = Float(sustainLevel)
//        internalAU?.releaseDuration = Float(releaseDuration)
//        internalAU?.detuningOffset = Float(detuningOffset)
//        internalAU?.detuningMultiplier = Float(detuningMultiplier)
    }

    // MARK: - AKPolyphonic

    // Function to start, play, or activate the node at frequency
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.startNote(noteNumber, velocity: velocity, frequency: Float(frequency))
    }

    /// Function to stop or bypass the node, both are equivalent
    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }
}
