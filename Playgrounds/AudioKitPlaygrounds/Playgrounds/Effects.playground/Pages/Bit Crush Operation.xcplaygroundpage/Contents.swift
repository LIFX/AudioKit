//: ## Bit Crush Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { input, parameters in
    let baseSampleRate = parameters[0]
    let sampleRateVariation = parameters[1]
    let baseBitDepth = parameters[2]
    let bitDepthVariation = parameters[3]
    let frequency = parameters[4]

    let sinusoid = AKOperation.sineWave(frequency: frequency)
    let sampleRate = baseSampleRate + sinusoid * sampleRateVariation
    let bitDepth = baseBitDepth + sinusoid * bitDepthVariation

    return input.bitCrush(bitDepth: bitDepth, sampleRate: sampleRate)
}
effect.parameters = [22_050, 0, 16, 0, 1]

AudioKit.output = effect
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Bit Crush Operation")
        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKPropertySlider(property: "Base Sample Rate",
                                    value: effect.parameters[0],
                                    range: 300 ... 22_050,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addSubview(AKPropertySlider(property: "Sample Rate Variation",
                                    value: effect.parameters[1],
                                    range: 0 ... 8_000,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addSubview(AKPropertySlider(property: "Base Bit Depth",
                                    value: effect.parameters[2],
                                    range: 1 ... 24
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
        addSubview(AKPropertySlider(property: "Bit Depth Variation",
                                    value: effect.parameters[3],
                                    range: 0 ...12,
                                    format: "%0.3f Hz"
        ) { sliderValue in
            effect.parameters[3] = sliderValue
        })
        addSubview(AKPropertySlider(property: "Frequency",
                                    value: effect.parameters[4],
                                    range: 0 ... 5,
                                    format: "%0.3f Hz"
        ) { sliderValue in
            effect.parameters[4] = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
