//
//  Shimmer.swift
//
//  Created by Vikram Kriplaney on 23.03.21.
//

import SwiftUI

/// A view modifier that applies an animated "shimmer" to any view, typically to show that
/// an operation is in progress.
public struct Shimmer: ViewModifier {
    
    /// The default animation effect.
    public static let defaultAnimation: Animation = .linear(duration: 1.5).repeatForever(autoreverses: false)
    
    @State
    private var phase: CGFloat = 0
    
    private let animation: Animation
    private let gradientMask: GradientMask
    
    /// Initializes his modifier with a custom animation,
    /// - Parameter animation: A custom animation. The default animation is
    ///   `.linear(duration: 1.5).repeatForever(autoreverses: false)`.
    init(
        animation: Animation,
        gradientMask: GradientMask
    ) {
        self.animation = animation
        self.gradientMask = gradientMask
    }
    
    /// Convenience, backward-compatible initializer.
    /// - Parameters:
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    ///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
    ///   - delay:A delay in seconds. Defaults to `0`.
    init(
        duration: Double,
        bounce: Bool,
        delay: Double,
        gradientMask: GradientMask
    ) {
        self.init(
            animation: .linear(duration: duration)
                .repeatForever(autoreverses: bounce)
                .delay(delay),
            gradientMask: .init()
        )
    }

    public func body(content: Content) -> some View {
        content
            .modifier(
                AnimatedMask(gradientMask: gradientMask, phase: phase)
                    .animation(animation)
            )
            .onAppear {
                phase = 0.8
            }
    }

    /// An animatable modifier to interpolate between `phase` values.
    struct AnimatedMask: AnimatableModifier {
        
        let gradientMask: GradientMask
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
                .mask(
                    gradientMask
                        .gradient(with: phase)
                        .scaleEffect(3),
                    inverse: gradientMask.inverse
                )
        }
    }
    
    /// Definition for an animatable gradient used as a mask
    public struct GradientMask {
        
        /// Inverse the gradient mask
        public let inverse: Bool
        /// Opacity of the center gradient stop
        public let centerOpacity: CGFloat
        /// Opacity of the edge gradient stops
        public let edgeOpacity: CGFloat
        /// Start point of the linear gradient
        public let startPoint: UnitPoint
        /// End point of the linear gradient
        public let endPoint: UnitPoint
        /// Distance between linear gradient stops
        public let width: CGFloat
        
        public init(
            inverse: Bool = false,
            centerOpacity: CGFloat = 1,
            edgeOpacity: CGFloat = 0.3,
            startPoint: UnitPoint = .topLeading,
            endPoint: UnitPoint = .bottomTrailing,
            width: CGFloat = 0.1
        ) {
            self.inverse = inverse
            self.centerOpacity = centerOpacity
            self.edgeOpacity = edgeOpacity
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.width = width
        }
        
        func gradient(with phase: CGFloat) -> some View {
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(edgeOpacity), location: phase),
                    .init(color: .black.opacity(centerOpacity), location: phase + width),
                    .init(color: .black.opacity(edgeOpacity), location: phase + width * 2),
                ],
                startPoint: startPoint,
                endPoint: endPoint
            )
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
    ///   - delay:A delay in seconds. Defaults to `0`.
    @ViewBuilder func shimmering(
        active: Bool = true,
        duration: Double = 1.5,
        bounce: Bool = false,
        delay: Double = 0,
        gradientMask: Shimmer.GradientMask = .init()
    ) -> some View {
        if active {
            modifier(Shimmer(
                duration: duration,
                bounce: bounce,
                delay: delay,
                gradientMask: gradientMask))
        } else {
            self
        }
    }

    // Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - animation: A custom animation. The default animation is
    ///   `.linear(duration: 1.5).repeatForever(autoreverses: false)`.
    @ViewBuilder
    func shimmering(
        active: Bool = true,
        animation: Animation = Shimmer.defaultAnimation,
        gradientMask: Shimmer.GradientMask = .init()
    ) -> some View {
        if active {
            modifier(Shimmer(animation: animation, gradientMask: gradientMask))
        } else {
            self
        }
    }
}

#if DEBUG
    struct Shimmer_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                Text("SwiftUI Shimmer")
                    .shimmering()
                
                Text("SwiftUI Shimmer")
                    .shimmering(gradientMask: .init(
                        inverse: false,
                        centerOpacity: 1,
                        edgeOpacity: 0.3,
                        startPoint: .trailing,
                        endPoint: .leading,
                        width: 0.1))
                    .preferredColorScheme(.light)
                
                Text("SwiftUI Shimmer")
                    .shimmering(gradientMask: .init(
                        inverse: false,
                        centerOpacity: 1,
                        edgeOpacity: 0.3,
                        startPoint: .top,
                        endPoint: .bottom,
                        width: 0.1))
                    .preferredColorScheme(.dark)
                
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                    VStack(alignment: .leading) {
                        Text("Loading...").font(.title)
                        Text(String(repeating: "Shimmer", count: 12))
                            .redacted(reason: .placeholder)
                    }
                    .frame(maxWidth: 200)
                    .shimmering(gradientMask: .init(
                        inverse: false,
                        centerOpacity: 0.8,
                        edgeOpacity: 0.3,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing,
                        width: 0.2))
                }
            }
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
#endif
