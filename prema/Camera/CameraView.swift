//
//  CameraView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/23/23.
//

import ARKit
import SwiftUI

struct CameraView: View {
    @StateObject var manager = CameraManager()
    var body: some View {
        ZStack {
            PreviewView(arView: manager.arView)
        }
        .ignoresSafeArea()
        .onAppear {
            manager.startPreview()
        }
        .onAppear {
            manager.pausePreview()
        }
    }
}

struct PreviewView: UIViewRepresentable {
    var arView: ARSCNView
    func makeUIView(context: Context) -> ARSCNView {
        return arView
    }
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
    
    
}
