//
//  PassageTextView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct PassageText: View {
    let passageContent = """
By 2050, nearly 80% of the earth's population will reside in urban centers. Applying the most conservative estimates to current demographic trends, the human population will increase by about 3 billion people during the interim. An estimated 109 hectares of new land (about 20% more land than is represented by the country of Brazil) will be needed to grow enough food to feed them, if traditional farming practices continue as they are practiced today.
"""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // First paragraph with drop cap
            HStack(alignment: .top, spacing: 8) {
                Text("B")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.top, -8)
                
                Text("y 2050, nearly 80% of the earth's population will reside in urban centers. Applying the most conservative estimates to current demographic trends, the human population will increase by about 3 billion people during the interim. An estimated 109 hectares of new land (about 20% more land than is represented by the country of Brazil) will be needed to grow enough food to feed them, if traditional farming")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                    .lineSpacing(6)
            }
            
            // Additional paragraphs would go here
            // For demonstration, using placeholder text
            Text("practices continue as they are practiced today. At present, throughout the world, over 80% of the land that is suitable for raising crops is in use. Historically, some 15% of that has been laid waste by poor management practices.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .lineSpacing(6)
        }
        .padding(.bottom, 100) // Extra padding for bottom button
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            PassageText()
                .padding()
        }
    }
}
