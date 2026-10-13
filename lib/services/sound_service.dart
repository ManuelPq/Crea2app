import 'package:flutter/services.dart';

/// Sonidos/hápticos del marcador. Usa las APIs nativas de la plataforma,
/// así funciona en móvil y en web sin assets de audio.
class SoundService {
  const SoundService();

  void point() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  void undo() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  void courtSwitch() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();
  }

  void setWon() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();
  }

  void matchWon() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }
}
