//
//  AudioLevelCapture.swift
//  prepy
//
//  Захват уровня звука с микрофона в реальном времени для визуализации волны.
//

import AVFoundation
import SwiftUI
internal import Combine

/// Публикует массив последних уровней (0...1) для отрисовки волны. Обновления приходят на main queue.
final class AudioLevelCapture: NSObject, ObservableObject {
    @Published private(set) var levels: [CGFloat] = Array(repeating: 0.15, count: 40)
    @Published private(set) var isRunning = false
    @Published private(set) var permissionGranted: Bool?

    private let engine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private let barCount = 40
    private var buffer: [CGFloat] = []
    private let smoothing: CGFloat = 0.3
    private var lastLevel: CGFloat = 0.15

    override init() {
        inputNode = engine.inputNode
        super.init()
        buffer = Array(repeating: 0.15, count: barCount)
    }

    func requestPermissionAndStart() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if granted {
                    self?.start()
                }
            }
        }
    }

    func start() {
        guard permissionGranted == true else {
            requestPermissionAndStart()
            return
        }
        guard !isRunning else { return }

        let format = inputNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else { return }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        do {
            try engine.start()
            DispatchQueue.main.async { [weak self] in
                self?.isRunning = true
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.isRunning = false
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        inputNode.removeTap(onBus: 0)
        engine.stop()
        DispatchQueue.main.async { [weak self] in
            self?.isRunning = false
            self?.levels = Array(repeating: 0.15, count: self?.barCount ?? 40)
        }
    }

    private func processBuffer(_ pcmBuffer: AVAudioPCMBuffer) {
        guard let channelData = pcmBuffer.floatChannelData?[0] else { return }
        let frameLength = Int(pcmBuffer.frameLength)
        guard frameLength > 0 else { return }

        var sum: Float = 0
        for i in 0..<frameLength {
            sum += abs(channelData[i])
        }
        let average = sum / Float(frameLength)
        let normalized = min(1.0, CGFloat(average) * 8)
        let smoothed = lastLevel * (1 - smoothing) + normalized * smoothing
        lastLevel = smoothed

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.buffer.removeFirst()
            self.buffer.append(smoothed)
            self.levels = self.buffer
        }
    }
}
