//
//  View+iOS13Support.swift
//
//
//  Created by Vladyslav Sosiuk on 06.11.2023.
//

import SwiftUI
import Combine

extension View {
    /// A backwards compatible wrapper for iOS 14 `onChange` based on https://betterprogramming.pub/implementing-swiftui-onchange-support-for-ios13-577f9c086c9
    @ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}
