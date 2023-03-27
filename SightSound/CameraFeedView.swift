import SwiftUI
import Vision
import AVFoundation

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
#endif

#if os(macOS)
import AppKit

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
