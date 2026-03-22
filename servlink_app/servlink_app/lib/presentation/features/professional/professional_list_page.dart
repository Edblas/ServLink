import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_providers.dart';
import 'professional_detail_page.dart';

class ProfessionalListPage extends ConsumerStatefulWidget {
  const ProfessionalListPage({super.key});

  @override
  ConsumerState<ProfessionalListPage> createState() =>
      _ProfessionalListPageState();
}

class _ProfessionalListPageState
    extends ConsumerState<ProfessionalListPage> {
  final _scrollController = ScrollController();
  final _queryController = TextEditingController();
  final _bairroController = TextEditingController();
  final List<int> _pagesLoaded = [0];
  int _currentPage = 0;
  bool _isLoadingMore = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _queryController.text = ref.read(profissionaisQueryProvider);
    _bairroController.text = ref.read(profissionaisBairroProvider);
    _queryController.addListener(_onFiltersChanged);
    _bairroController.addListener(_onFiltersChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _queryController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  void _onFiltersChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      ref.read(profissionaisQueryProvider.notifier).state = _queryController.text;
      ref.read(profissionaisBairroProvider.notifier).state =
          _bairroController.text;

      setState(() {
        _currentPage = 0;
        _pagesLoaded
          ..clear()
          ..add(0);
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
      _pagesLoaded.add(_currentPage);
    });
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cidade = ref.watch(cidadeSelecionadaProvider);
    final categoria = ref.watch(categoriaSelecionadaProvider);

    final providers = _pagesLoaded
        .map((page) => ref.watch(profissionaisProvider(page)))
        .toList();

    final items = providers
        .where((value) => value.hasValue)
        .expand((value) => value.value!)
        .toList();

    final isAnyLoading = providers.any((value) => value.isLoading);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoria != null
              ? '${categoria.nome} em ${cidade?.nome ?? ''}'
              : 'Profissionais',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _queryController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Buscar por nome ou categoria',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bairroController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    labelText: 'Bairro/Região (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final profissional = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(profissional.nome.substring(0, 1)),
                  ),
                  title: Text(profissional.nome),
                  subtitle: Text(
                    [
                      profissional.categoria,
                      profissional.cidade,
                      if (profissional.bairro != null &&
                          profissional.bairro!.trim().isNotEmpty)
                        profissional.bairro!.trim(),
                    ].join(' • '),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profissional.plano == 'DESTAQUE'
                            ? 'Destaque'
                            : 'Básico',
                        style: TextStyle(
                          color: profissional.plano == 'DESTAQUE'
                              ? Colors.orange
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(profissional.mediaAvaliacoes.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfessionalDetailPage(profissional: profissional),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (isAnyLoading || _isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
