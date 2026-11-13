
class Validadores {
  // Validar nome
  static String? validarNome(String? nome) {
    if (nome == null || nome.trim().isEmpty) {
      return 'Digite seu nome';
    }

    if (nome.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }

    return null;
  }

  // Validar e-mail
  static String? validarEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Digite seu e-mail';
    }

    final regex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!regex.hasMatch(email.trim())) {
      return 'Digite um e-mail válido';
    }

    return null;
  }

  // Validar senha
  static String? validarSenha(String? senha) {
    if (senha == null || senha.isEmpty) {
      return 'Digite sua senha';
    }

    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }
}
