//
//  ViewExtensions.swift
//  Prema
//
//  Created by Denzel Nyatsanza on 6/11/23.
//

import SwiftUI

enum CustomAlignment {
    case none, trailing, center, leading
}

extension View {
    func shadow() -> some View {
        shadow(color: .shadoww, radius: 10)
    }

    func haptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        
    }
    func showMediaPicker(isPresented: Binding<Bool>, type: MediaConfigType, max: Int = 7, media: @escaping ([Media]) -> ()) -> some View {
        modifier(MediaPickerModifier(isPresented: isPresented, type: type, max: max, media: { mediaa in
            media(mediaa)
        }))
    }
    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
    
    func align(_ position: CustomAlignment) -> some View {
        HStack {
            switch position {
            case .none:
                self
            case .trailing:
                Spacer()
                self
            case .center:
                Spacer()
                self
                Spacer()
            case .leading:
                self
                Spacer()
            }
        }
    }
    
}
