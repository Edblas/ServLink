import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/whatsapp_service.dart';

final whatsAppServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService();
});

