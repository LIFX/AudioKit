//: ## Band Pass Butterworth Filter
//: Band-pass filters allow audio above a specified frequency range and
//: bandwidth to pass through to an output. The center frequency is the starting point
//: from where the frequency limit is set. Adjusting the bandwidth sets how far out
//: above and below the center frequency the frequency band should be.
//: Anything above that band should pass through.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0], baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a band pass filter
var filter = AKBandPassButterworthFilter(player)
filter.centerFrequency = 5_000 // Hz
filter.bandwidth = 600 // Cents
filter.rampTime = 1.0
AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Band Pass Butterworth Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(property: "Center Frequency",
                                    value: filter.centerFrequency,
                                    range: 20 ... 22_050,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            filter.centerFrequency = sliderValue
        })

        addSubview(AKPropertySlider(property: "Bandwidth",
                                    value: filter.bandwidth,
                                    range: 100 ... 1_200,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            filter.bandwidth = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
