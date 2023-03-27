import AVFAudio

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
  let synthesizer = AVSpeechSynthesizer()

  override init() {
    super.init()
    synthesizer.delegate = self
  }

  // Implement the delegate methods here
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
  {
    print("Speech started")
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
  {
    print("Speech finished")
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance)
  {
    print("Speech paused")
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance
  ) {
    print("Speech continued")
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance)
  {
    print("Speech cancelled")
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange,
    utterance: AVSpeechUtterance
  ) {
    //print("Will speak range:", characterRange)
  }
}

extension SpeechSynthesizer {
  func speakText(_ text: String) {
    //print(AVSpeechSynthesisVoice.currentLanguageCode())
    //print(AVSpeechSynthesisVoice.speechVoices())

    let utterance = AVSpeechUtterance(string: text)
    //utterance.rate = 0.57
    utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Ava-premium")
    //utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")

    #if os(iOS)
      utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Ava")
    #endif
    //print("Current voice: \(utterance.voice)")

    synthesizer.speak(utterance)
  }
}
