#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

func captureScreen() -> CGImage? {
  #if os(iOS)
    guard let window = UIApplication.shared.windows.first else { return nil }
    let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
    let image = renderer.image { context in
      window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
    }
    return image.cgImage
  #elseif os(macOS)
    guard let window = NSApp.windows.first else { return nil }
    guard let contentView = window.contentView else { return nil }
    let size = contentView.bounds.size
    let imageRepresentation = contentView.bitmapImageRepForCachingDisplay(in: contentView.bounds)
    contentView.cacheDisplay(in: contentView.bounds, to: imageRepresentation!)
    guard let cgImage = imageRepresentation?.cgImage else { return nil }
    return cgImage
  #endif
}
