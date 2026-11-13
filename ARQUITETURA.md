# Relatório de Migração Arquitetural: Edit Doc (Flutter)

Migração do código único do DartPad (Login, Cadastro e Home/Lista) para a arquitetura **MVVM** (Model-View-ViewModel), executando no GitHub Codespaces com Flutter Web.

## Estrutura final

```
lib/
├── main.dart
├── models/
│   ├── usuario.dart
│   ├── documento.dart
│   └── services/
│       ├── banco_local_service.dart
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

---

## 1. Mapeamento de Classes e Widgets

| Elemento (DartPad) | Tipo | Novo local | Camada |
|---|---|---|---|
| `Usuario` (id, nome, e-mail, senha) | Modelo | `lib/models/usuario.dart` | Model |
| `Documento` (id, título, conteúdo, datas) | Modelo | `lib/models/documento.dart` | Model |
| Leitura e gravação de usuários e documentos | Acesso a dados | `lib/models/services/banco_local_service.dart` | Model (service) |
| Lógica de login, cadastro e usuário logado | Regra de negócio / estado | `lib/viewmodels/auth_viewmodel.dart` (`AuthViewModel`) | ViewModel |
| Lista de documentos, carregamento e exclusão | Regra de negócio / estado | `lib/viewmodels/documentos_viewmodel.dart` (`DocumentosViewModel`) | ViewModel |
| Tela de Login (`LoginView`) | Widget | `lib/views/login_view.dart` | View |
| Tela de Cadastro (`CadastroView`) | Widget | `lib/views/cadastro_view.dart` | View |
| Tela Home / Lista (`HomeView`) | Widget | `lib/views/home_view.dart` | View |
| Validação de nome, e-mail e senha | Funções auxiliares | `lib/utils/validadores.dart` (`Validadores`) | Utils |
| `main()`, `MeuApp`, `MaterialApp`, tema e rotas | Ponto de entrada | `lib/main.dart` | Raiz |

`editor_view.dart` e `preferences_service.dart` já existem na estrutura, mas serão implementados na Etapa 5 (CRUD e persistência).

---

## 2. Alterações de Estrutura e Imports

**Divisão em arquivos e imports.** Cada classe foi para seu próprio arquivo, e cada arquivo passou a declarar o que usa. As views importam apenas ViewModels e `Validadores`, nunca o service diretamente. Os ViewModels importam models e services. Os imports são relativos (`../viewmodels/...`, `../utils/...`). O `main.dart` importa as quatro views para registrar as rotas.

**Construtores.** Os widgets ganharam construtores `const` com `super.key` (ex.: `const LoginView({super.key})`), o que permite usar `const LoginView()` nas rotas. Os modelos usam construtores com parâmetros nomeados `required`.

**Visibilidade de atributos.** Os campos de estado dos ViewModels viraram privados (`_usuarioAtual`, `_carregando`, `_erro`, `_documentos`) e são expostos por *getters* públicos. A lista de documentos é entregue com `List.unmodifiable`, para que a View não a altere sem passar pelo ViewModel. Os métodos auxiliares de validação são `static`, então são chamados sem instanciar a classe (`Validadores.validarEmail`).

**Serialização.** Os modelos receberam `toJson()` e `factory fromJson()`, preparando o armazenamento em JSON.

**Rotas nomeadas.** A navegação foi centralizada no `MaterialApp`:

| Rota | View |
|---|---|
| `/` (`initialRoute`) | `LoginView` |
| `/cadastro` | `CadastroView` |
| `/home` | `HomeView` |
| `/editor` | `EditorView` |

Como as telas não compartilham mais variáveis de um arquivo único, o `id` do usuário logado é passado entre rotas via `arguments` (`Navigator.pushReplacementNamed(context, '/home', arguments: usuarioId)`). A `HomeView` o lê com `ModalRoute.of(context)?.settings.arguments` dentro de `didChangeDependencies`.

**Ciclo de vida.** Foram adicionados `dispose()` para liberar `TextEditingController`s e ViewModels, e a verificação `if (!mounted) return;` antes de usar o `context` depois de operações assíncronas (`await`).

---

## 3. Mudanças no Gerenciamento de Estado

**`setState()` removidos das views.** Os estados que antes eram alterados com `setState()` dentro das telas foram transferidos para os ViewModels: indicador de carregamento, mensagem de erro, usuário autenticado e lista de documentos. As views não calculam mais nada disso.

**Onde cada estado vive agora:**

| ViewModel | Variáveis de estado | Operações |
|---|---|---|
| `AuthViewModel` | `_usuarioAtual`, `_carregando`, `_erro` | `login`, `cadastrar`, `logout` |
| `DocumentosViewModel` | `_documentos`, `_carregando`, `_erro` | `carregarDocumentos`, `criarDocumento`, `atualizarDocumento`, `excluirDocumento` |

As views mantêm apenas estado de interface: `GlobalKey<FormState>`, `TextEditingController`s e o `_usuarioId` recebido pela rota. Nenhum deles exige redesenhar a tela.

**Como as telas reagem às mudanças.** Os dois ViewModels estendem `ChangeNotifier`. Cada operação segue o padrão:

1. `_carregando = true; _erro = null; notifyListeners();`: a tela mostra o indicador.
2. Executa a operação (service).
3. No `finally`: `_carregando = false; notifyListeners();`: a tela atualiza com o resultado.

As views escutam o ViewModel com `ListenableBuilder(listenable: viewModel, builder: ...)`, que reconstrói apenas o trecho da interface afetado. Exemplos:

- **Login e Cadastro:** o botão é desabilitado e exibe `CircularProgressIndicator` enquanto `carregando` é `true`; erros chegam por `_auth.erro` e aparecem em um `SnackBar`.
- **Home:** o `ListenableBuilder` decide entre indicador de carregamento, mensagem de erro, mensagem de lista vazia ou a `ListView` de documentos, conforme o estado do `DocumentosViewModel`. Excluir um documento chama o ViewModel, que recarrega a lista e notifica a tela.

**Resultado.** As views ficaram responsáveis apenas pela interface, e as regras de negócio e o estado ficaram nos ViewModels, o que facilita testes e a implementação do CRUD e da persistência na Etapa 5.