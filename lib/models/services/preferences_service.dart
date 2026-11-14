import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _chaveTema = 'tema_escuro';
  static const String _chaveSessao = 'usuario_logado_id';

  // Tema
  Future<void> salvarTema(bool temaEscuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveTema, temaEscuro);
  }

  Future<bool> carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveTema) ?? false;
  }

  // Sessão do usuário
  Future<void> salvarSessao(String usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveSessao, usuarioId);
  }

  Future<String?> carregarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveSessao);
  }

  Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
  }
}