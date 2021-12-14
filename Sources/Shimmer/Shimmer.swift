//
//  Shimmer.swift
//
//  Created by Vikram Kriplaney on 23.03.21.
//

import SwiftUI

public typealias ShimmerCompletion = (() -> ())

/// A view modifier that applies an animated "shimmer" to any view, typically to show that
/// an operation is in progress.
public struct Shimmer: ViewModifier {
    
    @State private var phase: CGFloat = 0
    var movement: AnimationMovement
    var delay: Double
    @State var contentSize: CGSize = .zero
    var bounces: Bool
    let invertedMask: Bool
    var repeats: Bool
    var completion: ShimmerCompletion?
    
    public init(movement: AnimationMovement = .constantDuration(1.5), delay: Double = 0, bounces: Bool = false, invertedMask: Bool = false, repeats: Bool = true, completion: ShimmerCompletion? = nil) {
        
        self.movement = movement
        self.delay = delay
        self.bounces = bounces
        self.invertedMask = invertedMask
        self.repeats = repeats
        self.completion = completion
    }
    
    public func body(content: Content) -> some View {
        Group {
            
            content
                .modifier(AnimatedMask(phase: phase, invertedMask: invertedMask)
                            .animation(Animation.animation(movement: movement, contentSize: contentSize, delay: delay, repeats: repeats, bounces: bounces)))
                .onAppear { phase = 0.8 }
            
                .background(GeometryReader { geoProxy in
                    
                    Rectangle()
                        .fill(.clear)
                        .preference(key: ContentSizeSetterPreferenceKey.self, value: [ContentSizeSetterPreferenceData(size: geoProxy.size)])
                }, alignment: .center)
                .onAnimationCompleted(for: phase) {
                    
                    guard !repeats else { return }
                    completion?()
                }
        }
        .onPreferenceChange(ContentSizeSetterPreferenceKey.self, perform: { prefs in
            
            contentSize = prefs.first?.size ?? .zero
        })
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
                
                content.mask(GradientMask.shimmerGradientMask(phase).scaleEffect(2))
            } else {
                
                content.mask(GradientMask.invertShimmerGradientMask(phase).scaleEffect(2))
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
                                .init(color: centerColor, location: phase + 0.15),
                                .init(color: edgeColor, location: phase + 0.3)
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
        active: Bool = true, movement: Shimmer.AnimationMovement = .constantDuration(1.5), delay: Double = 0, bounces: Bool = false, invertedMask: Bool = false, repeats: Bool = true, completion: ShimmerCompletion? = nil) -> some View {
            
            if active, #available(iOS 14.0, *) {
                modifier(Shimmer(movement: movement, delay: delay, bounces: bounces, invertedMask: invertedMask, repeats: repeats))
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
        
        Shimmer.GradientMask(phase: phase, centerColor: .black.opacity(0.5), edgeColor: .black.opacity(1))
    }
}

extension Shimmer.AnimatedMask {
    
    
}

public extension Shimmer {
    
    enum AnimationMovement {
        
        case constantVelocity(Double) //Assuming velocity of 1 => traverse screen width in 1 second
        case constantDuration(Double)
    }
}

public extension Shimmer.AnimationMovement {
    
    func duration(with contentSize: CGSize) -> Double {
        
        switch self {
            
        case .constantDuration(let dur): return dur
            
        case .constantVelocity(let vel):
            let screenWidth = UIScreen.main.bounds.size.width
            let contentWidth = contentSize.width
            return contentWidth / screenWidth / vel
        }
    }
}

extension Shimmer {
    //Setting this preference key to precicely get and set
    struct ContentSizeSetterPreferenceData: Equatable {
        
        let size: CGSize
    }
    
    struct ContentSizeSetterPreferenceKey: PreferenceKey {
        static var defaultValue: [ContentSizeSetterPreferenceData] = []
        
        static func reduce(value: inout [ContentSizeSetterPreferenceData], nextValue: () -> [ContentSizeSetterPreferenceData]) {
            value.append(contentsOf: nextValue())
        }
    }
}

extension Animation {
    
    static func animation(movement: Shimmer.AnimationMovement, contentSize: CGSize, delay: Double = 0, repeats: Bool = true, bounces: Bool = false) -> Animation {
        
        if repeats {
            return Animation.linear(duration: movement.duration(with: contentSize))
                .delay(delay)
                .repeatForever(autoreverses: bounces)
        } else {
            return Animation.linear(duration: movement.duration(with: contentSize))
                .delay(delay)
        }
    }
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
