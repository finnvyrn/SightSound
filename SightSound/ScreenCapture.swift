#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

func captureScreen() -> CGImage? {
  #if os(iOS)
    guard let window = UIApplication.shared.windows.first else {
      return nil
    }

    let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
    let image = renderer.image { context in
      window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
    }

    return image.cgImage
  #elseif os(macOS)
    guard let window = NSApp.windows.first else {
      return nil
    }

    return window.contentView?.bitmapImageRepForCachingDisplay(in: window.contentView!.bounds)?
      .cgImage
  #endif
}
