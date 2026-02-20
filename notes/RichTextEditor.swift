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
        textView.textColor = .label
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        context.coordinator.configureText(on: textView, html: text)
        textView.inputAccessoryView = context.coordinator.createToolbar(for: textView)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if !uiView.isFirstResponder {
            context.coordinator.configureText(on: uiView, html: text)
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
        
        private var boldButton: UIButton?
        private var italicButton: UIButton?
        private var underlineButton: UIButton?
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        // MARK: - Initial Text Setup
        
        func configureText(on textView: UITextView, html: String) {
            if let data = html.data(using: .utf8),
               let attributed = try? NSMutableAttributedString(
                data: data,
                options: [
                    NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                    NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
               ) {
                
                let fullRange = NSRange(location: 0, length: attributed.length)
                
                attributed.enumerateAttribute(.font, in: fullRange) { value, range, _ in
                    let currentFont = value as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
                    let traits = currentFont.fontDescriptor.symbolicTraits
                    let baseDescriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor
                    let descriptor = baseDescriptor.withSymbolicTraits(traits) ?? baseDescriptor
                    let newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                    attributed.addAttribute(.font, value: newFont, range: range)
                }
                
                attributed.removeAttribute(.foregroundColor, range: fullRange)
                attributed.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
                
                textView.attributedText = attributed
            } else {
                textView.attributedText = NSAttributedString(
                    string: html,
                    attributes: [
                        .font: UIFont.preferredFont(forTextStyle: .body),
                        .foregroundColor: UIColor.label
                    ]
                )
            }
        }
        
        // MARK: - Toolbar
        
        func createToolbar(for textView: UITextView) -> UIView {
            self.textView = textView
            
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
            
            let background = UIView()
            background.backgroundColor = .secondarySystemBackground
            background.layer.cornerRadius = 16
            background.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(background)
            
            NSLayoutConstraint.activate([
                background.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                background.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                background.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                background.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
            ])
            
            boldButton = makeButton(title: "B", action: #selector(toggleBold))
            italicButton = makeButton(title: "I", action: #selector(toggleItalic))
            underlineButton = makeButton(title: "U", action: #selector(toggleUnderline))
            
            let stack = UIStackView(arrangedSubviews: [boldButton!, italicButton!, underlineButton!])
            stack.axis = .horizontal
            stack.spacing = 24
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            background.addSubview(stack)
            
            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: background.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: background.centerYAnchor)
            ])
            
            return container
        }
        
        private func makeButton(title: String, action: Selector) -> UIButton {
            let button = UIButton(type: .custom)
            button.layer.cornerRadius = 18
            button.clipsToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            let font: UIFont
            if title == "B" {
                font = UIFont.systemFont(ofSize: 18, weight: .bold)
            } else if title == "I" {
                font = UIFont.italicSystemFont(ofSize: 18)
            } else {
                font = UIFont.systemFont(ofSize: 18)
            }
            
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.label
            ]
            
            if title == "U" {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            
            button.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
            button.addTarget(self, action: action, for: .touchUpInside)
            
            return button
        }
        
        // MARK: - Formatting
        
        @objc private func toggleBold() {
            toggleFontTrait(.traitBold)
        }
        
        @objc private func toggleItalic() {
            toggleFontTrait(.traitItalic)
        }
        
        private func toggleFontTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
            guard let textView else { return }
            
            let range = textView.selectedRange
            
            if range.length > 0 {
                let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
                
                mutable.enumerateAttribute(.font, in: range) { value, subrange, _ in
                    let currentFont = value as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
                    var traits = currentFont.fontDescriptor.symbolicTraits
                    
                    if traits.contains(trait) {
                        traits.remove(trait)
                    } else {
                        traits.insert(trait)
                    }
                    
                    let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) ?? currentFont.fontDescriptor
                    let newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                    mutable.addAttribute(.font, value: newFont, range: subrange)
                }
                
                // 🔥 Preserve scroll position
                let currentOffset = textView.contentOffset
                
                textView.attributedText = mutable
                textView.selectedRange = range
                textView.layoutIfNeeded()
                textView.setContentOffset(currentOffset, animated: false)
                
                parent.text = htmlString(from: mutable)
            } else {
                var attrs = textView.typingAttributes
                let font = attrs[.font] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
                var traits = font.fontDescriptor.symbolicTraits
                
                if traits.contains(trait) {
                    traits.remove(trait)
                } else {
                    traits.insert(trait)
                }
                
                let descriptor = font.fontDescriptor.withSymbolicTraits(traits) ?? font.fontDescriptor
                attrs[.font] = UIFont(descriptor: descriptor, size: font.pointSize)
                textView.typingAttributes = attrs
            }
            
            updateToolbarState()
        }
        
        @objc private func toggleUnderline() {
            guard let textView else { return }
            
            let range = textView.selectedRange
            
            if range.length > 0 {
                let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
                
                mutable.enumerateAttribute(.underlineStyle, in: range) { value, subrange, _ in
                    if value != nil {
                        mutable.removeAttribute(.underlineStyle, range: subrange)
                    } else {
                        mutable.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: subrange)
                    }
                }
                
                // 🔥 Preserve scroll position
                let currentOffset = textView.contentOffset
                
                textView.attributedText = mutable
                textView.selectedRange = range
                textView.layoutIfNeeded()
                textView.setContentOffset(currentOffset, animated: false)
                
                parent.text = htmlString(from: mutable)
            } else {
                var attrs = textView.typingAttributes
                if attrs[.underlineStyle] != nil {
                    attrs.removeValue(forKey: .underlineStyle)
                } else {
                    attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
                }
                textView.typingAttributes = attrs
            }
            
            updateToolbarState()
        }
        
        // MARK: - Highlight State
        
        private func updateToolbarState() {
            guard let textView else { return }
            
            let attrs: [NSAttributedString.Key: Any]
            
            if textView.selectedRange.length > 0 {
                attrs = textView.attributedText.attributes(at: textView.selectedRange.location, effectiveRange: nil)
            } else {
                attrs = textView.typingAttributes
            }
            
            let font = attrs[.font] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
            let traits = font.fontDescriptor.symbolicTraits
            
            updateButton(boldButton, active: traits.contains(.traitBold))
            updateButton(italicButton, active: traits.contains(.traitItalic))
            updateButton(underlineButton, active: attrs[.underlineStyle] != nil)
        }
        
        private func updateButton(_ button: UIButton?, active: Bool) {
            guard let button else { return }
            
            button.setTitleColor(.label, for: .normal)
            button.setTitleColor(.label, for: .highlighted)
            button.tintColor = .label
            
            button.backgroundColor = active
                ? UIColor.systemBlue.withAlphaComponent(0.2)
                : .clear
        }
        
        // MARK: - Delegates
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = htmlString(from: textView.attributedText)
            updateToolbarState()
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            updateToolbarState()
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
            updateToolbarState()
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }
        
        // MARK: - HTML Export
        
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
