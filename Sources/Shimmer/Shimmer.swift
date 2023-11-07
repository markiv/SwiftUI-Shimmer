//
//  Shimmer.swift
//  SwiftUI-Shimmer
//  Created by Vikram Kriplaney on 23.03.21.
//

import SwiftUI

/// A view modifier that applies an animated "shimmer" to any view, typically to show that an operation is in progress.
public struct Shimmer: ViewModifier {
    private let isActive: Bool
    private let animation: Animation
    private let gradient: Gradient
    private let min, max: CGFloat
    @State private var isInitialState = true
    @Environment(\.layoutDirection) private var layoutDirection

    /// Initializes his modifier with a custom animation,
    /// - Parameters:
    ///   - animation: A custom animation. Defaults to ``Shimmer/defaultAnimation``.
    ///   - gradient: A custom gradient. Defaults to ``Shimmer/defaultGradient``.
    ///   - bandSize: The size of the animated mask's "band". Defaults to 0.3 unit points, which corresponds to
    /// 30% of the extent of the gradient.
    public init(
        isActive: Bool,
        animation: Animation = Self.defaultAnimation,
        gradient: Gradient = Self.defaultGradient,
        bandSize: CGFloat = 0.3
    ) {
        self.isActive = isActive
        self.animation = animation
        self.gradient = gradient
        // Calculate unit point dimensions beyond the gradient's edges by the band size
        self.min = 0 - bandSize
        self.max = 1 + bandSize
    }

    /// The default animation effect.
    public static let defaultAnimation = Animation.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false)

    // A default gradient for the animated mask.
    public static let defaultGradient = Gradient(colors: [
        .black.opacity(0.3), // translucent
        .black, // opaque
        .black.opacity(0.3) // translucent
    ])

    /*
     Calculating the gradient's animated start and end unit points:
     min,min
        \
         ┌───────┐         ┌───────┐
         │0,0    │ Animate │       │  "forward" gradient
     LTR │       │ ───────►│    1,1│  / // /
         └───────┘         └───────┘
                                    \
                                  max,max
                max,min
                  /
         ┌───────┐         ┌───────┐
         │    1,0│ Animate │       │  "backward" gradient
     RTL │       │ ───────►│0,1    │  \ \\ \
         └───────┘         └───────┘
                          /
                       min,max
     */

    /// The start unit point of our gradient, adjusting for layout direction.
    var startPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            return isInitialState ? UnitPoint(x: max, y: min) : UnitPoint(x: 0, y: 1)
        } else {
            return isInitialState ? UnitPoint(x: min, y: min) : UnitPoint(x: 1, y: 1)
        }
    }

    /// The end unit point of our gradient, adjusting for layout direction.
    var endPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            return isInitialState ? UnitPoint(x: 1, y: 0) : UnitPoint(x: min, y: max)
        } else {
            return isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: max, y: max)
        }
    }

    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: isActive ? gradient : .transparent,
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .animation(
                isActive ? animation : .linear(duration: 0), // FW: This is a correct way to stop animation. If using `isActive ? .linear(...) : .none` instead then the animation would be choppy. https://stackoverflow.com/questions/61830571/whats-causing-swiftui-nested-view-items-jumpy-animation-after-the-initial-drawi/61841018#61841018
                value: isInitialState
            )
            .onAppear {
                if isActive {
                    startShimmering()
                }
            }
            .valueChanged(value: isActive) { isActive in
                if isActive {
                    startShimmering()
                } else {
                    stopShimmering()
                }
            }
    }
    
    private func startShimmering() {
        isInitialState = false
    }
    
    private func stopShimmering() {
        isInitialState = true
    }
}

public extension View {
    /// Adds an animated shimmering effect to any view, typically to show that an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - animation: A custom animation. Defaults to ``Shimmer/defaultAnimation``.
    ///   - gradient: A custom gradient. Defaults to ``Shimmer/defaultGradient``.
    ///   - bandSize: The size of the animated mask's "band". Defaults to 0.3 unit points, which corresponds to
    /// 20% of the extent of the gradient.
    @ViewBuilder func shimmering(
        active: Bool = true,
        animation: Animation = Shimmer.defaultAnimation,
        gradient: Gradient = Shimmer.defaultGradient,
        bandSize: CGFloat = 0.3
    ) -> some View {
        modifier(
            Shimmer(isActive: active, animation: animation, gradient: gradient, bandSize: bandSize)
        )
    }

    /// Adds an animated shimmering effect to any view, typically to show that an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - duration: The duration of a shimmer cycle in seconds.
    ///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
    ///   - delay:A delay in seconds. Defaults to `0.25`.
    @available(*, deprecated, message: "Use shimmering(active:animation:gradient:bandSize:) instead.")
    @ViewBuilder func shimmering(
        active: Bool = true, duration: Double, bounce: Bool = false, delay: Double = 0.25
    ) -> some View {
        shimmering(
            active: active,
            animation: .linear(duration: duration).delay(delay).repeatForever(autoreverses: bounce)
        )
    }
}

#if DEBUG
struct Shimmer_Previews: PreviewProvider {
    struct TogglePreview: View {
        @State private var isShimmeringActive = true
        
        var body: some View {
            Form {
                Toggle(isOn: $isShimmeringActive) {
                    Text("Is shimmering active")
                }
                ViewWithItsOwnState()
                    .shimmering(active: isShimmeringActive)
            }
        }
        
        struct ViewWithItsOwnState: View {
            @State private var isOn: Bool = false
            
            var body: some View {
                Toggle(isOn: $isOn) {
                    Text("Should remain the same when toggle shimmering")
                }
                Text("SwiftUI Shimmer")
                    .foregroundColor(.red)
            }
        }
    }
    
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

        VStack(alignment: .leading) {
            Text("مرحبًا")
            Text("← Right-to-left layout direction").font(.body)
            Text("שלום")
        }
        .font(.largeTitle)
        .shimmering()
        .environment(\.layoutDirection, .rightToLeft)
        
        TogglePreview()
            .previewDisplayName("Shimmering toggle")
    }
}
#endif
