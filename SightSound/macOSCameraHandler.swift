#if os(macOS)
import AppKit
import AVFoundation

class macOSCameraViewHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func startCaptureSession(in view: NSView) {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .medium
        
        /*
        guard let frontCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaType.video) else {
            print("Unable to access front camera.")
            return
        }
         */
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Unable to access front camera.")
            return
        }
         
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession?.canAddInput(input) ?? false {
                captureSession?.addInput(input)
            } else {
                print("Could not add front camera input to capture session.")
                return
            }
        } catch {
            print("Error adding front camera input: (error.localizedDescription)")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession?.canAddOutput(videoOutput) ?? false {
            captureSession?.addOutput(videoOutput)
        } else {
            print("Could not add video output to capture session.")
            return
        }
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        previewLayer?.frame = view.bounds
        
        if let previewLayer = previewLayer {
            view.layer?.addSublayer(previewLayer)
        }
        
        captureSession?.startRunning()
    }
    
    func stopCaptureSession() {
        captureSession?.stopRunning()
    }
    
    // AVCaptureVideoDataOutputSampleBufferDelegate method
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process camera frames here
    }
}
#endif
