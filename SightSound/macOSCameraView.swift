#if os(macOS)
import SwiftUI
import AppKit

struct macOSCameraView: NSViewControllerRepresentable {
    typealias NSViewControllerType = macOSCameraViewController

    func makeNSViewController(context: Context) -> macOSCameraViewController {
        return macOSCameraViewController()
    }

    func updateNSViewController(_ nsViewController: macOSCameraViewController, context: Context) {
    }
}

class macOSCameraViewController: NSViewController {
    private let cameraHandler = macOSCameraViewHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraHandler.startCaptureSession(in: self.view)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        cameraHandler.stopCaptureSession()
    }
}
#endif
