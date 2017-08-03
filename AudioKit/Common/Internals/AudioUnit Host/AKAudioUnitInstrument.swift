//
//  AKAudioUnitInstrument.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

open class AKAudioUnitInstrument: AKMIDIInstrument {
    
    public init?(audioUnit: AVAudioUnitMIDIInstrument) {
        super.init()
        self.midiInstrument = audioUnit
        
        AudioKit.engine.attach(audioUnit)

        // assign the output to the mixer
        self.avAudioNode = audioUnit
        
        self.name = audioUnit.name
        
    }
    
    open func play(noteNumber: MIDINoteNumber,
                    velocity: MIDIVelocity = 64,
                    channel: MIDIChannel = 0) {

        guard self.midiInstrument != nil else { return }
        self.midiInstrument!.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
    }

    override open func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel = 0) {
        guard self.midiInstrument != nil else { return }
        self.midiInstrument!.stopNote(noteNumber, onChannel: channel)
    }
    
}
