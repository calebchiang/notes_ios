//
//  AiFeaturesView.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-20.
//

import SwiftUI

struct AiFeaturesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(Color.secondary.opacity(0.15))
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    Text("Generate Smart Notes")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack(spacing: 12) {
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.red)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.red.opacity(0.15))
                                )
                            
                            Text("Upload YouTube URL")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        
                        Text("Paste a YouTube link and instantly transform any video into structured, easy-to-review smart notes.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                colorScheme == .dark
                                ? Color.red.opacity(0.18)
                                : Color.red.opacity(0.08)
                            )
                    )
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack(spacing: 12) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.orange)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.orange.opacity(0.15))
                                )
                            
                            Text("Record Audio")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        
                        Text("Record a lecture, meeting, or live presentation and generate clean, structured smart notes in seconds.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                colorScheme == .dark
                                ? Color.orange.opacity(0.18)
                                : Color.orange.opacity(0.08)
                            )
                    )
                    .padding(.horizontal)
                    
                    Text("Practice")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.blue)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.15))
                                )
                            
                            Text("Generate Flashcards")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        
                        Text("Turn your notes into smart flashcards to reinforce key concepts and improve retention.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                colorScheme == .dark
                                ? Color.blue.opacity(0.18)
                                : Color.blue.opacity(0.08)
                            )
                    )
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.green)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.15))
                                )
                            
                            Text("Practice Quiz")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        
                        Text("Automatically generate practice questions to test your understanding and strengthen recall.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                colorScheme == .dark
                                ? Color.green.opacity(0.18)
                                : Color.green.opacity(0.08)
                            )
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
}
