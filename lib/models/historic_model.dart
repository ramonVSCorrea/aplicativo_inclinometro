class Historic {
  int id;
  DateTime dataOperacao;
  double calibracaoLateral;
  double calibracaoFrontal;
  double bloqueioLateral;
  double bloqueioFrontal;

  Historic({
    required this.id,
    required this.dataOperacao,
    required this.calibracaoLateral,
    required this.calibracaoFrontal,
    required this.bloqueioLateral,
    required this.bloqueioFrontal,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'truck_id': id,
  //     'data_operacao': dataOperacao,
  //     'calibracaolateral': calibracaoLateral,
  //     'calibracaofrontal': calibracaoFrontal,
  //     'bloqueiolateral': bloqueioLateral,
  //     'bloqueiolrontal': bloqueioFrontal,
  //   };
  // }

  // factory Historic.fromMap(Map<String, dynamic> data) {
  //   return Historic(
  //     id: data['truck_id'],
  //     dataOperacao: data['data_operacao'],
  //     calibracaoLateral: data['calibracaolateral'],
  //     calibracaoFrontal: data['calibracaofrontal'],
  //     bloqueioLateral: data['bloqueiolateral'],
  //     bloqueioFrontal: data['bloqueiolrontal'],
  //   );
  // }
}
