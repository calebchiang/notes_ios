import SwiftUI

struct NoteView: View {
    
    let notebook: Notebook
    let existingNote: Note?
    let autoFocus: Bool
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title
        case content
    }
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isLoading: Bool = false
    @State private var currentNote: Note?
    @State private var titleDebounceWorkItem: DispatchWorkItem?
    @State private var contentDebounceWorkItem: DispatchWorkItem?
    
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
                
                HStack(spacing: 8) {
                    
                    Button(action: {
                        lightHaptic()
                    }) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                            )
                    }
                    .buttonStyle(.plain)
                    
                    if focusedField != nil {
                        Button {
                            lightHaptic()
                            focusedField = nil
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    title.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.gray
                                    : Color.blue
                                )
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            )
                        )
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: focusedField != nil)

            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
            
            VStack(alignment: .leading, spacing: 16) {
                
                TextField("Title", text: $title, axis: .vertical)
                    .font(.title.bold())
                    .focused($focusedField, equals: .title)
                    .lineLimit(1...3)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .content
                    }
                    .onChange(of: title) { oldValue, newValue in
                        if newValue.contains("\n") {
                            title = newValue.replacingOccurrences(of: "\n", with: "")
                            focusedField = .content
                        }
                        scheduleTitleAutoSave()
                    }

                TextEditor(text: $content)
                    .font(.body)
                    .frame(minHeight: 200)
                    .focused($focusedField, equals: .content)
                    .onChange(of: content) { _, newValue in
                        scheduleContentAutoSave()
                    }

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            if let existingNote {
                currentNote = existingNote
                title = existingNote.title
                content = existingNote.content ?? ""
            }
            
            if autoFocus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .title
                }
            }
        }
    }
    
    private func scheduleTitleAutoSave() {
        titleDebounceWorkItem?.cancel()
        
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let workItem = DispatchWorkItem {
            if currentNote == nil {
                createNote()
            } else {
                updateTitleIfNeeded()
            }
        }
        
        titleDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
    
    private func scheduleContentAutoSave() {
        contentDebounceWorkItem?.cancel()
        
        guard currentNote != nil else { return }
        
        let workItem = DispatchWorkItem {
            updateContentIfNeeded()
        }
        
        contentDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
    
    private func createNote() {
        isLoading = true
        
        let body: [String: Any] = [
            "title": title,
            "content": content
        ]
        
        RequestManager.shared.sendRequest(
            endpoint: "/notebooks/\(notebook.id)/notes",
            method: "POST",
            body: body,
            responseType: Note.self
        ) { result in
            
            isLoading = false
            
            switch result {
            case .success(let createdNote):
                self.currentNote = createdNote
            case .failure(let error):
                print("Create note error:", error)
            }
        }
    }
    
    private func updateTitleIfNeeded() {
        guard let note = currentNote else { return }
        guard note.title != title else { return }
        updateNote()
    }
    
    private func updateContentIfNeeded() {
        guard let note = currentNote else { return }
        guard note.content != content else { return }
        updateNote()
    }
    
    private func updateNote() {
        guard let note = currentNote else { return }

        isLoading = true
        
        let body: [String: Any] = [
            "title": title,
            "content": content
        ]
        
        RequestManager.shared.sendRequest(
            endpoint: "/notebooks/\(notebook.id)/notes/\(note.id)",
            method: "PATCH",
            body: body,
            responseType: Note.self
        ) { result in
            
            isLoading = false
            
            switch result {
            case .success(let updatedNote):
                self.currentNote = updatedNote
            case .failure(let error):
                print("Update note error:", error)
            }
        }
    }

    private func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

