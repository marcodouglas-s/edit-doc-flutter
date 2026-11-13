
class Documento {
  final String id;
  final String usuarioId;
  String titulo;
  String conteudo;
  final DateTime dataCriacao;
  DateTime dataAtualizacao;

  Documento({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.conteudo,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'titulo': titulo,
      'conteudo': conteudo,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataAtualizacao': dataAtualizacao.toIso8601String(),
    };
  }

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'],
      usuarioId: json['usuarioId'],
      titulo: json['titulo'],
      conteudo: json['conteudo'],
      dataCriacao: DateTime.parse(json['dataCriacao']),
      dataAtualizacao: DateTime.parse(json['dataAtualizacao']),
    );
  }
}
