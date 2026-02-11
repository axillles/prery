//
//  SpeakingStageScreenView.swift
//  prepy
//
//  Экран Speaking: задание, центральный круг (картинка), подсказка, волна от микрофона, кнопка микрофона.
//

import SwiftUI

struct SpeakingStageScreenView: View {
    @StateObject private var audioCapture = AudioLevelCapture()
    @State private var isMuted = false
    @State private var timeRemaining = 105 // 01:45

    private let backgroundColor = Color(white: 0.08)
    private let accentOrange = Color.orange

    private var timeFormatted: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        taskHeader
                        centralVoiceArea
                        promptText
                        waveformView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 140)
                }
                .scrollIndicators(.hidden)

                micButtonSection
            }
        }
        .onAppear {
            if !isMuted {
                audioCapture.requestPermissionAndStart()
            }
        }
        .onDisappear {
            audioCapture.stop()
        }
        .onChange(of: isMuted) { muted in
            if muted {
                audioCapture.stop()
            } else {
                audioCapture.requestPermissionAndStart()
            }
        }
    }

    // MARK: - Task Header (PART 2 OF 3, title, timer)

    private var taskHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("PART 2 OF 3")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accentOrange)
                    .tracking(1)
                Text("Describe a memorable journey")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(accentOrange)
                Text(timeFormatted)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.18)))
        }
    }

    // MARK: - Central circle (placeholder image — замените на свою картинку)

    private var centralVoiceArea: some View {
        ZStack {
            // Внешнее свечение
            Circle()
                .stroke(accentOrange.opacity(0.5), lineWidth: 3)
                .frame(width: 260, height: 260)
                .shadow(color: accentOrange.opacity(0.4), radius: 20)

            // Внутренний тёмный круг
            Circle()
                .fill(Color(white: 0.12))
                .frame(width: 220, height: 220)
                .overlay(
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                        .foregroundColor(Color.white.opacity(0.15))
                )

            // Плейсхолдер: замените на свою картинку (например Image("owl") из Assets)
            Image(systemName: "face.smiling")
                .font(.system(size: 72))
                .foregroundColor(accentOrange.opacity(0.9))
        }
        .padding(.vertical, 8)
    }

    private var promptText: some View {
        Text("Can you tell me more about why that journey was so special to you?")
            .font(.system(size: 17))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    // MARK: - Волна по реальному уровню микрофона

    private var waveformView: some View {
        HStack(spacing: 4) {
            ForEach(0..<audioCapture.levels.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isMuted ? Color.gray.opacity(0.4) : accentOrange)
                    .frame(
                        width: 4,
                        height: max(8, audioCapture.levels[i] * 56)
                    )
                    .animation(.easeOut(duration: 0.08), value: audioCapture.levels[i])
            }
        }
        .frame(height: 56)
    }

    // MARK: - Кнопка микрофона (Tap to Mute)

    private var micButtonSection: some View {
        VStack(spacing: 12) {
            Button {
                isMuted.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(isMuted ? Color.gray : accentOrange)
                        .frame(width: 80, height: 80)
                        .shadow(color: (isMuted ? Color.gray : accentOrange).opacity(0.4), radius: 12)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            Text(isMuted ? "Tap to unmute" : "Tap to Mute")
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}

#Preview {
    SpeakingStageScreenView()
}
