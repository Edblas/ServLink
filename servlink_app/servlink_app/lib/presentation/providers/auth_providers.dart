import 'dart:io';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return DioClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(dioClientProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepositoryImpl(AuthRemoteDataSource(client), storage, client);
});

class AuthState {
  AuthState({
    this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthSession? session;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthSession? session,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(AuthState());

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    if (state.session != null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final session = await _repository.restoreSession();
      state = state.copyWith(session: session, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String email, String senha) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      AuthSession session;
      try {
        session = await _repository
            .login(email: email, senha: senha)
            .timeout(const Duration(seconds: 60));
      } on TimeoutException {
        session = await _repository
            .login(email: email, senha: senha)
            .timeout(const Duration(seconds: 60));
      }
      state = state.copyWith(session: session, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e, defaultMessage: 'Falha ao autenticar'),
      );
    }
  }

  Future<void> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String role,
    String? cnpj,
    String? endereco,
    String? cep,
    String? numero,
    String? complemento,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      AuthSession session;
      try {
        session = await _repository
            .register(
              nome: nome,
              email: email,
              telefone: telefone,
              senha: senha,
              role: role,
              cnpj: cnpj,
              endereco: endereco,
              cep: cep,
              numero: numero,
              complemento: complemento,
            )
            .timeout(const Duration(seconds: 60));
      } on TimeoutException {
        session = await _repository
            .register(
              nome: nome,
              email: email,
              telefone: telefone,
              senha: senha,
              role: role,
              cnpj: cnpj,
              endereco: endereco,
              cep: cep,
              numero: numero,
              complemento: complemento,
            )
            .timeout(const Duration(seconds: 60));
      }
      state = state.copyWith(session: session, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e, defaultMessage: 'Falha ao registrar'),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }

  void updateSession({String? nome, String? email, String? role}) {
    final current = state.session;
    if (current == null) return;
    state = state.copyWith(
      session: AuthSession(
        accessToken: current.accessToken,
        userId: current.userId,
        nome: nome ?? current.nome,
        email: email ?? current.email,
        role: role ?? current.role,
      ),
    );
  }
}

String _mapAuthError(Object error, {required String defaultMessage}) {
  if (error is TimeoutException) {
    return 'Servidor demorou para responder. Tente novamente.';
  }
  if (error is DioException) {
    final baseUrl = error.requestOptions.baseUrl;
    final status = error.response?.statusCode;
    if (error.error is SocketException) {
      if (baseUrl.trim().isEmpty) {
        return 'Sem conexão com o servidor. Verifique sua internet.';
      }
      return 'Sem conexão com o servidor ($baseUrl). Verifique sua internet.';
    }
    if (status == 401 || status == 403) {
      return 'Email ou senha inválidos';
    }

    if (error.type == DioExceptionType.badCertificate ||
        error.error is HandshakeException ||
        (error.error?.toString().toLowerCase().contains('certificate') ??
            false)) {
      if (baseUrl.trim().isNotEmpty) {
        return 'Falha HTTPS (certificado) em $baseUrl';
      }
      return 'Falha HTTPS (certificado)';
    }

    if (status != null && status >= 400 && status < 500) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
        final errorText = data['error'];
        if (errorText is String && errorText.trim().isNotEmpty) {
          return errorText.trim();
        }
      }
      return '$defaultMessage (HTTP $status)';
    }

    if (status != null && status >= 500) {
      return 'Servidor indisponível (HTTP $status). Tente novamente.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      if (baseUrl.trim().isEmpty) {
        return 'Sem conexão com o servidor. Verifique sua internet.';
      }
      return 'Sem conexão com o servidor ($baseUrl). Verifique sua internet.';
    }

    if (baseUrl.trim().isNotEmpty) {
      if (status != null) {
        return '$defaultMessage (HTTP $status, $baseUrl)';
      }
      return '$defaultMessage ($baseUrl)';
    }
  }
  return defaultMessage;
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthController(repository);
});
