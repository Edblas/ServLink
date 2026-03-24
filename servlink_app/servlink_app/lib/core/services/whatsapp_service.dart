import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  String buildProfessionalLink({
    required String telefone,
    required String categoria,
  }) {
    final digits = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final withCountry = digits.startsWith('55') ? digits : '55$digits';
    final message =
        'Olá, encontrei você no ServLink e preciso de um serviço de $categoria';
    final uri = Uri.parse(
      'https://wa.me/$withCountry?text=${Uri.encodeComponent(message)}',
    );
    return uri.toString();
  }

  String buildClienteLink({
    required String telefone,
    required String mensagem,
  }) {
    final digits = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final withCountry = digits.startsWith('55') ? digits : '55$digits';
    final uri = Uri.parse(
      'https://wa.me/$withCountry?text=${Uri.encodeComponent(mensagem)}',
    );
    return uri.toString();
  }

  Future<bool> open(String link) async {
    final uri = Uri.parse(link);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

