//
//  CommentAndShareView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/30/23.
//

import SwiftUI

struct CommentAndShareView: View {
    @Binding var detent: PresentationDetent
    
    @State var selectedIndex: Int = 0
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        TabView {
            ZStack {
                switch detent {
                    case .medium:
                    VStack {
                        Text("Top Comments")
                            .font(.title.bold())
                            .fontDesign(.rounded)
                        ScrollView(.horizontal) {
                            LazyHStack {
                               TopCommentCell()
                                TopCommentCell()
                                TopCommentCell()
                            }
                            // scrollTargetLayout is set to the whole LazyVStack
                            // and applied to each and every view it contains
                            .scrollTargetLayout()
                        }
                        
                        // if behaviour is set to .viewAligned every time scroll happens
                        // it will add offset to center the next child view
                        .scrollTargetBehavior(.viewAligned)
                        
                        .safeAreaPadding(.horizontal, 40)
                        
                    }
                default:
                    Color.clear
                }
            }
            .tag(0)
            
        }
        .tabViewStyle(.page)
    }
}

struct TopCommentCell: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
              
                    HStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .frame(width: 26, height: 26)
                        Text("Username")
                            .bold()
                            .fontDesign(.rounded)
                        Spacer()
                        Text("Follow")
                            .foregroundStyle(.white)
                            .bold()
                            .fontDesign(.rounded)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(Color.orange.gradient)
                            .clipShape(.rect(cornerRadius: 12, style: .continuous))
                    }
                
               
                Spacer()
                
            }
            Text("Wow, God is Good")
                .multilineTextAlignment(.leading)
            Divider()
                .padding(10)
            HStack {
                Text("20 minutes ago")
                    .font(.caption)
                Spacer()
                Image("Heart")
                    .resizable()
                    .frame(width: 20, height: 20)
                Image("Reply")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 30, style: .continuous))
        .shadowX()
        .frame(width: navigationManager.size.width - 40)
    }
}
