import AVFoundation
import SwiftUI
import Vision

#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

class GazeTracker: NSObject, ObservableObject {
  private func gazePoint(fromEyeLandmarks landmarks: VNFaceLandmarks2D) -> CGPoint? {
    guard let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye else { return nil }

    let leftEyeCenter = averagePoint(points: leftEye.normalizedPoints)
    let rightEyeCenter = averagePoint(points: rightEye.normalizedPoints)

    let gazeDirection = CGPoint(
      x: (leftEyeCenter.x + rightEyeCenter.x) / 2.0,
      y: (leftEyeCenter.y + rightEyeCenter.y) / 2.0)

    return gazeDirection
  }

  private func averagePoint(points: [CGPoint]) -> CGPoint {
    let sum = points.reduce(CGPoint.zero) { (result, point) -> CGPoint in
      return CGPoint(x: result.x + point.x, y: result.y + point.y)
    }

    return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
  }

  private func gazePointInScreenCoordinates(gazePoint: CGPoint, imageSize: CGSize) -> CGPoint {
    #if os(iOS)
      let screenWidth = UIScreen.main.bounds.size.width
      let screenHeight = UIScreen.main.bounds.size.height
    #elseif os(macOS)
      let screenWidth = NSScreen.main?.frame.width ?? 0
      let screenHeight = NSScreen.main?.frame.height ?? 0
    #endif

    let gazeX = gazePoint.x * screenWidth
    let gazeY = screenHeight - gazePoint.y * screenHeight

    return CGPoint(x: gazeX, y: gazeY)
  }

  func detectText(at gazePoint: CGPoint) {
    // Capture a screenshot of the current screen
    guard let screenShot = captureScreen() else {
      print("Failed to capture a screenshot.")
      return
    }

    // Create a VNDetectTextRectanglesRequest to detect text in the screenshot
    let textDetectionRequest = VNDetectTextRectanglesRequest { (request, error) in
      // ... (previous code)

      // Capture a screenshot of the current screen

      /*
         //guard let screenShot = UIApplication.shared.windows.first?.snapshot() else {

         //guard let screenShot = UIApplication.shared.windows.first?.screen else {
         guard let screenShot = UIApplication.UIWindowScene.windows.first? else {

         print("Failed to capture a screenshot.")
         return
         }
         */

      #if os(iOS)
        let renderer = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds)
        let screenShot = renderer.image { context in
          guard let window = UIApplication.shared.windows.first else {
            // handle error if window is nil
            return
          }
          window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
      #elseif os(macOS)
        let screenRect = NSScreen.main?.frame ?? CGRect.zero
        let bitmapRep = NSBitmapImageRep(
          bitmapDataPlanes: nil, pixelsWide: Int(screenRect.size.width),
          pixelsHigh: Int(screenRect.size.height), bitsPerSample: 8, samplesPerPixel: 4,
          hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0,
          bitsPerPixel: 0)!
        let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapRep)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        NSApp.keyWindow?.contentView?.display(screenRect)
        let screenShot = NSImage(size: screenRect.size)
        screenShot.addRepresentation(bitmapRep)
        NSGraphicsContext.restoreGraphicsState()
      #endif

      // Get the size of the image
      let screenShotSize = screenShot.size

      // Create a VNDetectTextRectanglesRequest to detect text in the screenshot
      let textDetectionRequest = VNDetectTextRectanglesRequest { (request, error) in
        guard let results = request.results as? [VNTextObservation] else {
          print("No text detected.")
          return
        }

        for textObservation in results {
          let boundingBox = textObservation.boundingBox
          let textCenter = CGPoint(x: boundingBox.midX, y: boundingBox.midY)

          let distanceThreshold: CGFloat = 50.0  // Adjust this value to control the text detection sensitivity

          // Check if the gaze point is close enough to the text center
          if abs(gazePoint.x - textCenter.x) <= distanceThreshold
            && abs(gazePoint.y - textCenter.y) <= distanceThreshold
          {
            // Speak the detected text
            print("Text detected at gaze point: \(textObservation)")
          }
        }
      }

      let handler = VNImageRequestHandler(cgImage: screenShot.cgImage as! CGImage, options: [:])

      do {
        try handler.perform([textDetectionRequest])
      } catch {
        print("Failed to perform text detection: (error)")
      }

    }

    let handler = VNImageRequestHandler(cgImage: screenShot, options: [:])

    do {
      try handler.perform([textDetectionRequest])
    } catch {
      print("Failed to perform text detection: \(error)")
    }
  }

  func handleDetectedFace() {
    // Capture the screen
    guard let screenImage = captureScreen() else { return }

    // Convert the NSImage to a CIImage
    guard let ciImage = nsImageToCIImage(nsImage: screenImage) else { return }

    // Create a Vision request handler
    let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])

    // Create a face detection request
    let faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
      guard let observations = request.results as? [VNFaceObservation], let strongSelf = self else {
        return
      }

      // Handle detected faces
      for faceObservation in observations {
        let faceBoundingBox = self.boundingBox(for: faceObservation, containerSize: imageSize)
        let faceImage = strongSelf.cropImage(screenImage, to: faceBoundingBox)
        strongSelf.handleDetectedText(in: faceImage)
      }
    }

    // Perform the face detection request
    do {
      try requestHandler.perform([faceDetectionRequest])
    } catch {
      print("Error performing face detection request: \(error)")
    }
  }

  func boundingBox(for faceObservation: VNFaceObservation, containerSize: CGSize) -> CGRect {
    let x = faceObservation.boundingBox.origin.x * containerSize.width
    let y =
      (1 - faceObservation.boundingBox.origin.y - faceObservation.boundingBox.height)
      * containerSize.height
    let width = faceObservation.boundingBox.width * containerSize.width
    let height = faceObservation.boundingBox.height * containerSize.height

    return CGRect(x: x, y: y, width: width, height: height)
  }

  func nsImageToCIImage(nsImage: NSImage) -> CIImage? {
    guard let tiffData = nsImage.tiffRepresentation,
      let imageRep = NSBitmapImageRep(data: tiffData),
      let cgImage = imageRep.cgImage
    else {
      return nil
    }
    return CIImage(cgImage: cgImage)
  }

  // --------------------------------------------------------------------- //

  @Published var gazePointInScreen = CGPoint(x: 0, y: 0)

  var captureSession: AVCaptureSession?
  var videoDataOutput: AVCaptureVideoDataOutput?

  func startCapture() {
    // Create an AVCaptureSession
    let session = AVCaptureSession()

    // Set the session's sessionPreset to high to capture high-quality video
    session.sessionPreset = .high

    // Get the default video device
    guard
      let videoDevice = AVCaptureDevice.default(
        .builtInWideAngleCamera, for: .video, position: .front)
    else {
      fatalError("Unable to access front camera")
    }

    // Create an AVCaptureDeviceInput with the video device
    guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
      fatalError("Unable to create AVCaptureDeviceInput")
    }

    // Add the input to the session
    if session.canAddInput(videoDeviceInput) {
      session.addInput(videoDeviceInput)
    }

    // Create an AVCaptureVideoDataOutput to capture video frames
    let videoDataOutput = AVCaptureVideoDataOutput()
    videoDataOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
    ]
    videoDataOutput.alwaysDiscardsLateVideoFrames = true

    // Create a dispatch queue to handle the video frames
    let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

    // Add the output to the session
    if session.canAddOutput(videoDataOutput) {
      session.addOutput(videoDataOutput)
    }

    // Save the session and videoDataOutput properties
    self.captureSession = session
    self.videoDataOutput = videoDataOutput

    // Start the session
    session.startRunning()
  }
}

extension GazeTracker: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    // Convert the sample buffer to a CIImage
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return
    }
    let ciImage = CIImage(cvImageBuffer: imageBuffer)

    // Determine the orientation of the video frames
    var orientation: CGImagePropertyOrientation
    switch connection.videoOrientation {
    case .portrait:
      orientation = .right
    case .portraitUpsideDown:
      orientation = .left
    case .landscapeLeft:
      orientation = .up
    case .landscapeRight:
      orientation = .down
    default:
      orientation = .up
    }

    // Create a VNImageRequestHandler with the CIImage
    let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: handleDetectedFace)
    let detectFaceRequestHandler = VNImageRequestHandler(
      ciImage: ciImage, orientation: orientation, options: [:])

    // Perform the face detection
    do {
      try detectFaceRequestHandler.perform([detectFaceRequest])
    } catch {
      print("Unable to perform face detection: \(error.localizedDescription)")
    }
  }
}

#if os(iOS)
  struct CameraPreview: UIViewRepresentable {
    @ObservedObject var gazeTracker: GazeTracker

    func makeUIView(context: Context) -> UIView {
      // Create the AVCaptureVideoPreviewLayer
      let previewLayer = AVCaptureVideoPreviewLayer(session: gazeTracker.captureSession!)
      previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

      // Create a UIView to contain the preview layer
      let previewView = UIView(
        frame: CGRect(
          x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
      previewView.layer.addSublayer(previewLayer)

      return previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
      // Start capturing the video and tracking the user's gaze
      gazeTracker.startCapture()
    }
  }
#elseif os(macOS)
  struct CameraPreview: NSViewRepresentable {
    @ObservedObject var gazeTracker: GazeTracker

    func makeNSView(context: Context) -> NSView {
      // Create the AVCaptureVideoPreviewLayer
      let previewLayer = AVCaptureVideoPreviewLayer(
        sessionWithNoConnection: gazeTracker.captureSession ?? AVCaptureSession())
      previewLayer.videoGravity = .resizeAspectFill

      // Create an NSView to contain the preview layer
      let previewView = NSView(
        frame: CGRect(
          x: 0, y: 0, width: NSScreen.main?.frame.width ?? 0,
          height: NSScreen.main?.frame.height ?? 0))
      previewView.layer?.addSublayer(previewLayer)

      return previewView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
      // Start capturing the video and tracking the user's gaze
      gazeTracker.startCapture()
    }
  }
#endif
