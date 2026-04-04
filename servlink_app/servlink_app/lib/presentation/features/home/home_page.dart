import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/categoria_entity.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../auth/login_page.dart';
import '../favorites/favorites_page.dart';
import '../profile/profile_page.dart';
import '../professional/professional_list_page.dart';
import '../vagas/vagas_page.dart';
import '../caronas/caronas_page.dart';
import '../../widgets/category_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  void _goToSearch({String? query}) {
    if (query != null) {
      ref.read(profissionaisQueryProvider.notifier).state = query.trim();
    }
    setState(() {
      _currentIndex = 1;
    });
  }

  void _selectCategoryAndSearch(CategoriaEntity categoria) {
    ref.read(categoriaSelecionadaProvider.notifier).state = categoria;
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).session;
    if (session == null) {
      return const LoginPage();
    }
    final tabs = [
      CategoriesTab(
        onSearch: _goToSearch,
        onSelectCategory: _selectCategoryAndSearch,
      ),
      const ProfessionalListPage(),
      const VagasPage(),
      const CaronasPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Vagas',
          ),
          NavigationDestination(
            icon: Icon(Icons.two_wheeler_outlined),
            selectedIcon: Icon(Icons.two_wheeler),
            label: 'Corridas',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class CategoriesTab extends ConsumerWidget {
  const CategoriesTab({
    super.key,
    required this.onSearch,
    required this.onSelectCategory,
  });

  final void Function({String? query}) onSearch;
  final void Function(CategoriaEntity categoria) onSelectCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final cidade = ref.watch(cidadeSelecionadaProvider);
    final countsAsync = ref.watch(categoriaCountsProvider);
    final brightness = Theme.of(context).brightness;

    final backgroundColor =
        brightness == Brightness.dark ? const Color(0xFF0F1115) : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: categoriasAsync.when(
          data: (categorias) {
            final featured = _featuredCategories(categorias);
            final counts = countsAsync.maybeWhen(
              data: (m) => m,
              orElse: () => const <int, int>{},
            );
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Buscar serviços...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isEmpty) return;
                            ref.read(categoriaSelecionadaProvider.notifier).state =
                                null;
                            onSearch(query: value);
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cidade != null
                              ? '📍 ${cidade.nome} e região'
                              : '📍 Alfenas e região',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '🔥 Mais procurados',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final categoria = featured[index];
                        final count = counts[categoria.id] ?? 0;
                        return SizedBox(
                          width: 230,
                          child: CategoryCard(
                            title: categoria.nome,
                            subtitle:
                                '+$count profissionais disponíveis',
                            icon: _iconFor(categoria.nome),
                            badgeText: _isAvailableNow(categoria.nome)
                                ? 'Disponível agora'
                                : null,
                            onTap: () => onSelectCategory(categoria),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '📂 Todas as categorias',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.35,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final categoria = categorias[index];
                        final count = counts[categoria.id] ?? 0;
                        return CategoryCard(
                          title: categoria.nome,
                          subtitle:
                              '+$count profissionais disponíveis',
                          icon: _iconFor(categoria.nome),
                          badgeText: _isAvailableNow(categoria.nome)
                              ? 'Disponível agora'
                              : null,
                          onTap: () => onSelectCategory(categoria),
                        );
                      },
                      childCount: categorias.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erro ao carregar categorias'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(categoriasProvider);
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<CategoriaEntity> _featuredCategories(List<CategoriaEntity> categorias) {
    final names = {'programador', 'diarista', 'eletricista'};
    final found = categorias
        .where((c) => names.contains(c.nome.trim().toLowerCase()))
        .toList();

    if (found.isNotEmpty) return found.take(3).toList();

    return categorias.take(3).toList();
  }

  bool _isAvailableNow(String categoriaNome) {
    final key = categoriaNome.trim().toLowerCase();
    return key == 'programador' ||
        key == 'manicure' ||
        key == 'diarista' ||
        key == 'eletricista';
  }

  IconData _iconFor(String categoriaNome) {
    final name = categoriaNome.toLowerCase();
    if (name.contains('program')) return Icons.code;
    if (name.contains('prof')) return Icons.school_outlined;
    if (name.contains('mani')) return Icons.brush_outlined;
    if (name.contains('cont')) return Icons.receipt_long_outlined;
    if (name.contains('cozin')) return Icons.restaurant_outlined;
    if (name.contains('dent')) return Icons.medical_services_outlined;
    if (name.contains('médic') || name.contains('medic')) {
      return Icons.local_hospital_outlined;
    }
    if (name.contains('enferm')) return Icons.health_and_safety_outlined;
    if (name.contains('bab') || name.contains('crian')) {
      return Icons.child_friendly_outlined;
    }
    if (name.contains('jard') || name.contains('plant')) {
      return Icons.yard_outlined;
    }
    if (name.contains('diar')) return Icons.cleaning_services_outlined;
    if (name.contains('eletr')) return Icons.electrical_services_outlined;
    return Icons.category_outlined;
  }
}
