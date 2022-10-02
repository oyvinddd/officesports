//
//  CodeInputView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 30/09/2022.
//

import UIKit

final class CodeInputView: UIView, CodeInputFieldDelegate {
    
    var text: String {
        return "text"
    }
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal, spacing: 6)
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(stackView)
        
        stackView.addArrangedSubviews(
            CodeInputField(index: 0, self),
            CodeInputField(index: 1, self),
            CodeInputField(index: 2, self),
            CodeInputField(index: 3, self),
            CodeInputField(index: 4, self),
            CodeInputField(index: 5, self)
        )
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func selectNextInputField(_ index: Int) {
        let noOfFields = stackView.subviews.count
        let nextIndex = index == noOfFields - 1 ? 0 : index + 1
        for view in stackView.subviews {
            let field = view as? CodeInputField
            field?.toggle(active: false)
        }
        let nextField = stackView.subviews[nextIndex] as? CodeInputField
        nextField?.toggle(active: true)
        _ = nextField?.becomeFirstResponder()
    }
    
    // MARK: - Code Input Field Delegate Conformance
    
    func characterTyped(_ index: Int) {
        selectNextInputField(index)
    }
    
    func backspaceTapped(_ index: Int) {
        
    }
}

// MARK: - Code Input Field

protocol CodeInputFieldDelegate: AnyObject {
    
    func characterTyped(_ index: Int)
    
    func backspaceTapped(_ index: Int)
}

private final class CodeInputField: UITextField, UITextFieldDelegate {
    
    private let index: Int
    
    weak var codeDelegate: CodeInputFieldDelegate?
    
    init(index: Int, _ codeDelegate: CodeInputFieldDelegate?) {
        self.index = index
        self.codeDelegate = codeDelegate
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 26, weight: .bold)
        backgroundColor = UIColor.OS.General.separator
        textColor = UIColor.OS.Text.normal
        textAlignment = .center
        isSecureTextEntry = true
        layer.cornerRadius = 8
        layer.borderColor = UIColor.OS.General.separator.cgColor
        layer.masksToBounds = true
        layer.borderWidth = 1.8
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func deleteBackward() {
        if let text = text, text.isEmpty {
            codeDelegate?.backspaceTapped(index)
        }
        super.deleteBackward()
    }
    
    override public func becomeFirstResponder() -> Bool {
        toggle(active: true)
        return super.becomeFirstResponder()
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
    
    // MARK: - Text Field Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            codeDelegate?.characterTyped(index)
        }
        return true
    }
}
