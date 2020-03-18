//
//  MainViewPresenter.swift
//  Anonymous
//
//  Created by Mamunul Mazid on 18/3/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import AVFoundation
import CoreGraphics
import Foundation

class MainViewPresenter: ObservableObject, PlayerDelegate {
    var avPlayerLayer: AVPlayerLayer?
    private var player = BasicPlayer()
    private var videoUrl: URL?
    @Published var updatePlayer = false
    private var isPlaying = true
    @Published var sliderValue: Float = 0.0
    @Published var playButtonText: String = "Pause"
    var videoSize: CGSize?

    init() {
        avPlayerLayer = AVPlayerLayer()
        videoUrl = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        startPlayer(with: &avPlayerLayer!)
        playPlayer()
    }

    func setFrame(rect: CGRect) {
        avPlayerLayer?.frame = rect
    }

    // MARK: - Player operation -

    func startPlayer(with layer: inout AVPlayerLayer) {
        guard let url = self.videoUrl else { return }
        player.startWithMedia(url: url, drawingLayer: &layer)
        player.delegate = self
    }

    func playPlayer() {
        player.play()
    }

    func pausePlayer() {
        player.pause()
    }

    func seekPlayer(to normalizedPosition: Float) throws {
        try player.seek(to: normalizedPosition)
    }

    // MARK: - View Event -

    func onPlayButtonClicked() {
        isPlaying.toggle()

        if isPlaying {
            playPlayer()
            playButtonText = "Pause"
        } else {
            pausePlayer()
            playButtonText = "Play"
        }
    }

    func onSliderValueUpdated() {
        do {
            try seekPlayer(to: sliderValue)
        } catch {
        }
    }

    func onSeek(to normalizedPosition: Float) {
        sliderValue = normalizedPosition
    }

    func onUpdateVideoFrame(size: CGSize) {
        updatePlayer = true
        videoSize = size
    }
}
