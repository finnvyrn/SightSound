import SwiftUI

struct ContentView: View {
  var body: some View {

    #if os(iOS)
      iOSCameraView()
    #elseif os(macOS)
      macOSCameraView()
    #endif

    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
    }
    .padding()

  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
