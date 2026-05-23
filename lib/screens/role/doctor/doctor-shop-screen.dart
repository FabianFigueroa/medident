import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/core/providers/doctor/doctor-main-provider.dart';
import 'package:medident/core/providers/doctor/doctor-shop-provider.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorShopScreen extends StatefulWidget {
  const DoctorShopScreen({super.key});

  @override
  State<DoctorShopScreen> createState() => _DoctorShopScreenState();
}

class _DoctorShopScreenState extends State<DoctorShopScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DoctorMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DoctorMainProvider>().initializeSection('shop');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DoctorMainProvider, bool>(
      selector: (_, p) => p.isSectionLoading('shop'),
      builder: (context, isLoading, _) {
        if (isLoading) {
          return Scaffold(
            body: _buildShimmer(),
          );
        }

        final mainProvider = context.watch<DoctorMainProvider>();
        final error = mainProvider.getSectionError('shop');

        if (error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar tienda: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mainProvider.initializeSection('shop'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final shopProvider = mainProvider.shopProvider;

        if (shopProvider == null) {
          return Scaffold(
            body: _buildShimmer(),
          );
        }

        return ChangeNotifierProvider.value(
          value: shopProvider,
          child: ResponsiveUtils(
            mobile: const _DoctorShopBody(),
            tablet: const _DoctorShopBody(),
            desktop: const _DoctorShopBody(),
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 24),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

class _DoctorShopBody extends StatelessWidget {
  const _DoctorShopBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoctorShopProvider>();
    final products = provider.products;
    final promotions = provider.promotions;
    final isLoading = provider.isLoading;
    final error = provider.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tienda Médica'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final p = context.read<DoctorShopProvider>();
          await Future.wait([
            p.loadProducts(),
            p.loadPromotions(),
          ]);
        },
        child: isLoading
            ? _buildShimmerContent()
            : error != null
                ? _buildError(error, context)
                : _buildContent(products, promotions),
      ),
    );
  }

  Widget _buildContent(
      List<Map<String, dynamic>> products,
      List<Map<String, dynamic>> promotions) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAdminPromotions(),
        const SizedBox(height: 16),
        if (promotions.isNotEmpty) ...[
          const Text('Promociones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promo = promotions[index];
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(promo['name'] ?? 'Promoción',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if (promo['discountPrice'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('\$${promo['price'] ?? 0}',
                                style: const TextStyle(
                                    color: Colors.white70,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 14)),
                            const SizedBox(width: 8),
                            Text('\$${promo['discountPrice']}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        const Text('Productos Médicos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (products.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No hay productos disponibles'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                        ),
                        child: const Center(
                          child: Icon(Icons.medical_services,
                              color: Color(0xFF1565C0), size: 48),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['name'] ?? 'Producto',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('\$${product['price'] ?? 0}',
                              style: const TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAdminPromotions() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('promotions')
          .where('scope', isEqualTo: 'global')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final promos = snapshot.data!.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return ProductModel.fromJson(data, d.id);
        }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Promociones Globales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: promos.length,
                itemBuilder: (context, index) {
                  final promo = promos[index];
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(promo.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (promo.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(promo.description,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 24),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error, BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final p = context.read<DoctorShopProvider>();
              Future.wait([
                p.loadProducts(),
                p.loadPromotions(),
              ]);
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
