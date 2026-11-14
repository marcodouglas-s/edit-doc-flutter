import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';

class AuthViewModel extends ChangeNotifier {
  // Instância única: todas as telas compartilham o mesmo estado
  static final AuthViewModel _instancia = AuthViewModel._interno();

  factory AuthViewModel() => _instancia;

  AuthViewModel._interno();

  final BancoLocalService _banco = BancoLocalService();
  final PreferencesService _prefs = PreferencesService();

  Usuario? _usuarioAtual;
  bool _carregando = false;
  bool _temaEscuro = false;
  String? _erro;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get carregando => _carregando;
  bool get temaEscuro => _temaEscuro;
  String? get erro => _erro;
  bool get estaLogado => _usuarioAtual != null;

  // Carrega tema e sessão salvos (chamado antes do runApp)
  Future<void> carregarPreferencias() async {
    try {
      _temaEscuro = await _prefs.carregarTema();

      final usuarioId = await _prefs.carregarSessao();

      if (usuarioId != null) {
        final usuarios = await _banco.listarUsuarios();

        for (final usuario in usuarios) {
          if (usuario.id == usuarioId) {
            _usuarioAtual = usuario;
            break;
          }
        }

        if (_usuarioAtual == null) {
          await _prefs.limparSessao();
        }
      }
    } catch (e) {
      _erro = 'Erro ao carregar preferências';
    }

    notifyListeners();
  }

  Future<void> alternarTema() async {
    _temaEscuro = !_temaEscuro;
    notifyListeners();

    await _prefs.salvarTema(_temaEscuro);
  }

  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final usuarios = await _banco.listarUsuarios();
      final emailNormalizado = email.trim().toLowerCase();

      for (final usuario in usuarios) {
        if (usuario.email == emailNormalizado &&
            usuario.senha == senha) {
          _usuarioAtual = usuario;
          await _prefs.salvarSessao(usuario.id);
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

  Future<void> logout() async {
    _usuarioAtual = null;
    await _prefs.limparSessao();
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
        (usuario) => usuario.email.toLowerCase() == emailNormalizado,
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

