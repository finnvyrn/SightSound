import AVFoundation
import SwiftUI

class CameraFeedViewModel: NSObject, ObservableObject {
  @Published var previewLayer: AVCaptureVideoPreviewLayer?
  private let session = AVCaptureSession()
  private let videoOutput = AVCaptureVideoDataOutput()
  private let queue = DispatchQueue(label: "com.ethan-quinn.SightSound.queue")

  func configureCaptureSession() {
    guard
      let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    else {
      print("Unable to access front camera")
      return
    }

    do {
      let input = try AVCaptureDeviceInput(device: camera)

      if session.canAddInput(input) {
        session.addInput(input)
      } else {
        print("Failed to add input")
        return
      }

      if session.canAddOutput(videoOutput) {
        session.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        videoOutput.videoSettings = [
          (kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
      } else {
        print("Failed to add output")
        return
      }

      let previewLayer = AVCaptureVideoPreviewLayer(session: session)
      previewLayer.videoGravity = .resizeAspectFill
      self.previewLayer = previewLayer
      session.startRunning()

    } catch {
      print("Error configuring capture session: \(error)")
    }
  }

  func startRunningCaptureSession() {
    session.startRunning()
  }

  func stopCaptureSession() {
    session.stopRunning()
  }
}

extension CameraFeedViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    // Add the code for processing the sample buffer here
  }
}
