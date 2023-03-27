#if os(iOS)
  import UIKit
  import AVFoundation

  class iOSCameraViewHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func startCaptureSession(in view: UIView) {
      // Check if the device has a camera
      guard
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
      else {
        print("No front camera found.")
        return
      }

      do {
        // Configure the capture session
        let input = try AVCaptureDeviceInput(device: device)
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(
          self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))

        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        captureSession?.addOutput(output)

        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        previewLayer?.frame = view.bounds

        if let previewLayer = previewLayer {
          view.layer.addSublayer(previewLayer)
        }

        // Start the capture session
        captureSession?.startRunning()
      } catch {
        print("Error starting the capture session: \(error.localizedDescription)")
      }
    }

    func stopCaptureSession() {
      captureSession?.stopRunning()
    }

    // AVCaptureVideoDataOutputSampleBufferDelegate method
    func captureOutput(
      _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
      from connection: AVCaptureConnection
    ) {
      // Process the captured video frame here
    }
  }
#endif
