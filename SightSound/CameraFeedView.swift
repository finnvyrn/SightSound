import AVFoundation
import SwiftUI
import Vision

#if os(macoS)
  import AppKit
#endif

struct CameraFeedView: View {
  @ObservedObject private var viewModel = CameraFeedViewModel()

  var body: some View {
    VStack {
      #if os(iOS)
        if let previewLayer = viewModel.previewLayer {
          CameraPreviewView_iOS(previewLayer: previewLayer)
            .edgesIgnoringSafeArea(.all)
        } else {
          Text("Camera not available")
        }
      #elseif os(macOS)
        if let previewLayer = viewModel.previewLayer {
          CameraPreviewView_macOS(previewLayer: previewLayer)
            .edgesIgnoringSafeArea(.all)
        } else {
          Text("Camera not available")
        }
      #endif
    }
    .onAppear {
      viewModel.configureCaptureSession()
      viewModel.startRunningCaptureSession()
    }
    .onDisappear {
      viewModel.stopCaptureSession()
    }
  }
}

#if os(iOS)
  struct CameraPreviewView_iOS: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
      let view = UIView(frame: .zero)
      previewLayer.frame = view.bounds
      view.layer.addSublayer(previewLayer)
      return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
      previewLayer.frame = uiView.bounds
    }
  }
#elseif os(macOS)
  struct CameraPreviewView_macOS: NSViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeNSView(context: Context) -> NSView {
      let view = NSView(frame: .zero)
      previewLayer.frame = view.bounds
      view.layer = previewLayer
      view.wantsLayer = true
      return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
      previewLayer.frame = nsView.bounds
    }
  }
#endif
