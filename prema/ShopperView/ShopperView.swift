//
//  ShopperView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/17/23.
//

import SwiftUI

struct ShopperView: View {
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                let strings: [String] = ["1", "2", "3", "4", "5"]
                HStack(spacing: 16) {
                    ForEach(strings, id: \.self) { string in
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.black.gradient)
                            
                            Text(string)
                                .font(.system(size: 92))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                        }
                        .frame(width: 300, height: 300 * 9 / 16)
                        .containerRelativeFrame(.vertical)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            Spacer()
        }
    }
}
