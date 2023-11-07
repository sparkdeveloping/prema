//
//  AuthManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/3/23.
//

import FirebaseStorage
import Firebase
import SwiftUI

class AuthManager: ObservableObject {
    
    static var shared = AuthManager()
    
    @Published var email: String = "" {
        didSet {
            withAnimation(.spring()) {
                error = nil
            }
        }
    }
    
    @Published var password: String = "" {
        didSet {
            withAnimation(.spring()) {
                error = nil
            }
        }
    }
    
    @Published var error: String?
    
    func login(email: String? = nil, password: String? = nil, onSuccess: @escaping () -> ()) {
        var emaill = self.email
        var passwordd = self.password
        if let email {
            emaill = email
        }
        if let password {
            passwordd = password
        }
        
        Auth.auth().signIn(withEmail: emaill, password: passwordd) { result, error in
            if let error {
                self.error = error.localizedDescription
            }
            
            if let result {
                let user = result.user
                let account = Account(id: user.uid, email: user.email ?? "noemail@prema.com", creationTimestamp: user.metadata.creationDate?.timeIntervalSince1970 ?? 0, lastLoginTimestamp: user.metadata.lastSignInDate?.timeIntervalSince1970 ?? 0)
                withAnimation(.spring()) {
                    AccountManager.shared.accounts.insert(account, at: 0)
                }
                if let encryptedString = EncryptionUtility.encryptString(passwordd, uid: result.user.uid) {
                    UserDefaults.standard.set(encryptedString, forKey: result.user.uid + "ep")
                }
                onSuccess()
            }
            AppearanceManager.shared.stopLoading()
        
        }
    }
    
    func createAccount() {
       
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                self.error = error.localizedDescription
            }
            
            if let result {
                let user = result.user
                let account = Account(id: user.uid, email: user.email ?? "noemail@prema.com", creationTimestamp: user.metadata.creationDate?.timeIntervalSince1970 ?? 0, lastLoginTimestamp: user.metadata.lastSignInDate?.timeIntervalSince1970 ?? 0)
                withAnimation(.spring()) {
                    AccountManager.shared.accounts.insert(account, at: 0)
                }
                if let encryptedString = EncryptionUtility.encryptString(self.password, uid: result.user.uid) {
                    UserDefaults.standard.set(encryptedString, forKey: result.user.uid + "ep")
                }
            }
            AppearanceManager.shared.stopLoading()
        }
    }
    
    func createProfile(accountID: String, fullName: String, username: String, bio: String, gender: Gender, birthday: Date, avatars: [Media], type: ProfileType) {
        AppearanceManager.shared.startLoading()
        let id = Firestore.firestore().collection("profiles").document().documentID
        
        Firestore.firestore().collection("profiles").document(id).setData(
            [
                "accountID": accountID,
                "fullName": fullName,
                "username": username,
                "gender": gender.rawValue,
                "type": type.rawValue,
                "bio": bio,
                "birthday": birthday.timeIntervalSince1970
            
            ]) { error in
                if let error {
                    self.error = error.localizedDescription
                }
                
                StorageManager.uploadMedia(media: avatars, locationName: "avatars") { mediaDict in
                    
                    Firestore.firestore().collection("profiles").document(id).setData(
                        ["media":mediaDict], merge: true)
                    
                    AccountManager.shared.fetchProfiles(id: accountID) { profiles in
                        if let index = AccountManager.shared.accounts.firstIndex(where: {$0.id == accountID }) {
                            AccountManager.shared.accounts[index].profiles = profiles
                            if !profiles.isEmpty {
                                withAnimation(.spring()) {
                                    AccountManager.shared.currentProfile = profiles[0]
                                }
                            }
                            AccountManager.shared.saveAccountsLocally()
                        }
                    }
                    AppearanceManager.shared.stopLoading()
                } onError: { error in
                    AccountManager.shared.fetchProfiles(id: accountID) { profiles in
                        if let index = AccountManager.shared.accounts.firstIndex(where: {$0.id == accountID }) {
                            AccountManager.shared.accounts[index].profiles = profiles
                            if !profiles.isEmpty {
                                withAnimation(.spring()) {
                                    AccountManager.shared.currentProfile = profiles[0]
                                }
                            }
                            AccountManager.shared.saveAccountsLocally()
                        }
                    }
                    AppearanceManager.shared.stopLoading()
                }

              
            }
    }
    
  

    
    
    func checkIfAccountExists() {
        AppearanceManager.shared.startLoading()
        Auth.auth().fetchSignInMethods(forEmail: email) { (methods, error) in
                if let error = error {
                    // An error occurred
                    print("Error checking account existence: \(error.localizedDescription)")
                    self.createAccount()
                } else if let methods = methods {
                    // Methods will be nil if no account exists for the given email

                    if !methods.isEmpty {
                        print("login called")
                        self.login() {}
                    } else {
                        print("create called")
                        self.createAccount()
                    }
                } else {
                    self.createAccount()
                }
            }
    }
    
}
