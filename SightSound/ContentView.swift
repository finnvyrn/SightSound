import SwiftUI

struct ContentView: View {
  
  @ObservedObject var gazeTracker = GazeTracker()

  
  var body: some View {
    /*
     VStack {
       Image(systemName: "globe")
         .imageScale(.large)
         .foregroundColor(.accentColor)
       Text("Hello, world!")
     }
     .padding()
     */

    /*
    #if os(iOS)
      iOSCameraView()
    #elseif os(macOS)
      macOSCameraView()
    #endif
     */
    
    /*
    Text("Eye Gaze Detection")
        .font(.largeTitle)
        .padding()
    CameraFeedView()
     */
    
  
    CameraPreview(gazeTracker: gazeTracker)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
