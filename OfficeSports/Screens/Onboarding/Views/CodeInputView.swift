//
//  CodeInputView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 30/09/2022.
//

import UIKit

private let maxCharacters: Int = 6

protocol CodeInputDelegate: AnyObject {
    func didType(input: String, finished: Bool)
}

final class CodeInputView: UIView {
    
    private weak var delegate: CodeInputDelegate?
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal, spacing: 6)
    }()
    
    private var currentActiveIndex: Int {
        return text.count
    }
    
    private var inputFields: [CodeInputField]? {
        return stackView.subviews as? [CodeInputField]
    }
    
    var text: String {
        guard let inputFields = inputFields else {
            return ""
        }
        return inputFields.reduce("") { $0 + $1.text! }
    }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        guard let firstField = inputFields?.first else {
            return true
        }
        return firstField.becomeFirstResponder()
    }
    
    private func setupChildViews() {
        addSubview(stackView)
        
        stackView.addArrangedSubviews(
            CodeInputField(index: 0, delegate: self),
            CodeInputField(index: 1, delegate: self),
            CodeInputField(index: 2, delegate: self),
            CodeInputField(index: 3, delegate: self),
            CodeInputField(index: 4, delegate: self),
            CodeInputField(index: 5, delegate: self)
        )
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension CodeInputView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /*
        guard isValidInput(string) else {
            return false
        }
        */
        guard let inputField = textField as? CodeInputField else {
            return false
        }
        inputField.text = string
        let currentIndex = inputField.index
        
        if !string.isEmpty {
            _ = cycleInputFields(index: currentIndex + 1)
        }
        delegate?.didType(input: text, finished: text.count == maxCharacters)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as? CodeInputField)?.toggle(active: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? CodeInputField)?.toggle(active: false)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let inputField = textField as? CodeInputField else {
            return false
        }
        return inputField.index <= currentActiveIndex
    }
    
    private func isValidInput(_ input: String?) -> Bool {
        guard let input = input else {
            return false
        }
        let alphanumerics = CharacterSet.alphanumerics
        return CharacterSet(charactersIn: input).isSubset(of: alphanumerics)
    }
    
    private func cycleInputFields(index: Int) -> Bool {
        guard let inputFields = inputFields else {
            return false
        }
        if index > -1 && index < inputFields.count {
            _ = inputFields[index].becomeFirstResponder()
            return true
        }
        endEditing(true)
        return false
    }
}

// MARK: - Code Input Field

private final class CodeInputField: UITextField, UITextFieldDelegate {
    
    let index: Int
    
    init(index: Int, delegate: UITextFieldDelegate?) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 28, weight: .bold)
        backgroundColor = UIColor.OS.General.separator
        textColor = UIColor.OS.Text.disabled
        textAlignment = .center
        isSecureTextEntry = true
        autocapitalizationType = .none
        textContentType = .none
        autocorrectionType = .no
        layer.cornerRadius = 8
        layer.borderColor = UIColor.OS.General.separator.cgColor
        layer.masksToBounds = true
        layer.borderWidth = 1.8
        self.delegate = delegate
        inputAccessoryView = nil
        textContentType = .oneTimeCode
        inputAccessoryView?.isHidden = true
        returnKeyType = .done
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func deleteBackward() {
        if let text = text, text.isEmpty {
            //codeDelegate?.backspaceTapped(index)
        }
        super.deleteBackward()
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    func toggle(active: Bool) {
        if active {
            layer.borderColor = UIColor.OS.General.main.cgColor
        } else {
            layer.borderColor = UIColor.OS.General.separator.cgColor
        }
    }
}
