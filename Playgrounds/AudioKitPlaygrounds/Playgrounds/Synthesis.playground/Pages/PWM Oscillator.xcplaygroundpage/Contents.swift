//: ## PWM Oscillator
//:
import AudioKitPlaygrounds
import AudioKit

var oscillator = AKPWMOscillator()
oscillator.pulseWidth = 0.5

var currentMIDINote: MIDINoteNumber = 0
var currentAmplitude = 0.1
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("PWM Oscillator")

        addSubview(AKPropertySlider(property: "Amplitude", value: currentAmplitude) { sliderValue in
            currentAmplitude = sliderValue
        })

        addSubview(AKPropertySlider(property: "Pulse Width", value: oscillator.pulseWidth) { sliderValue in
            oscillator.pulseWidth = sliderValue
        })

        addSubview(AKPropertySlider(property: "Ramp Time",
                                    value: currentRampTime,
                                    range: 0 ... 2,
                                    format: "%0.3f s"
        ) { sliderValue in
            currentRampTime = sliderValue
        })

        let keyboard = AKKeyboardView(width: playgroundWidth - 60, height: 100)
        keyboard.delegate = self
        addSubview(keyboard)
    }

    func noteOn(note: MIDINoteNumber) {
        currentMIDINote = note
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampTime = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()

        // Still use rampTime for volume
        oscillator.rampTime = currentRampTime
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }

    func noteOff(note: MIDINoteNumber) {
        if currentMIDINote == note {
            oscillator.amplitude = 0
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
