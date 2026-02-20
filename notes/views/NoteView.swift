import SwiftUI

struct NoteView: View {
    
    let notebook: Notebook
    let existingNote: Note?
    let autoFocus: Bool
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    @State private var isContentFocused: Bool = false
    @State private var showAiSheet: Bool = false
    @State private var showAiChat = false
    
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
            
            // MARK: Top Bar
            HStack {
                
                Button(action: {
                    lightHaptic()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                HStack(spacing: 12) {
                    
                    // AI Button
                    Button(action: {
                        lightHaptic()
                        showAiSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Text("AI")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.secondary.opacity(0.15))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Blue Check
                    if focusedField != nil || isContentFocused {
                        Button {
                            lightHaptic()
                            
                            if focusedField == .title {
                                focusedField = nil
                            }
                            
                            if isContentFocused {
                                isContentFocused = false
                            }
                            
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
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
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.8),
                    value: focusedField != nil || isContentFocused
                )
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
            
            
            // MARK: Content
            
            VStack(alignment: .leading, spacing: 16) {
                
                TextField("Title", text: $title, axis: .vertical)
                    .font(.title.bold())
                    .focused($focusedField, equals: .title)
                    .lineLimit(1...3)
                    .onChange(of: title) { oldValue, newValue in
                        
                        if newValue.contains("\n") {
                            title = newValue.replacingOccurrences(of: "\n", with: "")
                            focusedField = nil
                            
                            DispatchQueue.main.async {
                                isContentFocused = true
                            }
                            return
                        }
                        
                        scheduleTitleAutoSave()
                    }
                
                RichTextEditor(
                    isFocused: $isContentFocused,
                    text: $content
                )
                .font(.body)
                .frame(minHeight: 200)
                .onChange(of: content) { _, _ in
                    scheduleContentAutoSave()
                }
                
                Spacer()
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                Button {
                    lightHaptic()
                    showAiChat = true
                } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            }
        }
        .fullScreenCover(isPresented: $showAiSheet) {
            AiFeaturesView()
        }
        .fullScreenCover(isPresented: $showAiChat) {
            AiChatView()
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
    
    
    // MARK: Auto Save
    
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
    
    
    // MARK: Network
    
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
