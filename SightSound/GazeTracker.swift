import Vision

private func gazePoint(fromEyeLandmarks landmarks: VNFaceLandmarks2D) -> CGPoint? {
    guard let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye else { return nil }
    
    let leftEyeCenter = averagePoint(points: leftEye.normalizedPoints)
    let rightEyeCenter = averagePoint(points: rightEye.normalizedPoints)
    
    let gazeDirection = CGPoint(x: (leftEyeCenter.x + rightEyeCenter.x) / 2.0,
                                y: (leftEyeCenter.y + rightEyeCenter.y) / 2.0)
    
    return gazeDirection
}

private func averagePoint(points: [CGPoint]) -> CGPoint {
    let sum = points.reduce(CGPoint.zero) { (result, point) -> CGPoint in
        return CGPoint(x: result.x + point.x, y: result.y + point.y)
    }
    
    return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
}


#if os(iOS)
//import UIKit
import SwiftUI

private func gazePointInScreenCoordinates(gazePoint: CGPoint, imageSize: CGSize) -> CGPoint {
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    let gazeX = gazePoint.x * screenWidth
    let gazeY = screenHeight - gazePoint.y * screenHeight
    
    return CGPoint(x: gazeX, y: gazeY)
}

func detectText(at gazePoint: CGPoint) {
    // Capture a screenshot of the current screen
  
  
  /*
    //guard let screenShot = UIApplication.shared.windows.first?.snapshot() else {
  
  //guard let screenShot = UIApplication.shared.windows.first?.screen else {
  guard let screenShot = UIApplication.UIWindowScene.windows.first? else {
  
      print("Failed to capture a screenshot.")
      return
  }
   */
  
  
  let renderer = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds)
  let screenShot = renderer.image { context in
      guard let window = UIApplication.shared.windows.first else {
          // handle error if window is nil
          return
      }
      window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
  }

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
          
          let distanceThreshold: CGFloat = 50.0 // Adjust this value to control the text detection sensitivity
          
          // Check if the gaze point is close enough to the text center
          if abs(gazePoint.x - textCenter.x) <= distanceThreshold && abs(gazePoint.y - textCenter.y) <= distanceThreshold {
              // Speak the detected text
              print("Text detected at gaze point: \(textObservation)")
          }
      }
  }
  
  let handler = VNImageRequestHandler(cgImage: screenShot.cgImage!, options: [:])
  
  do {
    try handler.perform([textDetectionRequest])
  } catch {
    print("Failed to perform text detection: (error)")
  }
}
#endif


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

