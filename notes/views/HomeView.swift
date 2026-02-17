//
//  HomeView.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-16.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    @State private var notebooks: [Notebook] = []
    @State private var isLoading: Bool = false
    @State private var showCreateNotebook: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                HStack {
                    
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button(action: {
                        lightHaptic()
                        showCreateNotebook = true
                    }) {
                        Text("+ New")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Notebooks")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    if isLoading {
                        ProgressView()
                            .padding(.top, 20)
                    }
                    else if notebooks.isEmpty {
                        Text("No notebooks created yet.")
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                    }
                    else {
                        ForEach(notebooks) { notebook in
                            NavigationLink {
                                NotesListView(notebook: notebook)
                            } label: {
                                HStack(spacing: 12) {
                                    
                                    Image(systemName: "text.book.closed")
                                        .font(.system(size: 22))
                                        .foregroundStyle(colorForNotebook(notebook))
                                    
                                    Text(notebook.title)
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(
                                  TapGesture().onEnded {
                                      lightHaptic()
                                  }
                              )
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .onAppear {
                fetchNotebooks()
            }
            .sheet(isPresented: $showCreateNotebook) {
                CreateNotebookView {
                    fetchNotebooks()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func colorForNotebook(_ notebook: Notebook) -> Color {
        if notebook.color.isEmpty {
            return .blue
        }
        return Color(hex: notebook.color)
    }
    
    private func fetchNotebooks() {
        isLoading = true
        
        RequestManager.shared.sendRequest(
            endpoint: "/notebooks",
            method: "GET",
            responseType: [Notebook].self
        ) { result in
            
            isLoading = false
            
            switch result {
            case .success(let fetched):
                self.notebooks = fetched
            case .failure(let error):
                print("Failed to fetch notebooks:", error)
            }
        }
    }
    
    private func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}

