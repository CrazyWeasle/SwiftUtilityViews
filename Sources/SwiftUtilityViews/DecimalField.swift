//
//  DecimalField.swift
//  SwiftUtilityViews
//
//  Created by Joe Jarriel on 4/3/26.
//

import SwiftUI
import Combine

#if os(macOS)
import AppKit
#endif

public struct DecimalField: View {
    
    public var promptString: String = ""
    @Binding public var decimalString: String
    @FocusState private var isTextFieldFocused: Bool
    
    public init(promptString: String = "", decimalString: Binding<String>) {
        self.promptString = promptString
        self._decimalString = decimalString
    }
    
    public var body: some View {
        
#if os(iOS)
        VStack {
            TextField(promptString, text: $decimalString)
                .focused($isTextFieldFocused)
                .keyboardType(.decimalPad)
                .decimalNumberOnly($decimalString)
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                    Spacer()
            }
            ToolbarItem(placement: .keyboard) {
                Button {
                    isTextFieldFocused = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        
        
#elseif os(macOS)
        ZStack(alignment: .trailing) {
            TextField(promptString, text: $decimalString)
                .focused($isTextFieldFocused)
                .decimalNumberOnly($decimalString)
            
            if !decimalString.isEmpty {
                Button(action:
                {
                    self.decimalString = ""
                })
                {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(NSColor.systemGray))
                        .padding(.trailing, 8)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
        }
#endif

    }
}

private struct DecimalNumbersOnlyViewModifier: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content
//            .keyboardType(.decimalPad)
            .onReceive(Just(text)) { newValue in
                var numbers = "0123456789"
                let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
                numbers += decimalSeparator
                
                if newValue.components(separatedBy: decimalSeparator).count-1 > 1 {
                    let filtered = newValue
                    self.text = String(filtered.dropLast())
                } else {
                    let filtered = newValue.filter { numbers.contains($0) }
                    if filtered != newValue {
                        self.text = filtered
                    }
                }
            }
    }
}

extension View {
    func decimalNumberOnly(_ text: Binding<String>) -> some View {
        self.modifier(DecimalNumbersOnlyViewModifier(text: text))
    }
}
