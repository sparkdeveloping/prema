//
//  AccountManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/3/23.
//

import SwiftUI
import Firebase
import FirebaseDatabase

class AccountManager: ObservableObject {
    
    static var shared = AccountManager()
  
    var currentAccount: Account? {
        return accounts.first(where: { $0.id == Auth.auth().currentUser?.uid })
    }
    @Published var currentProfile: Profile? {
        didSet {
            saveProfileLocally()
        }
    }
    @Published var accounts: [Account] = [] {
        didSet {
            saveAccountsLocally()
        }
    }
    
    var handle: AuthStateDidChangeListenerHandle?

    
    init() {
        loadAccounts()
        listen()
    }
    
    func listen() {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                //if we have a user, create a new user model
                let account = Account(id: user.uid, email: user.email ?? "noemail@prema.com", creationTimestamp: user.metadata.creationDate?.timeIntervalSince1970 ?? 0, lastLoginTimestamp: user.metadata.lastSignInDate?.timeIntervalSince1970 ?? 0)
                if let index = self.accounts.firstIndex(where: { account == $0 }) {
                    self.accounts[index] = account
                } else {
                    self.accounts.append(account)
                }
                self.fetchProfiles(id: account.id) { profiles in
                    var newAccount = account
                    if let index = self.accounts.firstIndex(where: { account == $0 }) {
                        newAccount.profiles = profiles
                        if let index = profiles.firstIndex(where: { $0.id == self.currentProfile?.id }) {
                            withAnimation(.spring()) {
                                self.currentProfile = profiles[index]
                            }
                        }
                        self.accounts[index] = newAccount
                    } else {
                        self.accounts.append(newAccount)
                    }
                }
            } else {
                // if not, then session is nil
            }
        })
    }
    
    func saveProfileLocally() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(self.currentProfile)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("currentProfile.json")
                try encodedData.write(to: fileURL)
            }
        } catch {
            print("Error saving current profile: \(error)")
        }
    }
    
    func saveAccountsLocally() {
        let accounts = Array(Set(self.accounts))
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(accounts)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("accounts.json")
                try encodedData.write(to: fileURL)
            }
        } catch {
            print("Error saving accounts: \(error)")
        }
    }

    func loadAccounts() {
        do {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("accounts.json")
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let accounts = try decoder.decode([Account].self, from: data)
                self.accounts = Array(Set(accounts))
                self.loadProfile()

            }
        } catch {
            print("Error loading accounts: \(error)")
        }
    }
    
    func loadProfile() {
        do {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("currentProfile.json")
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let currentProfile = try decoder.decode(Profile.self, from: data)
                withAnimation(.spring()) {
                    self.currentProfile = currentProfile
                }

            }
        } catch {
            print("Error loading accounts: \(error)")
        }
    }
    
    func fetchProfiles(id: String, completion: @escaping (([Profile]) -> ())) {
        Firestore.firestore().collection("profiles").whereField("accountID", isEqualTo: id).getDocuments() { snapshot, error in
            
            if let error {
                
            }
            
            if let snapshot {
                completion(snapshot.documents.map { $0.data().parseProfile( $0.documentID) })
            }
        }
    }
    
    func isOnline(bool: Bool, inboxes: [Inbox] = [], tab: String = "Home") {
        if let currentProfile {
            if !currentProfile.id.isEmpty {
                let ref = Ref().databaseIsOnline(uid: currentProfile.id)
                let dict: Dictionary<String, Any> = [
                    "online": bool as Any,
                    "latest": Date().timeIntervalSince1970 as Any,
                    "tab": tab as Any
                ]
                ref.updateChildValues(dict)
            }
        }
    }
    
    func updateInboxStatus(to: [Inbox], online: Bool? = nil, typing: Bool? = nil, inChat: Bool? = nil, tab: String? = nil) {
        if let currentProfile {
            to.forEach { to in
                print("our inbox id is: \(to.id)")
                let ref = Database.database().reference().child("direct").child("inbox").child(to.id).child("status")
                var dict: Dictionary<String, Any> = [:]
                
                if let online {
                    ref.child("online").child(currentProfile.id).setValue(online)
                }
                if let typing {
//                    dict["typing"] = [currentProfile.id:typing]
                    ref.child("typing").child(currentProfile.id).setValue(typing)

                }
                if let inChat {
//                    dict["inChat"] = [currentProfile.id:inChat]
                    ref.child("inChat").child(currentProfile.id).setValue(inChat)

                }
                if let tab {
                    ref.child("tab").child(currentProfile.id).setValue(tab)
//                    dict["tab"] = [currentProfile.id:tab]
                }
                print("our inbox id is: \(to.id) -- dict: \(dict)")
                
//                if !(online == nil && typing == nil && inChat == nil && tab == nil) {
//                    ref.setValue(dict)
//                }
            }
        }
    }
    
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        let set = Set(self)
        return Array(set)
    }
}
