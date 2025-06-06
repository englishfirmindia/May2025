import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech;

  SpeechService() : _speech = stt.SpeechToText();

  Future<bool> initialize() async {
    try {
      return await _speech.initialize(
        onStatus: (val) => print('SpeechService: onStatus: $val'),
        onError: (val) => print('SpeechService: onError: $val'),
      );
    } catch (e) {
      print('SpeechService: Error initializing speech: $e');
      Fluttertoast.showToast(msg: "Failed to initialize speech recognition");
      return false;
    }
  }

  Future<void> startListening({
    required String localeId,
    required Function(String) onResult,
    required Function onFinalResult,
  }) async {
    if (!_speech.isAvailable) {
      Fluttertoast.showToast(msg: "Speech recognition not available");
      return;
    }

    await _speech.listen(
      localeId: localeId,
      onResult: (val) {
        onResult(val.recognizedWords);
        if (val.finalResult) {
          onFinalResult();
        }
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}