/// Orders screen — paginated list of past/active orders.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_providers.dart';
import '../widgets/order_tile.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(orderControllerProvider);
    final ongoing = ref.watch(ongoingOrdersProvider);
    final completed = ref.watch(completedOrdersProvider);
    final cancelled = ref.watch(cancelledOrdersProvider);
    final activeOrders = ref.watch(activeOrdersProvider);
    final pastOrders = ref.watch(pastOrdersProvider);

    final tabOrders = [allOrders, ongoing, completed, cancelled];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (tabIndex) {
          final orders = tabOrders[tabIndex];
          if (orders.isEmpty) {
            return _EmptyOrders(message: _emptyMessage(tabIndex));
          }

          // Build grouped list for "All" tab, flat list for others
          if (tabIndex == 0) {
            return _GroupedOrderList(
              activeOrders: activeOrders,
              pastOrders: pastOrders,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 100),
            itemCount: orders.length,
            itemBuilder: (_, i) => OrderTile(order: orders[i]),
          );
        }),
      ),
    );
  }

  String _emptyMessage(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'No ongoing orders';
      case 2:
        return 'No completed orders yet';
      case 3:
        return 'No cancelled orders';
      default:
        return 'No orders yet';
    }
  }
}

// ── Grouped list widget (All tab) ────────────────────────────────────────────────

class _GroupedOrderList extends StatelessWidget {
  const _GroupedOrderList({
    required this.activeOrders,
    required this.pastOrders,
  });

  final List<OrderEntity> activeOrders;
  final List<OrderEntity> pastOrders;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 100),
      children: [
        if (activeOrders.isNotEmpty) ...[
          _SectionHeader(title: 'ACTIVE ORDERS'),
          ...activeOrders.map((o) => OrderTile(order: o)),
          const SizedBox(height: 8),
        ],
        if (pastOrders.isNotEmpty) ...[
          _SectionHeader(title: 'PAST ORDERS'),
          ...pastOrders.map((o) => OrderTile(order: o)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your orders will appear here',
            style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
