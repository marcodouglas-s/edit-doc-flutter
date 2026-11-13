
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _chaveTema = 'tema_escuro';

  Future<void> salvarTema(bool temaEscuro) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_chaveTema, temaEscuro);
  }

  Future<bool> carregarTema() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_chaveTema) ?? false;
  }
}
