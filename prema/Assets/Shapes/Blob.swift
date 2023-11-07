//
//  Blob.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/2/23.
//

import SwiftUI

struct Blob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: -0.47981*width, y: 1.51468*height))
        path.addCurve(to: CGPoint(x: -0.98521*width, y: 1.43441*height), control1: CGPoint(x: -0.7049*width, y: 1.67903*height), control2: CGPoint(x: -0.91053*width, y: 1.52964*height))
        path.addCurve(to: CGPoint(x: -1.70734*width, y: 1.09209*height), control1: CGPoint(x: -1.16408*width, y: 1.44907*height), control2: CGPoint(x: -1.55894*width, y: 1.40113*height))
        path.addCurve(to: CGPoint(x: -1.79274*width, y: -0.12798*height), control1: CGPoint(x: -1.89183*width, y: 0.70789*height), control2: CGPoint(x: -1.83255*width, y: 0.20783*height))
        path.addLine(to: CGPoint(x: -1.79209*width, y: -0.13351*height))
        path.addCurve(to: CGPoint(x: -0.71099*width, y: -0.61611*height), control1: CGPoint(x: -1.75229*width, y: -0.46935*height), control2: CGPoint(x: -1.22239*width, y: -0.74755*height))
        path.addCurve(to: CGPoint(x: 0.38382*width, y: -0.85991*height), control1: CGPoint(x: -0.19958*width, y: -0.48466*height), control2: CGPoint(x: 0.16126*width, y: -0.98727*height))
        path.addCurve(to: CGPoint(x: 0.96435*width, y: -0.11225*height), control1: CGPoint(x: 0.60638*width, y: -0.73255*height), control2: CGPoint(x: 0.90688*width, y: -0.27803*height))
        path.addCurve(to: CGPoint(x: 0.39906*width, y: 0.87297*height), control1: CGPoint(x: 1.02182*width, y: 0.05352*height), control2: CGPoint(x: 1.10061*width, y: 0.75688*height))
        path.addCurve(to: CGPoint(x: -0.47981*width, y: 1.51468*height), control1: CGPoint(x: -0.30249*width, y: 0.98906*height), control2: CGPoint(x: -0.19845*width, y: 1.30925*height))
        path.closeSubpath()
        return path
    }
}
