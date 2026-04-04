class LoginRequestModel {
  LoginRequestModel({
    required this.email,
    required this.senha,
  });

  final String email;
  final String senha;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'senha': senha,
    };
  }
}

class RegisterRequestModel {
  RegisterRequestModel({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.senha,
    required this.role,
    this.cnpj,
    this.endereco,
    this.cep,
    this.numero,
    this.complemento,
  });

  final String nome;
  final String email;
  final String telefone;
  final String senha;
  final String role;
  final String? cnpj;
  final String? endereco;
  final String? cep;
  final String? numero;
  final String? complemento;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'senha': senha,
      'role': role,
    };
    if (cnpj != null) json['cnpj'] = cnpj;
    if (endereco != null) json['endereco'] = endereco;
    if (cep != null) json['cep'] = cep;
    if (numero != null) json['numero'] = numero;
    if (complemento != null) json['complemento'] = complemento;
    return json;
  }
}

class ForgotPasswordRequestModel {
  ForgotPasswordRequestModel({required this.email});

  final String email;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequestModel {
  ResetPasswordRequestModel({
    required this.token,
    required this.novaSenha,
  });

  final String token;
  final String novaSenha;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'novaSenha': novaSenha,
    };
  }
}

class AuthMeResponseModel {
  AuthMeResponseModel({
    required this.nome,
    required this.email,
    required this.role,
  });

  final String nome;
  final String email;
  final String role;

  factory AuthMeResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthMeResponseModel(
      nome: json['nome'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

class LoginResponseModel {
  LoginResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.nome,
    required this.email,
    required this.role,
  });

  final String accessToken;
  final String tokenType;
  final String nome;
  final String email;
  final String role;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
