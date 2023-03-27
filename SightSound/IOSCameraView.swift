#if os(iOS)
  import SwiftUI
  import UIKit

  struct iOSCameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = iOSCameraViewController

    func makeUIViewController(context: Context) -> iOSCameraViewController {
      return iOSCameraViewController()
    }

    func updateUIViewController(_ uiViewController: iOSCameraViewController, context: Context) {
    }
  }

  class iOSCameraViewController: UIViewController {
    private let cameraHandler = iOSCameraViewHandler()

    override func viewDidLoad() {
      super.viewDidLoad()
      cameraHandler.startCaptureSession(in: self.view)
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      cameraHandler.stopCaptureSession()
    }
  }
#endif
