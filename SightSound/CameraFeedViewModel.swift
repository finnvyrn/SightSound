import Vision
import AVFoundation

class CameraFeedViewModel: NSObject, ObservableObject {
  
  private var requestHandler = VNSequenceRequestHandler()
  @Published var previewLayer: AVCaptureVideoPreviewLayer?
  
  func startRunningCaptureSession() {
      self.session.startRunning()
  }

  func stopRunningCaptureSession() {
      self.session.stopRunning()
  }
  
  func detectEyeLandmarks(sampleBuffer: CMSampleBuffer) {
      guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
      
      let detectFaceLandmarksRequest = VNDetectFaceLandmarksRequest { (request, error) in
          if let error = error {
            print("Failed to detect face landmarks: \(error.localizedDescription)")
            return
        }

        guard let results = request.results as? [VNFaceObservation] else { return }
        
        for faceObservation in results {
            DispatchQueue.main.async {
                self.handleFaceLandmarks(faceObservation)
            }
        }
    }

    do {
        try requestHandler.perform([detectFaceLandmarksRequest], on: pixelBuffer)
    } catch {
        print("Failed to perform request: \(error.localizedDescription)")
    }
  }
  
  func handleFaceLandmarks(_ faceObservation: VNFaceObservation) {
    if let leftEye = faceObservation.landmarks?.leftEye {
      print("Left eye landmarks: \(leftEye.normalizedPoints)")
    }
    
    if let rightEye = faceObservation.landmarks?.rightEye {
      print("Right eye landmarks: \(rightEye.normalizedPoints)")
    }
  }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
      detectEyeLandmarks(sampleBuffer: sampleBuffer)
  }
}


