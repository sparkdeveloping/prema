//
//  Ref.swift
//  Elixer
//
//  Created by Denzel Anderson on 5/25/22.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

let REF_USER = "users"
let REF_PROFILE = "profiles"
let REF_MESSAGE = "messages"
let REF_INBOX = "inbox"

let URL_STORAGE_ROOT = "gs://elixer-sparkdev.appspot.com"
let STORAGE_PROFILE = "profile"
let PROFILE_IMAGE_URL = "profileImageUrl"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "name"
let STATUS = "status"
let IS_ONLINE = "isOnline"

let ERROR_EMPTY_PHOTO = "Please choose your profile image"
let ERROR_EMPTY_EMAIL = "Please enter an email address"
let ERROR_EMPTY_USERNAME = "Please enter an name"
let ERROR_EMPTY_PASSWORD = "Please enter a password"
let ERROR_EMPTY_EMAIL_RESET = "Please enter an email address for password reset"

let SUCCESS_EMAIL_RESET = "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password"

let IDENTIFIER_TABBAR = "TabBarVC"
let IDENTIFIER_WELCOME = "WelcomeVC"
let IDENTIFIER_CHAT = "ChatVC"
let IDENTIFIER_USER_AROUND = "UsersAroundViewController"


let IDENTIFIER_CELL_USERS = "UserTableViewCell"


class Ref {
    static let storage = Storage.storage().reference(forURL: "gs://elixer-sparkdev.appspot.com")
    static let firestoreDb = Firestore.firestore()
    static let databaseDb = Database.database().reference()
    static let algoliaRef = Ref.databaseDb.child("algolia")
    static let firestoreUsers = Ref.firestoreDb.collection("users")
    static let firestoreProfiles = Ref.firestoreDb.collection("profiles")
    static let firestoreEvents = Ref.firestoreDb.collection("events")
    static let firestoreQuickies = Ref.firestoreDb.collection("quickies")
    static let firestoreUpdates = Ref.firestoreDb.collection("updates")
    static let firestoreInboxes = Ref.firestoreDb.collection("inbox")
    
    static func databaseFollowers(_ id: String) -> DatabaseReference {
        return databaseDb.child("followers").child(id)
    }
    
    static func databaseFollowing(_ id: String) -> DatabaseReference {
        return databaseDb.child("following").child(id)
    }
    
    static func firestoreinbox(_ id: String) -> DocumentReference {
        return firestoreDb.collection("inbox").document(id)
    }
    static func firestoreMessages(_ inboxId: String) -> CollectionReference {
        return firestoreDb.collection("inbox").document(inboxId).collection("messages")
    }
    static func firestoreMessage(inboxId: String, messageId: String) -> DocumentReference {
        return firestoreDb.collection("inbox").document(inboxId).collection("messages").document(messageId)
    }
    
    let databaseRoot: DatabaseReference = Database.database().reference()
    
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    var databaseProfiles: DatabaseReference {
        return databaseRoot.child(REF_PROFILE)
    }
    
    func databaseSpecificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    
    func databaseIsOnline(uid: String) -> DatabaseReference {
        return databaseProfiles.child(uid).child(STATUS)
    }
    
    var databaseMessage: DatabaseReference {
        return databaseRoot.child(REF_MESSAGE)
    }
    
    func databaseMessageSendTo(from: String, to: String) -> DatabaseReference {
        return databaseMessage.child(from).child(to)
    }
    
    var databaseInbox: DatabaseReference {
        return databaseRoot.child(REF_INBOX)
    }
    
    func databaseInbox(id: String) -> DatabaseReference {
        return databaseInbox.child(id)
    }
    
    func databaseInboxForUser(uid: String) -> DatabaseReference {
        return databaseInbox.child(uid)
    }
    
    // Storage Ref
    
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    
    var storageMessage: StorageReference {
        return storageRoot.child(REF_MESSAGE)
    }
    
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    func storageSpecificProfile(uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }
    
    func storageSpecificImageMessage(id: String) -> StorageReference {
        return storageMessage.child("photo").child(id)
    }
    
    func storageSpecificVideoMessage(id: String) -> StorageReference {
        return storageMessage.child("video").child(id)
    }
}
