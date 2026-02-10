//
//  WrittingStageView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct WritingStageView: View {
    @State private var essayText: String = ""
    @State private var wordCount: Int = 0
    let minimumWords: Int = 250
    
    var body: some View {
        VStack(spacing: 20) {
            // Task description
            VStack(alignment: .leading, spacing: 12) {
                Text("TASK 1")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                    .tracking(1)
                
                Text("Write an essay discussing the advantages and disadvantages of urban agriculture. Give reasons for your answer and include any relevant examples from your own knowledge or experience.")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.15))
            )
            
            // Writing area
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "bold")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(white: 0.2))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "italic")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(white: 0.2))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "underline")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(white: 0.2))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Word counter
                    HStack(spacing: 4) {
                        Text("\(wordCount)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(wordCount >= minimumWords ? .green : .orange)
                        
                        Text("/ \(minimumWords) words")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .background(Color(white: 0.1))
                
                // Text editor
                TextEditor(text: $essayText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color(white: 0.05))
                    .frame(minHeight: 400)
                    .onChange(of: essayText) { oldValue, newValue in
                        wordCount = newValue.split(separator: " ").count
                    }
            }
            .background(Color(white: 0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(white: 0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            WritingStageView()
        }
    }
}
