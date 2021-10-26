//
//  Shimmer.swift
//
//  Created by Vikram Kriplaney on 23.03.21.
//

import SwiftUI

//let centerColor = Color.white.opacity(0.3)
//let edgeColor = Color.white.opacity(1)

/// A view modifier that applies an animated "shimmer" to any view, typically to show that
/// an operation is in progress.
public struct Shimmer: ViewModifier {
    
    @State private var phase: CGFloat = 0
    var duration: Double
    var bounce: Bool
    
    let invertedMask: Bool
    
    public init(duration: Double = 1.5, bounce: Bool = false, invertedMask: Bool = false) {
        
        self.duration = duration
        self.bounce = bounce
        self.invertedMask = invertedMask
    }

    public func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase, invertedMask: invertedMask).animation(
                Animation.linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
            ))
            .onAppear { phase = 0.8 }
    }

    /// An animatable modifier to interpolate between `phase` values.
    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0
        var invertedMask: Bool = false
        
        internal init(phase: CGFloat, invertedMask: Bool = false) {
            self.phase = phase
            self.invertedMask = invertedMask
        }

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            
            if !invertedMask {
                
                content.mask(GradientMask.shimmerGradientMask(phase).scaleEffect(3))
            } else {
                
                content.mask(GradientMask.invertShimmerGradientMask(phase).scaleEffect(3))
            }
        }
    }

    /// A slanted, animatable gradient between transparent and opaque to use as mask.
    /// The `phase` parameter shifts the gradient, moving the opaque band.
    struct GradientMask: View {
        
        let phase: CGFloat
        let centerColor: Color
        let edgeColor: Color
        
        internal init(phase: CGFloat, centerColor: Color = .black, edgeColor: Color = .black.opacity(0.3)) {
            self.phase = phase
            self.centerColor = centerColor
            self.edgeColor = edgeColor
        }
        
        var body: some View {
            LinearGradient(gradient:
                Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

public extension View {
    /// Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    ///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
    @ViewBuilder func shimmering(
        active: Bool = true, duration: Double = 1.5, bounce: Bool = false, invertedMask: Bool = false
    ) -> some View {
        if active {
            modifier(Shimmer(duration: duration, bounce: bounce, invertedMask: invertedMask))
        } else {
            self
        }
    }
}

extension Shimmer.GradientMask {
    
    static func shimmerGradientMask(_ phase: CGFloat) -> Shimmer.GradientMask {
        
        Shimmer.GradientMask(phase: phase)
    }
    
    static func invertShimmerGradientMask(_ phase: CGFloat) -> Shimmer.GradientMask {
        
        Shimmer.GradientMask(phase: phase, centerColor: .white.opacity(0.3), edgeColor: .white.opacity(1))
    }
}

extension Shimmer.AnimatedMask {
    
    
}

#if DEBUG
struct Shimmer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Text("SwiftUI Shimmer")
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Text("SwiftUI Shimmer").preferredColorScheme(.light)
                Text("SwiftUI Shimmer").preferredColorScheme(.dark)
                VStack(alignment: .leading) {
                    Text("Loading...").font(.title)
                    Text(String(repeating: "Shimmer", count: 12))
                        .redacted(reason: .placeholder)
                }.frame(maxWidth: 200)
            }
        }
        .padding()
        .shimmering()
        .previewLayout(.sizeThatFits)
    }
}
#endif
