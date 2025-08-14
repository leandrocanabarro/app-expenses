import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    _isInitialized = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
    return _isInitialized;
  }

  bool get isAvailable => _isInitialized && _speechToText.isAvailable;

  bool get isListening => _speechToText.isListening;

  Future<void> startListening({
    required Function(String) onResult,
    Duration? listenFor,
  }) async {
    if (!isAvailable) {
      throw Exception('Speech recognition is not available');
    }

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: listenFor ?? const Duration(seconds: 10),
      localeId: 'pt_BR',
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> cancel() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }

  List<String> get availableLocales {
    return _speechToText.locales
        .where((locale) => locale.localeId.startsWith('pt'))
        .map((locale) => locale.localeId)
        .toList();
  }
}