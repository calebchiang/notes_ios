//
//  AiChatView.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-20.
//

import SwiftUI

struct AiChatView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 44))
                .foregroundStyle(.primary)
            
            Text("Welcome to AI Chat")
                .font(.title.bold())
            
            Text("Here is where you’ll be able to ask questions about your notes and chat with AI.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("Feature COMING SOON.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary.opacity(0.7))
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.secondary.opacity(0.15))
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}
