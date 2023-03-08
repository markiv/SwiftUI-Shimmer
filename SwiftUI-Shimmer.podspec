Pod::Spec.new do |s|
    s.name             = 'SwiftUI-Shimmer'
    s.version          = '1.2.0'
    s.summary          = 'Shimmer is a super-light modifier that adds a shimmering effect to any SwiftUI View, for example, to show that an operation is in progress.'
    s.homepage         = 'https://github.com/markiv/SwiftUI-Shimmer'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Vikram Kriplaney' => 'vikram@kriplaney.com' }
    s.source           = { :git => 'https://github.com/markiv/SwiftUI-Shimmer.git', :tag => s.version.to_s }
    s.ios.deployment_target = '13.0'
    s.osx.deployment_target = '10.15'
    s.watchos.deployment_target = '6.0'
    s.tvos.deployment_target = '13.0'
    s.swift_version = '5.0'
    s.source_files = 'Sources/Shimmer/**/*'
  end