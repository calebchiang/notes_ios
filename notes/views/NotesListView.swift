//
//  NotesListView.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-17.
//

import SwiftUI

struct NotesListView: View {
    
    let notebook: Notebook
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var notes: [Note] = []
    @State private var isLoading: Bool = false
    @State private var showNoteView: Bool = false
    @State private var selectedTab: Tab = .all
    @State private var selectedNote: Note?
    @State private var showExistingNoteView: Bool = false
    @State private var noteToDelete: Note?
    @State private var showDeleteAlert: Bool = false
    
    enum Tab: String, CaseIterable {
        case all = "All Notes"
        case recents = "Recents"
        case favorites = "Favorites"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                
                Button(action: {
                    lightHaptic()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: {
                    lightHaptic()
                    showNoteView = true
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
                
                Text(notebook.title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                                
                HStack(spacing: 20) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        VStack(alignment: .leading, spacing: 6) {
                            
                            Text(tab.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(
                                    selectedTab == tab
                                    ? Color.primary
                                    : Color.secondary
                                )
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(selectedTab == tab ? Color.blue : Color.clear)
                                .frame(height: 4)
                        }
                        .fixedSize()
                        .onTapGesture {
                            lightHaptic()
                            selectedTab = tab
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                if isLoading {
                    ProgressView()
                        .padding(.top, 20)
                }
                else if notes.isEmpty {
                    Text("No notes yet.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                }
                else {
                    List {
                        ForEach(notes) { note in
                            HStack(alignment: .center, spacing: 12) {
                                
                                Image(systemName: "doc.text")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.primary)
                                    .frame(width: 28)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    Text(note.title)
                                        .font(.headline)
                                    
                                    Text(formattedDate(from: note.created_at))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                lightHaptic()
                                selectedNote = note
                                showExistingNoteView = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    lightHaptic()
                                    noteToDelete = note
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            fetchNotes()
        }
        .navigationDestination(isPresented: $showNoteView) {
            NoteView(
                notebook: notebook,
                existingNote: nil,
                autoFocus: true
            )
        }
        .navigationDestination(isPresented: $showExistingNoteView) {
            if let note = selectedNote {
                NoteView(
                    notebook: notebook,
                    existingNote: note,
                    autoFocus: false
                )
            }
        }
        .alert("Delete Note?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    deleteNote(note)
                }
            }
        }
    }
    
    private func fetchNotes() {
        isLoading = true
        
        RequestManager.shared.sendRequest(
            endpoint: "/notebooks/\(notebook.id)/notes",
            method: "GET",
            responseType: [Note].self
        ) { result in
            
            isLoading = false
            
            switch result {
            case .success(let fetched):
                self.notes = fetched
            case .failure(let error):
                print("Failed to fetch notes:", error)
            }
        }
    }
    
    private func deleteNote(_ note: Note) {
        RequestManager.shared.sendRequest(
            endpoint: "/notebooks/\(notebook.id)/notes/\(note.id)",
            method: "DELETE",
            responseType: MessageResponse.self
        ) { result in
            
            switch result {
            case .success:
                notes.removeAll { $0.id == note.id }
            case .failure(let error):
                print("Delete note error:", error)
            }
        }
    }
    
    private func formattedDate(from isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        guard let date = isoFormatter.date(from: isoString) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }

    private func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct MessageResponse: Decodable {
    let message: String
}

