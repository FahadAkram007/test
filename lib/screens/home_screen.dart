import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/voucher_model.dart';
import '../theme/app_theme.dart';
import '../widgets/color_scheme_preview_card.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/voucher_card.dart';
import 'partners_screen.dart';
import 'redeem_screen.dart';

/// Main screen showcasing the corporate voucher app, rotating QR redemption,
/// and partner merchant locations.
class HomeScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HomeScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Food & Dining',
    'Fitness',
    'Transportation',
    'Education',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VoucherModel> get _filteredVouchers {
    return VoucherModel.sampleVouchers.where((v) {
      final matchesCategory =
          _selectedCategory == 'All' || v.category == _selectedCategory;
      final query = _searchController.text.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          v.title.toLowerCase().contains(query) ||
          v.merchant.toLowerCase().contains(query) ||
          v.code.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get _totalBalance {
    return VoucherModel.sampleVouchers.fold(0.0, (acc, v) => acc + v.balance);
  }

  void _showRedeemDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        title: Row(
          children: [
            Icon(Icons.add_card_rounded, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            const Text('Add Voucher Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter company benefit code to add to balance:'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              decoration: const InputDecoration(
                hintText: 'e.g. CORP-PERK-2026',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voucher successfully added to your balance!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Add Now'),
          ),
        ],
      ),
    );
  }

  void _openRedeemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RedeemScreen(availableBalance: _totalBalance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: switch (_currentTabIndex) {
        1 => RedeemScreen(availableBalance: _totalBalance),
        2 => const PartnersScreen(),
        _ => _buildBenefitsTab(theme, cs, isDark),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentTabIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wallet_giftcard_outlined),
            selectedIcon: Icon(Icons.wallet_giftcard_rounded),
            label: 'Benefits',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_rounded),
            selectedIcon: Icon(Icons.qr_code_2_rounded),
            label: 'Pay / QR',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Partners',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsTab(ThemeData theme, ColorScheme cs, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: AppRadius.xsRadius,
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                color: cs.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PerkFlow',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Enterprise Benefits',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Mode Live Selector
          PopupMenuButton<ThemeMode>(
            initialValue: widget.currentThemeMode,
            tooltip: 'Switch Theme Mode',
            icon: Icon(
              widget.currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : widget.currentThemeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded,
              color: cs.onSurface,
            ),
            onSelected: widget.onThemeModeChanged,
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.brightness_auto_rounded, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text('System Default'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode_rounded, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text('Light Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_rounded, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text('Dark Mode'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: cs.primaryContainer,
              child: Text(
                'FA',
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Visually Prominent Hero Voucher / Balance Card
                  HeroBalanceCard(
                    totalBalance: _totalBalance,
                    activeVouchersCount: VoucherModel.sampleVouchers.length,
                    onScanTap: _openRedeemScreen,
                    onTopUpTap: _showRedeemDialog,
                    onHistoryTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing Transaction History'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 2. Quick Jump Card to Nearby Partners
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentTabIndex = 2; // Jump to Partners tab
                      });
                    },
                    borderRadius: AppRadius.mdRadius,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: AppRadius.mdRadius,
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.near_me_rounded, color: cs.primary, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Find Nearby Partner Merchants',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Browse dining, gyms & transit with live distance radius',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 3. Color Palette & Token Preview Card
                  const ColorSchemePreviewCard()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: AppSpacing.md),

                  // 4. Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search vouchers, merchants or perks...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 5. Horizontal Category Chips (8pt grid)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isSelected = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                          labelStyle: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? cs.onPrimary : cs.onSurface,
                          ),
                          selectedColor: cs.primary,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.fullRadius),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 6. Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Benefit Vouchers',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_filteredVouchers.length} available',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),
          ),

          // 7. Voucher Cards List
          if (_filteredVouchers.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: cs.outline),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'No vouchers found',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Try searching for another term or category.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final voucher = _filteredVouchers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: VoucherCard(
                        voucher: voucher,
                        index: index,
                        onTap: () {
                          // Tapping voucher can also directly open QR redeem screen
                          _openRedeemScreen();
                        },
                      ),
                    );
                  },
                  childCount: _filteredVouchers.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }
}
