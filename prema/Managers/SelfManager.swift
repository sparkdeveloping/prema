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
    
    @Published var visions: [Vision] = []
    
    init() {
        listenForVisions()
    }
    

    
    func listenForVisions() {
        if let profile = AccountManager.shared.currentProfile {
            Ref.firestoreDb.collection("visions").whereField("accepts", arrayContains: profile.id).addSnapshotListener { snapshot, error in
                
                if let error {
                    
                }
                
                if let snapshot {
                    withAnimation(.spring()) {
                        self.visions = snapshot.documents.map { $0.data().parseVision($0.documentID) }
                    }
                }
            }
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
                "accepts":[profile.id]
                
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
