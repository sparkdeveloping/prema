//
//  AuthView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/3/23.
//

import Firebase
import SwiftUI
import ExyteMediaPicker
import SDWebImageSwiftUI

enum ProfileType: String, Codable, Hashable {
    case none = "Select Profile Type", personal = "Personal", business = "Business", organization = "Organization"
    static var allCases: [Self] = [.none, .personal, .business, .organization]
}

struct AuthView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager
    @StateObject var accountsManager = AccountManager.shared

    @State var createProfile: Bool = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State var appeared = false
    @State var showAuth = false
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        showAuth = true
                    }
                } label: {
                    Text("create an account")
                        .font(.title3.bold())
                        .foregroundStyle(Color.white)
                        .roundedFont()
                        .verticalPadding(5)
                        .buttonPadding()
                        .frame(maxWidth: .infinity)
                        .vibrantBackground(cornerRadius: 15, colorScheme: colorScheme)
                        .horizontalPadding(40)
                }
                Button {
                    withAnimation(.spring()) {
                        showAuth = true
                    }
                } label: {
                    Text("login")
                        .font(.title3.bold())
                        .foregroundStyle(Color.vibrant)
                        .roundedFont()
                        .verticalPadding(5)
                        .buttonPadding()
                        .frame(maxWidth: .infinity)
                        .nonVibrantBackground(cornerRadius: 15, colorScheme: colorScheme)
                        .horizontalPadding(40)
                }
            }
            .bottomPadding(safeAreaInsets.bottom + 40)
            .offset(y: (appeared && !showAuth && !createProfile) ? 0:300)
            .onAppear {
                withAnimation(.spring()) {
                    appeared = true
                }
            }
            AuthFormView(showAuth: $showAuth)
                .offset(y: showAuth ? 0:appearance.size.height)
                .onChange(of: showAuth) { _, value in
                    withAnimation(.spring()) {
                        appearance.shrinkBlob = value
                    }
                }
            AccountsView(createProfile: $createProfile)
                .offset(y: (!accountsManager.accounts.isEmpty && !showAuth) ? 0:appearance.size.height)

        }
    }
}

enum AuthState {
    case none, login, create
}

struct AccountsView: View {
    @StateObject var accountsManager = AccountManager.shared
    @StateObject var authManager = AuthManager.shared

    @EnvironmentObject var appearance: AppearanceManager
    @Environment(\.colorScheme) var colorScheme
    @State var selectedAccountIndex: Int = 0
   var selectedAccount: Account {
        return accountsManager.accounts[selectedAccountIndex]
    }
    
    @Binding var createProfile: Bool
    
    @State var fullName = ""
    @State var username = ""
    @State var bio = ""
    @State var gender: Gender = .none
    @State var type: ProfileType = .none
    @State var birthday: Date = .now

    @State var media: [prema.Media] = []
    
    @State var showPicker = false
    
    var body: some View {
      
            VStack {
                if appearance.isLoading {
                    SpinnerView()
                        .frame(width: 80, height: 80)
                } else {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text(createProfile ? "Create Profile":"Available Accounts")
                                .font(.title.bold())
                                .roundedFont()
                            Spacer()
                            if createProfile {
                                DismissButton() {
                                    withAnimation(.spring()) {
                                        createProfile = false
                                    }
                                }
                            }
                        }
                        Text("Profiles are like all the different exciting versions of you, an account can have multiple of those :)")
                            .foregroundStyle(.secondary)
                        
                    }
                    if createProfile {
                        createProfileView
                    } else {
                        accountsView
                    }
                }
            }
            .padding()
            .nonVibrantBackground(cornerRadius: 30, colorScheme: colorScheme)
            .padding()
        
    }
    var accountsView: some View {
  
        VStack {
            
            ForEach(accountsManager.accounts.indices, id: \.self) { index in
                let account = accountsManager.accounts[index]
                VStack(alignment: .leading, spacing: 15) {
                    
                    HStack {
                        Text(account.email.censorEmail())
                            .font(.title3.bold())
                        Spacer()
                        if accountsManager.currentAccount == account {
                            Button {
                                do {
                                    try Auth.auth().signOut()
                                } catch {}
                            } label: {
                                Text("logout")
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                    .buttonPadding(5)
                                    .background(Color.red)
                                    .clipShape(.rect(cornerRadius: 12, style: .continuous))
                            }
                        }
                        Button {
                            if accountsManager.currentAccount == account {
                                do {
                                    try Auth.auth().signOut()
                                } catch {}
                            }
                            withAnimation(.spring()) {
                                let indexx = index
                                self.accountsManager.accounts.remove(at: indexx)
                            }
                        } label: {
                            Image(systemName: "trash.fill")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .buttonPadding(5)
                                .background(Color.red)
                                .clipShape(.rect(cornerRadius: 12, style: .continuous))
                        }
                        
                    }
                    .padding(10)
                    .nonVibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedAccountIndex = index
                        }
                    }
                    
                    ForEach(account.profiles) { profile in
                        VStack {
                            HStack {
                                ProfileImageView(avatars: profile.avatars)
                                    .frame(width: 40, height: 40)
                                VStack(alignment: .leading) {
                                    Text(profile.fullName)
                                    Text("@" + profile.username.lowercased())
                                        .font(.subheadline)
                                }
                              
                                Spacer()
                                Button {
                                    do {
                                        try Auth.auth().signOut()
                                        if let password = account.password {
                                            authManager.login(email: account.email, password: password) {
                                                withAnimation(.spring()) {
                                                    AccountManager.shared.currentProfile = profile
                                                }
                                                AppearanceManager.shared.stopLoading()
                                            }
                                        } else {
                                            if accountsManager.currentAccount == account {
                                                do {
                                                    try Auth.auth().signOut()
                                                } catch {}
                                            }
                                            withAnimation(.spring()) {
                                                let indexx = index
                                                self.accountsManager.accounts.remove(at: indexx)
                                            }
                                        }
                                    } catch {}
                                } label: {
                                    Text("switch")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .buttonPadding(5)
                                        .background(Color.vibrant)
                                        .clipShape(.rect(cornerRadius: 12, style: .continuous))
                                }
                            }
                            Divider()
                        }
                    }
                    
                    if selectedAccountIndex == index {
                        Button {
                            withAnimation(.spring()) {
                                createProfile = true
                            }
                        } label: {
                            Text("Create a Profile")
                                .bold()
                                .foregroundStyle(.white)
                                .verticalPadding(5)
                                .buttonPadding()
                                .frame(maxWidth: .infinity)
                                .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                        }
                    }
                }
                .background {
                    if index == selectedAccountIndex {
                        Color.clear.nonVibrantSecondaryBackground(cornerRadius: 14, colorScheme: colorScheme)
                    }
                }
            }
        }
        
    }
    
    var createProfileView: some View {
        VStack(alignment: .leading) {
           
                ZStack {
                    if media.isEmpty {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .foregroundStyle(Color.vibrant)
                    } else {
                        TabView {
                            ForEach(media) { item in
                                if let uiImage = item.uiImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(width: 100, height: 100)
                    }
                }
                .frame(width: 100, height: 100)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPicker = true
                    }
                }
                .sheet(isPresented: $showPicker) {
                    MediaPicker(
                        isPresented: $showPicker,
                        onChange: { items in
                            
                            items.forEach { item in
                                var mediaa: Media?
                                SwiftUI.Task {
                                    await mediaa = Media(videoURLString: item.getURL()?.absoluteString)
                                    if let mediaa {
                                        media.append(mediaa)
                                    }
                                }
                            }
                            
                        }
                    )
                }
            
            .frame(width: 100, height: 100)

            .nonVibrantSecondaryBackground(cornerRadius: 40, colorScheme: colorScheme)

            CustomTextField(text: $fullName, imageName: "FullName", placeHolder: "Full Name")
            Divider()
            CustomTextField(text: $username, imageName: "Username", placeHolder: "username")
                            Divider()
                            
            HStack {
                Image("Visionary")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                Menu {
                    ForEach(ProfileType.allCases, id: \.self) { type in
                        Button(type.rawValue) {
                            self.type = type
                        }
                    }
                } label: {
                    HStack {
                        Text(self.type.rawValue)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                        .contentShape(.rect)
                }
            }
            
            Divider()
            HStack {
                Image("Gender")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                Menu {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Button(gender.rawValue) {
                            self.gender = gender
                        }
                    }
                } label: {
                    HStack {
                        Text(self.gender.rawValue)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                        .contentShape(.rect)
                }
            }
            Divider()
            HStack {
                Image("Date")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                DatePicker("birthday", selection: $birthday, in: ...Date(), displayedComponents: .date)
            }
            Button {
                withAnimation(.spring()) {
                    authManager.createProfile(accountID: selectedAccount.id, fullName: fullName, username: username, bio: bio, gender: gender, birthday: birthday, avatars: media, type: type)
                }
            } label: {
                Text("create profile")
                    .font(.title3.bold())
                    .foregroundStyle(Color.white)
                    .roundedFont()
                    .verticalPadding(5)
                    .buttonPadding()
                    .frame(maxWidth: .infinity)
                    .vibrantBackground(cornerRadius: 15, colorScheme: colorScheme)
            }
        }
    }
    
}

struct AuthFormView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showAuth: Bool
    @EnvironmentObject var appearance: AppearanceManager
    @StateObject var authManager: AuthManager = .shared
    var buttonEnabled: Bool {
        return (!authManager.email.isEmpty && !authManager.password.isEmpty)
    }
    var body: some View {
        ZStack {
            if appearance.isLoading {
                SpinnerView()
                    .frame(width: 80, height: 80)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("Welcome")
                                .font(.largeTitle.bold())
                                .roundedFont()
                            Text("We will make this quick!")
                                .font(.caption)
                        }
                        Spacer()
                        DismissButton() {
                            withAnimation(.spring()) {
                                showAuth = false
                            }
                        }
                    }
                    VStack {
                        CustomTextField(text: $authManager.email, imageName: "Email", placeHolder: "Email Address")
                        Divider()
                            .padding(10)
                        CustomTextField(text: $authManager.password, imageName: "Password", placeHolder: "Password")
                    }
                    Link(destination: URL(string: "https://apple.com")!) {
                        
                        Text("By proceeding, you agree to the terms and conditions of the EULA")
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.vibrantSecondary)
                        
                    }
                    if !buttonEnabled {
                        Button {} label: {
                            Text("proceed")
                                .font(.title3.bold())
                                .foregroundStyle(.gray)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .nonVibrantSecondaryBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                        .allowsHitTesting(false)
                    } else {
                        Button {
                            if !AccountManager.shared.accounts.isEmpty {
                                do {
                                    try Auth.auth().signOut()
                                    authManager.checkIfAccountExists()
                                } catch {}
                            } else {
                                authManager.checkIfAccountExists()
                            }
                        } label: {
                            Text("proceed")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .vibrantBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                    }
                }
            }
              
        }
        .padding()
        .nonVibrantBackground(cornerRadius: 30, colorScheme: colorScheme)
        .padding()
        .padding(.vertical, 10)
        .onChange(of: AccountManager.shared.accounts) { _, v in
            if !v.isEmpty {
                showAuth = false
            }
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    var imageName: String
    var placeHolder: String
    @Environment(\.colorScheme) var colorScheme

    @State var showPassword = false
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 20, height: 20)
                .padding(8)
                .foregroundStyle(.secondary)
                .nonVibrantSecondaryBackground(cornerRadius: 10, colorScheme: colorScheme)
            if !showPassword {
                TextField(placeHolder, text: $text)
            } else {
                SecureField(placeHolder, text: $text)
            }
        }
        .overlay(alignment: .trailing) {
            if placeHolder == "Password" {
                Image(systemName: showPassword ? "eye.slash.fill":"eye.fill")
                    .font(.title3)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showPassword.toggle()
                        }
                    }
                    .padding(.horizontal)
            }
        }
    }
}

struct DismissButton: View {
    
    var action:() -> ()
    var color: Color = .red
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .font(.title2.bold())
                .foregroundStyle(color)
                .padding(10)
                .nonVibrantBackground(cornerRadius: 12, colorScheme: colorScheme)
        }
    }
}


extension Text {
    func roundedFont() -> Text {
        fontDesign(.rounded)
    }
}

extension View {
    func nonVibrantBackground(cornerRadius: Double, colorScheme: ColorScheme) -> some View {
        return background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(colorScheme == .light ? AppearanceManager.shared.currentTheme .nonVibrantGradient:AppearanceManager.shared.currentTheme .nonVibrantSecondaryGradientDark)            .shadow(color: Color("Shadoww"), radius: 40, x: 4, y: 10))

        
    }
    func nonVibrantSecondaryBackground(cornerRadius: Double, colorScheme: ColorScheme) -> some View {
        return background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(colorScheme == .light ? AppearanceManager.shared.currentTheme .nonVibrantSecondaryGradient:AppearanceManager.shared.currentTheme .nonVibrantSecondaryGradientDark)
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .clipped()
            .contentShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color("Shadoww"), radius: 40, x: 4, y: 10))

        
    }
    func vibrantBackground(cornerRadius: Double, colorScheme: ColorScheme) -> some View {
        return background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppearanceManager.shared.currentTheme .vibrantGradient)
            .shadow(color: Color("Shadoww"), radius: 20, x: 4, y: 10))
    }
    func buttonPadding(_ amount: Double = 10) -> some View {
        return padding(amount)
            .padding(.horizontal, amount)
    }
    
    func bottomPadding(_ amount: Double = 10) -> some View {
        padding(.bottom, amount)
    }
    
    func topPadding(_ amount: Double = 10) -> some View {
        padding(.top, amount)
    }
    
    func leadingPadding(_ amount: Double = 10) -> some View {
        padding(.leading, amount)
    }
    func trailingPadding(_ amount: Double = 10) -> some View {
        padding(.trailing, amount)
    }
    func horizontalPadding(_ amount: Double = 10) -> some View {
        padding(.horizontal, amount)
    }
    func verticalPadding(_ amount: Double = 10) -> some View {
        padding(.vertical, amount)
    }
}

struct SpinnerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AppearanceManager.shared.currentTheme.vibrantGradient,
                lineWidth: 5
            )
            .frame(width: 50, height: 50)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear() {
                self.isAnimating = true
            }
    }
}

extension String {
    func censorEmail() -> String {
        let components = self.components(separatedBy: "@")
        
        if components.count == 2 {
            let username = components[0]
            let domain = components[1]
            
            if username.count >= 3 {
                let censoredUsername = String(username.prefix(3)) + String(repeating: "*", count: username.count - 3)
                return censoredUsername + "@" + domain
            }
        }
        
        return self
    }
}

struct ProfileImageView: View {
    @Environment(\.colorScheme) var colorScheme
    var avatars: [Media] = []
    var avatarImageURL: String?
    var body: some View {
        GeometryReader {
            var size = $0.size
            
            ZStack {
                if let avatarImageURL {
                    ImageX(urlString: avatarImageURL)
                } else if avatars.isEmpty {
                    Image("FullName")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .padding(12)
                } else {
                    TabView {
                        ForEach(avatars) { avatar in
                            if avatar.type == .video {
                                
                            } else if let urlString = avatar.imageURLString {
                                ImageX(urlString: urlString)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(width: size.width, height: size.width)
                    .clipShape(RoundedRectangle(cornerRadius: size.width / 3, style: .continuous))
                    .clipped()
                    .nonVibrantSecondaryBackground(cornerRadius: size.width / 3, colorScheme: colorScheme)
                }
            }
            
        }
    }
}

extension Account {
    var password: String? {
        if let storedEncryptedString = UserDefaults.standard.string(forKey: self.id + "ep"),
           let decryptedString = EncryptionUtility.decryptString(storedEncryptedString, uid: self.id) {
            return decryptedString
        }
        return nil
    }
}
