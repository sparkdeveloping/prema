//
//  SideMenu.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/16/23.
//

import SwiftUI

struct SideMenu: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
   
    @Namespace var animation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Profile")
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                    HStack {
                        ZStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .background(.secondaryBackground)
                        .cornerRadius(10)
                        .clipShape(.rect(cornerRadius: 16, style: .continuous))
                        VStack {
                            Text("Denzel")
                                .font(.title3.bold())
                                .fontDesign(.rounded)
                            Text("@denzel")
                                .font(.subheadline.bold())
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: getRect().width / 2, alignment: .leading)
                    
                    TabButton(module: .activity, animation: animation)
                    Divider()
                        .frame(maxWidth: getRect().width / 2, alignment: .leading)
                }
                .padding(10)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20, style: .continuous))
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    
                    Text("SuperApp")
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                    TabButton(module: .play, animation: animation)
                    
                    TabButton(module: .direct, animation: animation)
                    
                    TabButton(module: .shopper, animation: animation)
                    TabButton(module: .bite, animation: animation)

                    TabButton(module: .ride, animation: animation)
                    
                }
                .padding(10)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20, style: .continuous))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Account")
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                    HStack {
                        ZStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 14, height: 14)
                                .foregroundStyle(.secondary)
                        }
                        .padding(7)
                        .background(.secondaryBackground)
                        .clipShape(.rect(cornerRadius: 7, style: .continuous))
                        VStack {
                            ScrollView(.horizontal) {
                                Text("DEN**GMAIL.COM")
                                    .bold()
                                    .fontDesign(.rounded)
                            }
                            .scrollIndicators(.hidden)
                          
                        }
                    }
                    .frame(maxWidth: getRect().width / 2, alignment: .leading)
                    TabButton(module: .support, animation: animation)

                    TabButton(module: .logout, animation: animation)
                    
                 
                }
                .padding(10)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20, style: .continuous))
                
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.vertical)
            .padding(.top, navigationManager.safeArea.top)
            .padding(.bottom, navigationManager.safeArea.bottom)
            .padding(.leading, navigationManager.safeArea.leading)
            .padding(.trailing, navigationManager.safeArea.trailing)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
    
}

