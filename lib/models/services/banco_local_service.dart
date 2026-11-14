import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../usuario.dart';

class BancoLocalService {
  static const String _chaveUsuarios = 'usuarios';

  // Salvar lista de usuários
  Future<void> salvarUsuarios(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = usuarios.map((u) => u.toJson()).toList();

    await prefs.setString(_chaveUsuarios, jsonEncode(dados));
  }

  // Recuperar lista de usuários
  Future<List<Usuario>> listarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_chaveUsuarios);

    if (dados == null) return [];

    final lista = jsonDecode(dados) as List<dynamic>;

    return lista
        .map((item) => Usuario.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }
}