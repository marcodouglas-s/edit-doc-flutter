
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/services/banco_local_service.dart';

class AuthViewModel extends ChangeNotifier {
  final BancoLocalService _banco = BancoLocalService();

  Usuario? _usuarioAtual;
  bool _carregando = false;
  String? _erro;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get estaLogado => _usuarioAtual != null;

  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final usuarios = await _banco.listarUsuarios();

      for (final usuario in usuarios) {
        if (usuario.email == email && usuario.senha == senha) {
          _usuarioAtual = usuario;
          return true;
        }
      }

      _erro = 'E-mail ou senha incorretos';
      return false;
    } catch (e) {
      _erro = 'Erro ao realizar login';
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void logout() {
    _usuarioAtual = null;
    notifyListeners();
  }
  
Future<bool> cadastrar(
  String nome,
  String email,
  String senha,
) async {
  _carregando = true;
  _erro = null;
  notifyListeners();

  try {
    final usuarios = await _banco.listarUsuarios();

    final emailNormalizado = email.trim().toLowerCase();

    final emailExiste = usuarios.any(
      (usuario) =>
          usuario.email.toLowerCase() == emailNormalizado,
    );

    if (emailExiste) {
      _erro = 'Este e-mail já está cadastrado';
      return false;
    }

    final novoUsuario = Usuario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nome: nome.trim(),
      email: emailNormalizado,
      senha: senha,
    );

    usuarios.add(novoUsuario);

    await _banco.salvarUsuarios(usuarios);

    _usuarioAtual = novoUsuario;
    return true;
  } catch (e) {
    _erro = 'Erro ao cadastrar usuário';
    return false;
  } finally {
    _carregando = false;
    notifyListeners();
  }
}

}
