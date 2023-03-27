import AVFoundation
import SwiftUI
import Vision

#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

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
    let screenWidth = NSScreen.main?.frame.size.width ?? 0
    let screenHeight = NSScreen.main?.frame.size.height ?? 0
  #endif

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
  #if os(iOS)
    guard let screenShot = UIApplication.shared.windows.first?.snapshot() else {
      print("Failed to capture a screenshot.")
      return
    }
  #elseif os(macOS)
    guard let screenShot = NSApplication.shared.keyWindow?.snapshot() else {
      print("Failed to capture a screenshot.")
      return
    }
  #endif

  // Convert the NSImage to a CGImage
  guard let cgImage = screenShot.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to convert NSImage to CGImage.")
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
#endif
