//
//  ListeningStageView.swift
//  prepy
//
//  Created for prepy.
//

import SwiftUI

struct ListeningStageView: View {
    @Binding var isPaused: Bool
    let timeRemaining: Int
    
    // 5:30 = 330 sec total for Part 1
    private let partDuration = 330
    private var elapsed: Int { partDuration - timeRemaining }
    private var elapsedFormatted: String {
        let m = elapsed / 60
        let s = elapsed % 60
        return String(format: "%02d:%02d", m, s)
    }
    private var totalFormatted: String {
        let m = partDuration / 60
        let s = partDuration % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    @State private var selectedQuestion1: Int? = nil
    @State private var selectedQuestion2: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // AUDIO PART 1
                audioPlayerSection
                
                // Questions 1-5
                questionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var audioPlayerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AUDIO PART 1")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.orange)
                }
                
                // Упрощённая визуализация волны (оранжевые полосы)
                HStack(spacing: 4) {
                    ForEach(0..<24, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i < 10 ? Color.orange : Color.orange.opacity(0.35))
                            .frame(width: 4, height: CGFloat([20, 32, 24, 40, 18, 36, 28, 22, 38, 30, 24, 34, 26, 42, 20, 30, 28, 36, 22, 40, 26, 32, 24, 28][i % 24]))
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text("\(elapsedFormatted) / \(totalFormatted)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(Color(white: 0.12))
            .cornerRadius(16)
        }
    }
    
    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Questions 1-5")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("Part 1")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.2))
                    .cornerRadius(8)
            }
            
            // Question 1
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 4) {
                    Text("1.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                    Text("What is the customer's primary reason for calling the insurance company?")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                listeningOption(index: 1, selected: $selectedQuestion1, text: "To renew an existing car insurance policy.")
                listeningOption(index: 2, selected: $selectedQuestion1, text: "To inquire about a quote for a new vehicle.")
                listeningOption(index: 3, selected: $selectedQuestion1, text: "To file a claim for a recent accident.")
            }
            
            // Question 2
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text("2.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                    Text(" Which type of coverage does the agent recommend?")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                listeningOption(index: 1, selected: $selectedQuestion2, text: "Comprehensive only")
                listeningOption(index: 2, selected: $selectedQuestion2, text: "Third-party only")
                listeningOption(index: 3, selected: $selectedQuestion2, text: "Both comprehensive and third-party")
            }
        }
    }
    
    private func listeningOption(index: Int, selected: Binding<Int?>, text: String) -> some View {
        Button {
            selected.wrappedValue = selected.wrappedValue == index ? nil : index
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: selected.wrappedValue == index ? "circle.inset.filled" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(selected.wrappedValue == index ? .orange : .gray)
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(Color(white: 0.12))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

/// Кнопка «Submit Part 1» для экрана Listening
struct SubmitPartButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text("Submit Part 1")
                    .font(.system(size: 18, weight: .semibold))
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.orange)
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ListeningStageView(isPaused: .constant(false), timeRemaining: 196)
    }
}
