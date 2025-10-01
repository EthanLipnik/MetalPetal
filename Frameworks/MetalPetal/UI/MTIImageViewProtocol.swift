//
//  MTIImageViewProtocol.swift
//  MetalPetal
//
//  Created by Yu Ao on 2019/7/5.
//

import Metal

#if SWIFT_PACKAGE
import MetalPetalObjectiveC.Core
#endif

public protocol MTIImageViewProtocol: AnyObject {
    
    var automaticallyCreatesContext: Bool { get set }
    
    var colorPixelFormat: MTLPixelFormat { get set }
    
    var clearColor: MTLClearColor { get set }
    
    var resizingMode: MTIDrawableRenderingResizingMode { get set }
    
    var context: MTIContext? { get set }
    
    var image: MTIImage? { get set }
}

extension MTIImageViewProtocol {
    public var inputPort: Port<Self, MTIImage?, ReferenceWritableKeyPath<Self, MTIImage?>> {
        return Port(self, \.image)
    }
}

#if canImport(UIKit)

extension MTIImageView: @MainActor MTIImageViewProtocol {
    
}

extension MTIThreadSafeImageView: @MainActor MTIImageViewProtocol {
    
}

extension MTIImageView: @MainActor InputPortProvider {
    
}

extension MTIThreadSafeImageView: @MainActor InputPortProvider {
    
}

#endif
