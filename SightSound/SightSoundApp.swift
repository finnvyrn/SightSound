import SpeechSynthesizer
import SwiftUI

@main
struct SightSoundApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }

  init() {
    SpeechSynthesizer.shared.speakText(
      "I love you. As for the \"Invalid rule\" and other warnings, they are usually not critical and should not impact the functionality of your app. These messages are generated by the internal workings of the speech synthesis system and are related to the specific voice resources being used. You can generally ignore these messages as they are not indicative of issues in your code."
    )
  }
}
