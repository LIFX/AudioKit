//: ## Playback Speed
//: This playground uses the AKVariSpeed node to change the playback speed of a file
//: (which also affects the pitch)
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true

var variSpeed = AKVariSpeed(player)
variSpeed.rate = 2.0

AudioKit.output = variSpeed
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Playback Speed")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: variSpeed))

        addSubview(AKPropertySlider(property: "Rate", value: variSpeed.rate, range: 0.312_5 ... 5) { sliderValue in
            variSpeed.rate = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
