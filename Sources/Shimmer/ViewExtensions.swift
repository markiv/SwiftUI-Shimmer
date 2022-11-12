//
//  ViewExtensions.swift
//
//  Created by Ethan Pippin on 11/10/22.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func inverseMask<M: View>(_ mask: M) -> some View {
        let inversed = mask
            .foregroundColor(.black)
            .background(Color.white)
            .compositingGroup()
            .luminanceToAlpha()
        
        self.mask(inversed)
    }
    
    @ViewBuilder
    func mask<M: View>(_ mask: M, inverse: Bool) -> some View {
        if inverse {
            self.inverseMask(mask)
        } else {
            self.mask(mask)
        }
    }
}
