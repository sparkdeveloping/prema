//
//  ViewExtensions.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/17/23.
//

import SwiftUI

extension View {
    func shadowX(color: Color = Color.shadoww, radius: CGFloat = 15, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        shadow(color: color, radius: radius, x: x, y: y)
    }
}
