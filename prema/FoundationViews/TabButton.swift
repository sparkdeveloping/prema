//
//  TabButton.swift
//  Custom_Side_Menu (iOS)
//
//  Created by Balaji on 03/04/21.
//

import SwiftUI

struct TabButton: View {
    var module: Module
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    var animation: Namespace.ID
    
    var body: some View {
        
        Button(action: {
            withAnimation(.spring()) {
                navigationManager.selectedModule = module
                navigationManager.showModules = false
            }
        }, label: {
            
            HStack(spacing : 15){
                
                Image(module.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    
                Text(module.rawValue)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
            }
            .foregroundColor(navigationManager.selectedModule == module ? Color.white : .primary)
            .padding(.vertical,12)
            .padding(.horizontal,10)
            // Max Frame..
            .frame(maxWidth: getRect().width / 2, alignment: .leading)
            .background(
            
                // hero Animation...
                ZStack{
                    
                    if navigationManager.selectedModule == module{
                        Rectangle()
                            .fill(.orange.gradient)
                            .opacity(navigationManager.selectedModule == module ? 1 : 0)
                            .clipShape(.rect(cornerRadii: .init(topLeading: 12, bottomLeading: 5, bottomTrailing: 12, topTrailing: 5), style: .continuous))
      
                        
                            .shadowX()
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
            )
        })
    }
}
