//
//  BasicPlayer.swift
//  Anonymous
//
//  Created by Mamunul Mazid on 10/1/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import AVFoundation
import Foundation

enum PlayerError: Error {
    case invalidSeekPosition
}

protocol PlayerDelegate: AnyObject {
    func onSeek(to normalizedPosition: Float)
    func onUpdateVideoFrame(size:CGSize)
}

protocol IPlayer {
    func play()
    func pause()
    func seek(to position: Float) throws
}

protocol IBasicPlayer: IPlayer {
    var delegate: PlayerDelegate? { get set }
    func startWithMedia(url: URL, drawingLayer: inout AVPlayerLayer)
}

class BasicPlayer: IBasicPlayer {
    weak var delegate: PlayerDelegate?

    private var dataSourceUrl: URL?
    private var player: AVPlayer?
    private var totalDuration: CMTime?
    var videoSize: CGSize?

    private func setupSeekObserver() {
        let intervalTime = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        player?.addPeriodicTimeObserver(
            forInterval: intervalTime,
            queue: DispatchQueue.main,
            using: { time in
                if self.videoSize == nil || self.videoSize != self.player?.currentItem?.presentationSize {
                    self.videoSize = self.player?.currentItem?.presentationSize
                    self.delegate?.onUpdateVideoFrame(size: self.videoSize!)
                }
                let sliderVaue = Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(self.totalDuration!))
                self.delegate?.onSeek(to: sliderVaue)
            }
        )
    }

    func startWithMedia(url: URL, drawingLayer: inout AVPlayerLayer) {
        dataSourceUrl = url
        player = AVPlayer(url: dataSourceUrl!)
        drawingLayer.player = player

        player?.play()
        player?.pause()
        drawingLayer.videoGravity = .resizeAspect
        totalDuration = (player?.currentItem?.asset.duration)
        setupSeekObserver()
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func seek(to normalizedPosition: Float) throws {
        guard normalizedPosition >= 0 && normalizedPosition <= 1.0 else {
            throw PlayerError.invalidSeekPosition
        }
        let seekTimeInSecond =
            CMTimeMultiplyByRatio(totalDuration!, multiplier: Int32(normalizedPosition * 100), divisor: 100)
        player!.seek(to: seekTimeInSecond)
    }
}
