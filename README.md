# Edit Doc

Aplicativo de edição de documentos feito em Flutter para a disciplina de desenvolvimento mobile. O usuário cria uma conta, entra e consegue criar, editar e excluir seus próprios documentos. O projeto segue a arquitetura MVVM.

Demo online: https://marcodouglas-s.github.io/edit-doc-flutter/

## Funcionalidades

- Cadastro e login, com validação de nome, e-mail e senha
- Criar, listar, editar e excluir documentos
- Cada usuário vê apenas os próprios documentos
- Tema claro e escuro
- Os dados, a sessão e o tema continuam salvos ao recarregar a página

Os dados ficam guardados no navegador (`shared_preferences`), então em outro navegador ou em aba anônima o app começa vazio e é preciso criar uma conta de novo.

## Estrutura do projeto

```
lib/
├── main.dart
├── models/
│   ├── usuario.dart
│   ├── documento.dart
│   └── services/
│       ├── banco_local_service.dart
│       ├── documento_storage_service.dart
│       └── preferences_service.dart
├── viewmodels/
│   ├── auth_viewmodel.dart
│   └── documentos_viewmodel.dart
├── views/
│   ├── login_view.dart
│   ├── cadastro_view.dart
│   ├── home_view.dart
│   └── editor_view.dart
└── utils/
    └── validadores.dart
```

- **models**: classes `Usuario` e `Documento` e os services que gravam os dados
- **viewmodels**: estado das telas e regras de negócio, usando `ChangeNotifier`
- **views**: só a interface; elas escutam o ViewModel com `ListenableBuilder`
- **utils**: validações dos formulários

O relatório da migração para MVVM está no arquivo [ARQUITETURA.md](ARQUITETURA.md).

## Persistência

Como o app roda na web, não dá para usar SQLite. Tudo é salvo com `shared_preferences`:

- `BancoLocalService`: lista de usuários
- `DocumentoStorageService`: CRUD dos documentos, convertendo a lista para JSON com `jsonEncode` e `jsonDecode`
- `PreferencesService`: tema escolhido e usuário logado

## Como rodar

Precisa ter o [Flutter](https://docs.flutter.dev/get-started/install) instalado.

```bash
git clone https://github.com/marcodouglas-s/edit-doc-flutter.git
cd edit-doc-flutter
flutter pub get
flutter run -d chrome
```

No GitHub Codespaces o ambiente já vem configurado pelo devcontainer. Para rodar:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Depois é só abrir a porta 8080 na aba Portas. O atalho F5 também funciona, por causa do `.vscode/launch.json`.

## Deploy

A cada push na branch `main`, o workflow `.github/workflows/deploy.yml` compila o app com `flutter build web --release` e publica no GitHub Pages.

## Observações

Projeto feito para fins didáticos. As senhas são salvas em texto puro no armazenamento do navegador, o que não serve para um app de verdade. Em produção seria necessário usar hash de senha e um servidor para autenticação.

Autor: Marco Douglas
