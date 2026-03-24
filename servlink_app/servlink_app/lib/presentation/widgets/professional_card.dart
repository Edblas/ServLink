import 'package:flutter/material.dart';
import '../../domain/entities/profissional_entity.dart';

class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({
    super.key,
    required this.profissional,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.onWhatsApp,
  });

  final ProfissionalEntity profissional;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(profissional.nome.substring(0, 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profissional.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                        if (onWhatsApp != null)
                          IconButton(
                            onPressed: onWhatsApp,
                            icon: Icon(
                              Icons.chat,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      [
                        profissional.categoria,
                        if (profissional.bairro != null &&
                            profissional.bairro!.trim().isNotEmpty)
                          profissional.bairro!.trim(),
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(profissional.mediaAvaliacoes.toStringAsFixed(1)),
                        const SizedBox(width: 10),
                        Text(
                          profissional.plano == 'DESTAQUE' ? 'Destaque' : 'Básico',
                          style: TextStyle(
                            color: profissional.plano == 'DESTAQUE'
                                ? Colors.orange
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
