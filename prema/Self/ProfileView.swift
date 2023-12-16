//
//  ProfileView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import FirebaseAuth
import SwiftUI



struct Statement: Identifiable, Codable {
    var id: String
    var message: String
    var timestamp: Timestamp
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = self.id
        dict["message"] = self.message
        dict["timestamp"] = self.timestamp.dictionary
        return dict
    }
}

extension [String: Any] {
    func parseStatement(_ id: String? = nil) -> Statement {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        
        let message = self["message"] as? String ?? ""
        var timestamp = (self["timestamp"] as? [String: Any] ?? [:]).parseTimestamp()
        
        return .init(id: _id, message: message, timestamp: timestamp)
    }
}

struct Progress: Identifiable, Codable {
    var id: String
    var percentageDecimal: Double
    var timestamp: Timestamp
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = self.id
        dict["percentageDecimal"] = self.percentageDecimal
        dict["timestamp"] = self.timestamp.dictionary
        return dict
    }
}

extension [String: Any] {
    func parseProgress(_ id: String? = nil) -> Progress {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        
        let percentageDecimal = self["percentageDecimal"] as? Double ?? 0
        var timestamp = (self["timestamp"] as? [String: Any] ?? [:]).parseTimestamp()
        
        return .init(id: _id, percentageDecimal: percentageDecimal, timestamp: timestamp)
    }
}

struct Performance: Identifiable, Codable {
    var id: String
    var name: String
    var progress: [Progress]
    var statements: [Statement]
    var opens: [Timestamp]
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = self.id
        dict["name"] = self.name
        dict["statements"] = self.statements.map {$0.dictionary}
        dict["opens"] = self.opens.map {$0.dictionary}
        return dict
    }
}

extension [String: Any] {
    func parsePerformance(_ id: String? = nil) -> Performance {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        let name = self["name"] as? String ?? ""

        let progress = (self["progress"] as? [[String: Any]] ?? []).map {$0.parseProgress()}
        let statements = (self["statements"] as? [[String: Any]] ?? []).map {$0.parseStatement()}
        let opens = (self["opens"] as? [[String: Any]] ?? []).map {$0.parseTimestamp()}
        
        return .init(id: _id, name: name, progress: progress, statements: statements, opens: opens)
    }
}


struct ProfileView: View {
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager
    @State var selection = "portfolio"
    var profile: Profile?
    
    @StateObject var accountManager = AccountManager.shared
    @StateObject var authManager = AuthManager.shared
    
    var current: Profile? {
        return profile != nil ? profile: AccountManager.shared.currentProfile
    }

    var body: some View {
        if let current {
      
            ZStack {
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 20) {
                                
                                VStack(alignment: .leading) {
                                    VStack(alignment: .leading) {
                                        Text("full name")
                                            .font(.subheadline.bold())
                                            .roundedFont()
                                            .foregroundStyle(.secondary)
                                        Text(current.fullName)
                                            .font(.title.bold())
                                            .roundedFont()
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("username")
                                            .font(.subheadline.bold())
                                            .roundedFont()
                                            .foregroundStyle(.secondary)
                                        Text("@" + current.username)
                                            .font(.title.bold())
                                            .roundedFont()
                                    }
                                    
                                }
                                Spacer()
                                ProfileImageView(avatars: current.avatars)
                                    .frame(width: appearance.size.width / 4, height: appearance.size.width / 4)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("biography")
                                    .font(.subheadline.bold())
                                    .roundedFont()
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                                Text(current.bio.isEmpty ? "No bio":current.bio)
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
                                    Text(current.gender.rawValue)
                                        .fontWeight(.bold)
                                    
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("birthday")
                                        .font(.subheadline.bold())
                                        .roundedFont()
                                        .foregroundStyle(.secondary)
                                    Text(current.birthday.fullString())
                                        .fontWeight(.bold)
                                    
                                }
                            }
                        }
                        .padding()
                        
                        VStack {
                            HStack(alignment: .top) {
                                CustomSelectorView(selection: $selection, strings: ["portfolio", "posts"])
                                    .padding(-10)
                                
                                VStack(alignment: .leading) {
                                    Text("prema score")
                                        .font(.caption.bold())
                                    Text("328")
                                        .font(.largeTitle.bold())
                                }
                            }
                            Divider()
                                .padding(10)
                            
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(current.performances) { item in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Spacer()
                                            CircularProgressView(progress: item.progress.first?.percentageDecimal ?? 0)
                                                .frame(width: 60, height: 60)
                                                .padding(10)
                                            Spacer()
                                        }
                                        .verticalPadding(20)
                                        HStack {
                                            Image(item.name)
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            Text(item.name)
                                                .font(.subheadline.bold())
                                            Spacer()
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .nonVibrantBlurBackground(cornerRadius: 24, colorScheme: colorScheme)
                                }
                            }
                        }
                        
                        .padding()
                        .padding(.bottom, safeAreaInsets.bottom + 80)
                        
                        .nonVibrantBackground(cornerRadius: 30, colorScheme: colorScheme)
                        
                    }
                    .padding(.top, (Double.blobHeight - safeAreaInsets.top) - (profile == nil ? 0:safeAreaInsets.top))
                }
                .scrollIndicators(.hidden)
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
                    .topPadding(profile == nil ? safeAreaInsets.top:0)
                    .padding()
                    Spacer()
                    
                }
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
        GeometryReader {
            let size = $0.size
            ZStack {
                Circle()
                    .stroke(
                        Color.pink.opacity(0.5),
                        lineWidth: size.width / 7
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        appearance.currentTheme.vibrantGradient,
                        style: StrokeStyle(
                            lineWidth: size.width / 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                // 1
                    .animation(.easeOut, value: progress)
                
            }
        }
    }
}
