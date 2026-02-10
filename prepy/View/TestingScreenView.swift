//
//  TestingScreenView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI
internal import Combine

enum TestStage: String, CaseIterable {
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    case speaking = "Speaking"
    
    var color: Color {
        switch self {
        case .listening: return .green
        case .reading: return .orange
        case .writing: return .gray
        case .speaking: return .gray
        }
    }
    
    var isCompleted: Bool {
        switch self {
        case .listening: return true
        case .reading, .writing, .speaking: return false
        }
    }
    
    var isActive: Bool {
        switch self {
        case .reading: return true
        case .listening, .writing, .speaking: return false
        }
    }
}

struct TestingView: View {
    @State private var currentStage: TestStage = .reading
    @State private var currentPassage: Int = 1
    @State private var totalPassages: Int = 3
    @State private var timeRemaining: Int = 1122 // seconds (18:42)
    @State private var isPaused: Bool = false
    @State private var showQuestions: Bool = false
    
    // Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation bar
                TestStageNavigation(
                    stages: TestStage.allCases,
                    currentStage: currentStage,
                    isPaused: $isPaused
                )
                
                // Content area
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Passage header
                        PassageHeader(
                            passageNumber: currentPassage,
                            totalPassages: totalPassages,
                            title: "Urban Agriculture",
                            timeRemaining: timeRemaining
                        )
                        
                        // Passage image
                        PassageImage()
                        
                        // Passage text
                        PassageText()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Bottom button
                ViewQuestionsButton(showQuestions: $showQuestions)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
        }
        .onReceive(timer) { _ in
            if !isPaused && timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
}

#Preview {
    TestingView()
}
