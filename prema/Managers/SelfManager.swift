//
//  SelfManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/6/23.
//

import Firebase
import SwiftUI

class SelfManager: ObservableObject {
    static var shared = SelfManager()
    
    @Published var accepts: [Vision] = []
    @Published var explores: [Vision] = []
    @Published var requests: [Vision] = []
    
    @State var selection = "my visions"
    
    var visions: [Vision] {
        selection == "my visions" ? accepts:selection == "explore" ? explores:requests
    }

    init() {
        listenForVisions()
    }
    
    func deleteVision(_ vision: Vision) {
        Ref.firestoreDb.collection("visions").document(vision.id).delete()
    }
    
    func updateLatestPerfomances() {
        if let profile = AccountManager.shared.currentProfile {
            
        }
    }
    
    
    
    func listenForVisions() {
        if let profile = AccountManager.shared.currentProfile {
            Ref.firestoreDb.collection("visions").whereField("accepts", arrayContains: profile.id).addSnapshotListener { snapshot, error in
                 
                if let error {
                    
                }
                
                if let snapshot {
                    let visionss = snapshot.documents.map { $0.data().parseVision($0.documentID) }
                    withAnimation(.spring()) {
                        self.accepts = visionss
                    }
                    
                    NotificationManager.shared.removeAllNotifications()
                    
                    visionss.forEach { v in
                        v.tasks.forEach { t in
                            NotificationManager.shared.scheduleNotification(task: t)
                        }
                    }
           
                }
            }
            Ref.firestoreDb.collection("visions").whereField("requests", arrayContains: profile.id).addSnapshotListener { snapshot, error in
                 
                if let error {
                    
                }
                
                if let snapshot {
                    let visionss = snapshot.documents.map { $0.data().parseVision($0.documentID) }
                    withAnimation(.spring()) {
                        self.requests = visionss
                    }
                    
                    NotificationManager.shared.removeAllNotifications()
                    
                  
                }
            }
            Ref.firestoreDb.collection("visions").whereField("privacy", isEqualTo: "public").addSnapshotListener { snapshot, error in
                 
                if let error {
                    
                }
                
                if let snapshot {
                    let visionss = snapshot.documents.map { $0.data().parseVision($0.documentID) }
                    withAnimation(.spring()) {
                        self.requests = visionss
                    }
                    
                    NotificationManager.shared.removeAllNotifications()
                    
                  
                }
            }
        }
    }
    
    func updateVisions(_ vision: Vision) {
        if let profile = AccountManager.shared.currentProfile {
            AppearanceManager.shared.startLoading()
            Ref.firestoreDb.collection("visions").document(vision.id).updateData(
                vision.dictionary
            )
        }
        
    }
    
    func createVision(vision: Vision, completion: @escaping() -> ()) {
        if let profile = AccountManager.shared.currentProfile {
            AppearanceManager.shared.startLoading()
            Ref.firestoreDb.collection("visions").addDocument(data: [
                
                "title":vision.title,
                "category":vision.category,
                "privacy":vision.privacy.rawValue.lowercased(),
                "deadline":vision.deadline,
                "visionaries":vision.visionaries.map { $0.dictionary },
                "timestamps":[Date.now.timeIntervalSince1970],
                "accepts":[profile.id],
                "requests":vision.visionaries.filter {$0.id != profile.id }
            ]) { error in
                if let error {
                    
                    
                }
                completion()
                AppearanceManager.shared.stopLoading()
            }
        }
    }
    func createTask(vision: Vision, task: Task, completion: @escaping() -> ()) {
        if let profile = AccountManager.shared.currentProfile {
            AppearanceManager.shared.startLoading()
            
            var dictArray = vision.tasks.map { $0.dictionary }
            
            dictArray.append([
                "id":UUID().uuidString,
                "title":task.title,
                "start":task.start,
                "end":task.end,
                "responsibles":task.responsibles.map { $0.dictionary },
                "timestamps":[Date.now.timeIntervalSince1970],
                "recursion":task.recursion.rawValue
            ])
            
            Ref.firestoreDb.collection("visions").document(vision.id).setData(["tasks": dictArray], merge: true) { error in
                if let error {
                    
                }
                completion()
                AppearanceManager.shared.stopLoading()
            }
        }
        
    }
}
