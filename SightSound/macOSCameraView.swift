#if os(macOS)
  import SwiftUI
  import AVFoundation

  struct macOSCameraView: NSViewRepresentable {
    typealias NSViewType = NSView

    let cameraHandler = macOSCameraViewHandler()

    func makeNSView(context: Context) -> NSView {
      let nsView = NSView()
      cameraHandler.startCaptureSession(in: nsView)
      return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }

    func dismantleNSView(_ nsView: NSView, coordinator: ()) {
      cameraHandler.stopCaptureSession()
    }
  }
#endif
