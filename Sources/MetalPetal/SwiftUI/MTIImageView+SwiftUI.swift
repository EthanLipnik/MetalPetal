#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit
import MetalKit

@MainActor
@Observable
public final class MTIImageViewProxy {
    @ObservationIgnored
    private weak var imageView: MTIImageView?

    public init() {}

    public var view: MTIImageView? {
        imageView
    }

    @MainActor
    public func setImage(_ image: MTIImage?) {
        imageView?.image = image
    }

    @MainActor
    public func perform(_ action: (MTIImageView) -> Void) {
        guard let view else { return }
        action(view)
    }
}

private struct MTIImageViewProxyKey: EnvironmentKey {
    static let defaultValue: MTIImageViewProxy? = nil
}

public extension EnvironmentValues {
    var mtiImageViewProxy: MTIImageViewProxy? {
        get { self[MTIImageViewProxyKey.self] }
        set { self[MTIImageViewProxyKey.self] = newValue }
    }
}

public extension View {
    func mtiImageViewProxy(_ proxy: MTIImageViewProxy?) -> some View {
        environment(\.mtiImageViewProxy, proxy)
    }
}

@MainActor
public struct MTIImageViewRepresentable: UIViewRepresentable {

    public enum Content {
        case image(MTIImage?)
        case manual
    }

    private let content: Content
    private let configure: (MTIImageView) -> Void
    private let explicitProxy: MTIImageViewProxy?

    public init(image: MTIImage?, configure: @escaping (MTIImageView) -> Void = { _ in }) {
        self.content = .image(image)
        self.configure = configure
        self.explicitProxy = nil
    }

    public init(proxy: MTIImageViewProxy? = nil, configure: @escaping (MTIImageView) -> Void = { _ in }) {
        self.content = .manual
        self.configure = configure
        self.explicitProxy = proxy
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(explicitProxy: explicitProxy)
    }

    public func makeUIView(context: Context) -> MTIImageView {
        let view = MTIImageView(frame: .zero)
        configure(view)
        attachProxy(view: view, context: context)
        applyContent(to: view)
        return view
    }

    public func updateUIView(_ uiView: MTIImageView, context: Context) {
        context.coordinator.explicitProxy = explicitProxy
        attachProxy(view: uiView, context: context)
        if case let .image(image) = content {
            if uiView.image !== image {
                uiView.image = image
            }
        }
    }

    public static func dismantleUIView(_ uiView: MTIImageView, coordinator: Coordinator) {
        coordinator.detach(view: uiView)
    }

    private func attachProxy(view: MTIImageView, context: Context) {
        context.coordinator.attach(view: view, environmentProxy: context.environment.mtiImageViewProxy)
    }

    private func applyContent(to view: MTIImageView) {
        if case let .image(image) = content {
            view.image = image
        }
    }

    @MainActor
    public final class Coordinator {
        fileprivate var explicitProxy: MTIImageViewProxy?
        private weak var attachedProxy: MTIImageViewProxy?

        init(explicitProxy: MTIImageViewProxy?) {
            self.explicitProxy = explicitProxy
        }

        func attach(view: MTIImageView, environmentProxy: MTIImageViewProxy?) {
            let target = explicitProxy ?? environmentProxy
            if attachedProxy !== target {
                attachedProxy?.bind(to: nil)
                attachedProxy = target
            }
            target?.bind(to: view)
        }

        func detach(view: MTIImageView) {
            if attachedProxy?.view === view {
                attachedProxy?.bind(to: nil)
                attachedProxy = nil
            }
        }
    }
}

@MainActor
private extension MTIImageViewProxy {
    func bind(to view: MTIImageView?) {
        imageView = view
    }
}

#if DEBUG
@MainActor
private enum MTIImageViewPreviewFactory {
    static func makeSolidImage(hue: CGFloat) -> MTIImage {
        let color = UIColor(hue: hue, saturation: 0.8, brightness: 0.95, alpha: 1)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return MTIImage(
            color: MTIColor(red: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)),
            sRGB: true,
            size: CGSize(width: 256, height: 256)
        )
    }
}

@MainActor
private struct MTIImageViewProxyPreview: View {
    @State private var proxy = MTIImageViewProxy()
    @State private var hue: CGFloat = 0.37

    var body: some View {
        VStack(spacing: 12) {
            MTIImageViewRepresentable(proxy: proxy) { view in
                view.clearColor = MTLClearColorMake(0, 0, 0, 1)
            }
            .frame(width: 180, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(radius: 6, y: 4)
            .onAppear { applyCurrentHue() }

            Button("Advance Frame") {
                advanceHue()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    private func advanceHue() {
        hue = (hue + 0.12).truncatingRemainder(dividingBy: 1)
        applyCurrentHue()
    }

    private func applyCurrentHue() {
        proxy.setImage(MTIImageViewPreviewFactory.makeSolidImage(hue: hue))
    }
}

@MainActor
private struct MTIImageViewStaticPreview: View {
    var body: some View {
        MTIImageViewRepresentable(image: MTIImageViewPreviewFactory.makeSolidImage(hue: 0.58))
            .frame(width: 180, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview("Static image") {
    MTIImageViewStaticPreview()
}

#Preview("Manual proxy updates") {
    MTIImageViewProxyPreview()
}
#endif

#endif
