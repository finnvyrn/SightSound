/*
#if canImport(ARKit)

import ARKit

class iOSEyeTrackingViewController: UIViewController, ARSessionDelegate {
    
    private let session = ARSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up AR session
        session.delegate = self
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension iOSEyeTrackingViewController {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // Check for face anchor
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        
        // Get eye transforms
        let leftEyeTransform = faceAnchor.leftEyeTransform
        let rightEyeTransform = faceAnchor.rightEyeTransform
        
        // Calculate eye positions relative to face center
        let eyeDistance = simd_distance(leftEyeTransform.translation, rightEyeTransform.translation)
        let eyeCenter = simd_mix(leftEyeTransform.translation, rightEyeTransform.translation, 0.5)
        let eyeCenterRelativeToFace = eyeCenter - faceAnchor.transform.translation
        
        // Convert eye positions to screen coordinates
        guard let screenPosition = view.projectPoint(eyeCenterRelativeToFace, orientation: .portrait, viewportSize: view.bounds.size) else { return }
        
        // Determine which part of the screen the user is looking at
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let x = screenPosition.x
        let y = screenHeight - screenPosition.y // Invert y-coordinate to match UIKit convention
        
        let screenFractionX = x / screenWidth
        let screenFractionY = y / screenHeight
        
        let textToSpeak = extractTextAtScreenPosition(xFraction: screenFractionX, yFraction: screenFractionY)
        
        // Use the speech synthesizer to speak the text
        speechSynthesizer.speakText(textToSpeak)
    }

    func extractTextAtScreenPosition(xFraction: CGFloat, yFraction: CGFloat) -> String {
        // Use OCR technology to extract the text at the specified screen position
        // ...
        return "Hello, world!"
    }

}

#endif
*/
