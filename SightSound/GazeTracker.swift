import AVFoundation
import SwiftUI
import Vision

#if os(iOS)
  import UIKit
  import ARKit
#elseif os(macOS)
  import AppKit
#endif

class GazeTracker: NSObject {

  #if os(iOS)
    private let sceneView = ARSCNView()
  #endif

  override init() {
    super.init()

    #if os(iOS)
      // Set up scene view
      sceneView.delegate = self
      sceneView.session.delegate = self
      sceneView.showsStatistics = true

    // ... (rest of the init code)
    #endif
  }

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
    let screenSize = getScreenSize()
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height

    let gazeX = gazePoint.x * screenWidth
    let gazeY = screenHeight - gazePoint.y * screenHeight

    return CGPoint(x: gazeX, y: gazeY)
  }

  private func handleDetectedFace(request: VNRequest, error: Error?) {
    guard let results = request.results as? [VNFaceObservation] else {
      print("No face detected.")
      return
    }

    guard let face = results.first, let landmarks = face.landmarks else {
      print("No face landmarks detected.")
      return
    }

    guard let gazePoint = gazePoint(fromEyeLandmarks: landmarks) else {
      print("Failed to calculate gaze point.")
      return
    }

    let imageSize = CGSize(width: face.boundingBox.width, height: face.boundingBox.height)
    let gazePointInScreen = gazePointInScreenCoordinates(gazePoint: gazePoint, imageSize: imageSize)

    print("Gaze point in screen coordinates: \(gazePointInScreen)")

    // Detect and read text at the gaze point
    detectText(at: gazePointInScreen)
  }

  func detectText(at gazePoint: CGPoint) {
    // Capture a screenshot of the current screen

    guard let screenShot = captureScreenshot() else {
      print("Failed to capture a screenshot.")
      return
    }

    // Convert the NSImage to a CGImage
    guard let cgImage = captureScreenshot() else {
      print("Failed to capture a screenshot.")
      return
    }

    // Create a VNDetectTextRectanglesRequest to detect text in the screenshot
    let textDetectionRequest = VNDetectTextRectanglesRequest { (request, error) in
      guard let results = request.results as? [VNTextObservation] else {
        print("No text detected.")
        return
      }

      let distanceThreshold: CGFloat = 50.0  // Adjust this value to control the text detection sensitivity

      for textObservation in results {
        let boundingBox = textObservation.boundingBox
        let textCenter = CGPoint(x: boundingBox.midX, y: boundingBox.midY)

        // Check if the gaze point is close enough to the text center
        if abs(gazePoint.x - textCenter.x) <= distanceThreshold
          && abs(gazePoint.y - textCenter.y) <= distanceThreshold
        {
          // Speak the detected text
          print("Text detected at gaze point: \(textObservation)")

          // Replace this example text with the actual text you want to speak
          let exampleText = "Detected text at gaze point."
          SpeechSynthesizer.shared.speakText(exampleText)
        }
      }
    }
  }

  func handleGazeTracking(with frame: ARFrame) {
    // Extract gaze points and perform necessary gaze tracking logic
    // ...
  }
  
}


// GPT-4 Starts

#if os(iOS)
  extension GazeTracker: ARSCNViewDelegate {
    // ARSCNViewDelegate methods
  }

  extension GazeTracker: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
      DispatchQueue.main.async {
        self.handleGazeTracking(with: frame)
      }
    }
  }
#endif

func getScreenSize() -> CGSize {
  #if os(macOS)
    let screenWidth = NSScreen.main?.frame.size.width ?? 0
    let screenHeight = NSScreen.main?.frame.size.height ?? 0
  #elseif os(iOS)
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
  #endif
  return CGSize(width: screenWidth, height: screenHeight)
}

func captureScreenshot() -> CGImage? {
  #if os(macOS)
    guard let screenShot = NSApplication.shared.keyWindow?.snapshot(),
      let cgImage = screenShot.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else {
      return nil
    }
  #elseif os(iOS)
    guard let screenShot = UIApplication.shared.windows.first?.snapshot() else {
      return nil
    }
    let cgImage = screenShot.cgImage!
  #endif
  return cgImage
}

#if os(macOS)
  extension NSWindow {
    func snapshot() -> NSImage? {
      guard let contentView = contentView else { return nil }
      let bounds = contentView.bounds
      let bitmapRep = contentView.bitmapImageRepForCachingDisplay(in: bounds)
      contentView.cacheDisplay(in: bounds, to: bitmapRep!)
      return NSImage(cgImage: bitmapRep!.cgImage!, size: bounds.size)
    }
  }
#elseif os(iOS)
  extension UIWindow {
    func snapshot() -> UIImage {
      let renderer = UIGraphicsImageRenderer(bounds: bounds)
      return renderer.image { _ in
        drawHierarchy(in: bounds, afterScreenUpdates: true)
      }
    }
  }
#endif
