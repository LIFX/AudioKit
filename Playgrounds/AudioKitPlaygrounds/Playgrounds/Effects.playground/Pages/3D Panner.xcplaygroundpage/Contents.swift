//: ## 3D Panner
//: ###
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0], baseDir: .resources)
let player = try AKAudioPlayer(file: file)
player.looping = true

let panner = AK3DPanner(player)

AudioKit.output = panner
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("3D Panner")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKPropertySlider(property: "X", value: panner.x, range: -10 ... 10) { sliderValue in
            panner.x = sliderValue
        })

        addSubview(AKPropertySlider(property: "Y", value: panner.y, range: -10 ... 10) { sliderValue in
            panner.y = sliderValue
        })

        addSubview(AKPropertySlider(property: "Z", value: panner.z, range: -10 ... 10) { sliderValue in
            panner.z = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
