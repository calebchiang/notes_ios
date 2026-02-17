//
//  CreateNotebookView.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-16.
//

import SwiftUI

struct CreateNotebookView: View {
    var onCreated: (() -> Void)?
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var selectedColorHex: String = "#3B82F6"
    @State private var customColor: Color = .blue
    @State private var isCustomSelected: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let colorOptions: [String] = [
        "#3B82F6",
        "#EF4444",
        "#10B981",
        "#F59E0B",
        "#8B5CF6",
        "#EC4899"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Top right X
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            Text("New Notebook")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Title")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("e.g. Biology 12, Psychology 101", text: $title)
                    .textInputAutocapitalization(.words)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }

            // Color Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Color")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 16) {
                    
                    // Preset Colors
                    ForEach(colorOptions, id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(
                                        (!isCustomSelected && selectedColorHex == hex) ? Color.primary : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .onTapGesture {
                                selectedColorHex = hex
                                isCustomSelected = false
                            }
                    }
                    
                    // Direct ColorPicker Circle
                    ColorPicker("", selection: $customColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 30, height: 30)
                        .background(customColor)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isCustomSelected ? Color.primary : Color.clear, lineWidth: 2)
                        )
                        .onChange(of: customColor) { _, newColor in
                               selectedColorHex = newColor.toHex()
                               isCustomSelected = true
                           }
                }
            }
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Button(action: {
                createNotebook()
            }) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Create Notebook")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(title.isEmpty || isLoading ? Color.gray : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(title.isEmpty || isLoading)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    private func createNotebook() {
        isLoading = true
        errorMessage = nil
        
        let body: [String: Any] = [
            "title": title,
            "color": selectedColorHex
        ]
        
        RequestManager.shared.sendRequest(
            endpoint: "/notebooks",
            method: "POST",
            body: body,
            responseType: Notebook.self
        ) { result in
            
            isLoading = false
            
            switch result {
            case .success:
                lightHaptic()
                onCreated?()
                dismiss()
            case .failure(let error):
                errorMessage = "Failed to create notebook."
                print("Create notebook error:", error)
            }
        }
    }
    
    private func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

