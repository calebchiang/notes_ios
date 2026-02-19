import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    
    @Binding var isFocused: Bool
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textColor = UIColor.label
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        if let data = text.data(using: .utf8),
           let attributed = try? NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
           ) {
            
            let fullRange = NSRange(location: 0, length: attributed.length)
            
            attributed.enumerateAttribute(.font, in: fullRange) { value, range, _ in
                let currentFont = value as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
                
                let traits = currentFont.fontDescriptor.symbolicTraits
                
                let newDescriptor = UIFont.preferredFont(forTextStyle: .body)
                    .fontDescriptor
                    .withSymbolicTraits(traits) ?? UIFont.preferredFont(forTextStyle: .body).fontDescriptor
                
                let newFont = UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
                
                attributed.addAttribute(.font, value: newFont, range: range)
            }
            
            textView.attributedText = attributed
        }
        else {
            textView.attributedText = NSAttributedString(
                string: text,
                attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .body),
                    .foregroundColor: UIColor.label
                ]
            )
        }
        
        textView.inputAccessoryView = context.coordinator.createToolbar(for: textView)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if !uiView.isFirstResponder {
            if let data = text.data(using: .utf8),
               let attributed = try? NSMutableAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
               ) {
                
                let fullRange = NSRange(location: 0, length: attributed.length)
                
                attributed.enumerateAttribute(.font, in: fullRange) { value, range, _ in
                    let currentFont = value as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
                    
                    let traits = currentFont.fontDescriptor.symbolicTraits
                    
                    let baseDescriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor
                    let newDescriptor = baseDescriptor.withSymbolicTraits(traits) ?? baseDescriptor
                    
                    let newFont = UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
                    
                    attributed.addAttribute(.font, value: newFont, range: range)
                }
                
                uiView.attributedText = attributed
            }
        }
        
        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
        
        if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var parent: RichTextEditor
        weak var textView: UITextView?
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
                
        func createToolbar(for textView: UITextView) -> UIView {
            self.textView = textView

            let container = UIView()
            container.backgroundColor = .clear
            container.frame = CGRect(x: 0, y: 0, width: 0, height: 60)

            let toolbarBackground = UIView()
            toolbarBackground.backgroundColor = UIColor.secondarySystemBackground
            toolbarBackground.layer.cornerRadius = 16
            toolbarBackground.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(toolbarBackground)
            
            NSLayoutConstraint.activate([
                toolbarBackground.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                toolbarBackground.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                toolbarBackground.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                toolbarBackground.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
            ])
            
            let boldButton = makeButton(title: "B", action: #selector(toggleBold(_:)))
            let italicButton = makeButton(title: "I", action: #selector(toggleItalic(_:)))
            let underlineButton = makeButton(title: "U", action: #selector(toggleUnderline(_:)))
            
            let stack = UIStackView(arrangedSubviews: [boldButton, italicButton, underlineButton])
            stack.axis = .horizontal
            stack.spacing = 24
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            toolbarBackground.addSubview(stack)
            
            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: toolbarBackground.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: toolbarBackground.centerYAnchor)
            ])
            
            return container
        }
        
        private func makeButton(title: String, action: Selector) -> UIButton {
            let button = UIButton(type: .system)
            button.tintColor = .label
            button.setTitleColor(.label, for: .normal)
            
            let baseFontSize: CGFloat = 18
            
            switch title {
            case "B":
                button.setAttributedTitle(
                    NSAttributedString(
                        string: "B",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: baseFontSize, weight: .bold),
                            .foregroundColor: UIColor.label
                        ]
                    ),
                    for: .normal
                )
                
            case "I":
                button.setAttributedTitle(
                    NSAttributedString(
                        string: "I",
                        attributes: [
                            .font: UIFont.italicSystemFont(ofSize: baseFontSize),
                            .foregroundColor: UIColor.label
                        ]
                    ),
                    for: .normal
                )
                
            case "U":
                button.setAttributedTitle(
                    NSAttributedString(
                        string: "U",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: baseFontSize, weight: .regular),
                            .foregroundColor: UIColor.label,
                            .underlineStyle: NSUnderlineStyle.single.rawValue
                        ]
                    ),
                    for: .normal
                )
                
            default:
                button.setTitle(title, for: .normal)
            }
            
            button.addTarget(self, action: action, for: .touchUpInside)
            
            return button
        }

        @objc func toggleBold(_ sender: UIButton) {
            applyStyle { currentFont in
                var traits = currentFont.fontDescriptor.symbolicTraits
                if traits.contains(.traitBold) {
                    traits.remove(.traitBold)
                } else {
                    traits.insert(.traitBold)
                }
                guard let newDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) else {
                    return currentFont
                }
                return UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
            }
        }

        @objc func toggleItalic(_ sender: UIButton) {
            applyStyle { currentFont in
                var traits = currentFont.fontDescriptor.symbolicTraits
                if traits.contains(.traitItalic) {
                    traits.remove(.traitItalic)
                } else {
                    traits.insert(.traitItalic)
                }
                guard let newDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) else {
                    return currentFont
                }
                return UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
            }
        }

        @objc func toggleUnderline(_ sender: UIButton) {
            guard let textView = textView else { return }
            let range = textView.selectedRange
            guard range.length > 0 else { return }
            
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            
            mutable.enumerateAttribute(.underlineStyle, in: range, options: []) { value, subrange, _ in
                if value != nil {
                    mutable.removeAttribute(.underlineStyle, range: subrange)
                } else {
                    mutable.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: subrange)
                }
            }
            
            textView.attributedText = mutable
            textView.selectedRange = range
            parent.text = htmlString(from: textView.attributedText)
        }
        
        private func applyStyle(transform: (UIFont) -> UIFont) {
            guard let textView = textView else { return }
            let range = textView.selectedRange
            guard range.length > 0 else { return }
            
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            
            mutable.enumerateAttribute(.font, in: range, options: []) { value, subrange, _ in
                let currentFont = value as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
                let newFont = transform(currentFont)
                mutable.addAttribute(.font, value: newFont, range: subrange)
            }
            
            textView.attributedText = mutable
            textView.selectedRange = range
            parent.text = htmlString(from: textView.attributedText)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = htmlString(from: textView.attributedText)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isFocused = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isFocused = false
            }
        }
        
        private func htmlString(from attributedString: NSAttributedString) -> String {
            let range = NSRange(location: 0, length: attributedString.length)
            let options: [NSAttributedString.DocumentAttributeKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html
            ]
            
            guard let data = try? attributedString.data(from: range, documentAttributes: options),
                  let html = String(data: data, encoding: .utf8) else {
                return attributedString.string
            }
            
            return html
        }
    }
}

