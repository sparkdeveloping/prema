//
//  ProfileView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager

    @StateObject var accountManager = AccountManager.shared
    @StateObject var authManager = AuthManager.shared

    var body: some View {
        if let _ = accountManager.currentProfile {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        if let currentAccount = accountManager.currentAccount {
                            Menu {
                                ForEach(currentAccount.profiles) { profile in
                                    Button(profile.username) {
                                        do {
                                            try Auth.auth().signOut()
                                            if let password = currentAccount.password {
                                                authManager.login(email: currentAccount.email, password: password) {
                                                    withAnimation(.spring()) {
                                                        AccountManager.shared.currentProfile = profile
                                                    }
                                                    appearance.stopLoading()
                                                    DirectManager.shared = .init()
                                                }
                                            }
                                        } catch {}
                                    }
                                }
                            } label: {
                                Text("@" + (accountManager.currentProfile?.username ?? ""))
                                    .bold()
                                    .foregroundStyle(Color.vibrant)
                                    .buttonPadding(20)
                                    .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                                
                            }
                        }
                    }
                    .topPadding(safeAreaInsets.top)
                    .padding()
                    Spacer()
                    
                }
                VStack {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 20) {
                            ProfileImageView(avatars: accountManager.currentProfile!.avatars)
                                .frame(width: appearance.size.width / 4, height: appearance.size.width / 4)
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    Text("full name")
                                        .font(.subheadline.bold())
                                        .roundedFont()
                                        .foregroundStyle(.secondary)
                                    Text(accountManager.currentProfile!.fullName)
                                        .font(.title.bold())
                                        .roundedFont()
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("username")
                                        .font(.subheadline.bold())
                                        .roundedFont()
                                        .foregroundStyle(.secondary)
                                    Text("@" + accountManager.currentProfile!.username)
                                        .font(.title.bold())
                                        .roundedFont()
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("biography")
                                .font(.subheadline.bold())
                                .roundedFont()
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                            Text(accountManager.currentProfile!.bio)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.leading)
                            
                            
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("gender")
                                    .font(.subheadline.bold())
                                    .roundedFont()
                                    .foregroundStyle(.secondary)
                                Text(accountManager.currentProfile!.gender.rawValue)
                                    .fontWeight(.bold)
                                
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("birthday")
                                    .font(.subheadline.bold())
                                    .roundedFont()
                                    .foregroundStyle(.secondary)
                                Text(accountManager.currentProfile!.birthday.fullString())
                                    .fontWeight(.bold)
                                
                            }
                        }
                    }
                    .padding()
                    
                    VStack {
                        
                        VStack {
                            Text("prema score")
                            Text("328")
                                .font(.largeTitle.bold())
                        }
                        .verticalPadding(20)
                        HStack {
                            Color.clear
                            CircularProgressView(progress: 0.5)
                            Color.clear
                            CircularProgressView(progress: 0.2)
                            Color.clear
                        }
                        HStack {
                            Color.clear
                            CircularProgressView(progress: 0.5)
                            Color.clear
                            CircularProgressView(progress: 0.2)
                            Color.clear
                            CircularProgressView(progress: 0.2)
                            Color.clear
                        }
                    }
                    .padding()
                    .padding(.bottom, safeAreaInsets.bottom + 80)

                    .nonVibrantBackground(cornerRadius: 30, colorScheme: colorScheme)
                    
                }
                .padding(.top, Double.blobHeight - safeAreaInsets.top)
            }
            .ignoresSafeArea()
        }
    }
}
extension Double {
    func fullString() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        return dateFormatter.string(from: date)
    }
}

struct CircularProgressView: View {
    let progress: Double
    @StateObject var appearance = AppearanceManager.shared
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.pink.opacity(0.5),
                    lineWidth: 14
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    appearance.currentTheme.vibrantGradient,
                    style: StrokeStyle(
                        lineWidth: 14,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)

        }
    }
}
