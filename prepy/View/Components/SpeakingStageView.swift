//
//  SpeakingStageView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI
internal import Combine

struct SpeakingStageView: View {
    @State private var isRecording: Bool = false
    @State private var recordingTime: Int = 0
    @State private var hasRecording: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            // Question card
            VStack(alignment: .leading, spacing: 16) {
                Text("PART 1 - QUESTION 1")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                    .tracking(1)
                
                Text("Describe a time when you visited an urban garden or farm. You should say:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    BulletPoint(text: "Where it was")
                    BulletPoint(text: "When you went there")
                    BulletPoint(text: "What you saw and did")
                    BulletPoint(text: "How you felt about the experience")
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                    Text("Preparation time: 1 minute")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.15))
            )
            
            // Recording interface
            VStack(spacing: 20) {
                // Waveform animation
                RecordingWaveform(isRecording: isRecording)
                
                // Timer display
                Text(formatRecordingTime(recordingTime))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(isRecording ? .orange : .white)
                
                // Recording controls
                HStack(spacing: 24) {
                    if hasRecording {
                        Button(action: {
                            // Delete recording
                            hasRecording = false
                            recordingTime = 0
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    
                    // Main record button
                    Button(action: {
                        isRecording.toggle()
                        if !isRecording {
                            hasRecording = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : Color.orange)
                                .frame(width: 80, height: 80)
                            
                            if isRecording {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                            } else {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                    if hasRecording {
                        Button(action: {
                            // Play recording
                            print("Play recording")
                        }) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Text(isRecording ? "Recording..." : hasRecording ? "Tap to re-record" : "Tap to start recording")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.08))
            )
        }
        .padding(.horizontal, 20)
        .onReceive(timer) { _ in
            if isRecording {
                recordingTime += 1
            }
        }
    }
    
    private func formatRecordingTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)
                .padding(.top, 7)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct RecordingWaveform: View {
    let isRecording: Bool
    @State private var amplitudes: [CGFloat] = Array(repeating: 0.3, count: 30)
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<30) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isRecording ? Color.orange : Color.gray.opacity(0.3))
                    .frame(width: 4, height: amplitudes[index] * 80)
                    .animation(.easeInOut(duration: 0.1), value: amplitudes[index])
            }
        }
        .frame(height: 80)
        .onReceive(timer) { _ in
            if isRecording {
                withAnimation {
                    amplitudes = amplitudes.map { _ in CGFloat.random(in: 0.3...1.0) }
                }
            } else {
                amplitudes = Array(repeating: 0.3, count: 30)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            SpeakingStageView()
        }
    }
}
