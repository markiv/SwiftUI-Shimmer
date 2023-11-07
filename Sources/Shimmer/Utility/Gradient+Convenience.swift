//
//  Gradient+Convenience.swift
//
//
//  Created by Vladyslav Sosiuk on 06.11.2023.
//

import SwiftUI

extension Gradient {
    static var transparent: Self {
        .init(colors: [.black]) // .black has no effect
    }
}
