import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientShopScreen extends StatefulWidget {
  const PatientShopScreen({super.key});

  @override
  State<PatientShopScreen> createState() => _PatientShopScreenState();
}

class _PatientShopScreenState extends State<PatientShopScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _promotions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fs = FirebaseFirestore.instance;
      final results = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
        fs.collection('products').where('isActive', isEqualTo: true).limit(20).get(),
        fs.collection('promotions').where('isActive', isEqualTo: true).limit(10).get(),
      ]);

      setState(() {
        _products = results[0].docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _promotions = results[1].docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Tienda'), backgroundColor: Colors.white, elevation: 0),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_promotions.isNotEmpty) ...[
          const Text('Promociones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _promotions.length,
              itemBuilder: (context, index) {
                final promo = _promotions[index];
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF008080), Color(0xFF20B2AA)]),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(promo['name'] ?? 'Promoción',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (promo['discountPrice'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('\$${promo['price'] ?? 0}',
                                style: const TextStyle(color: Colors.white70, decoration: TextDecoration.lineThrough, fontSize: 14)),
                            const SizedBox(width: 8),
                            Text('\$${promo['discountPrice']}',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
        const Text('Productos Dentales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_products.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No hay productos')))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return Card(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080).withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Center(child: Icon(Icons.shopping_bag, color: Color(0xFF008080), size: 48)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['name'] ?? 'Producto',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('\$${product['price'] ?? 0}',
                              style: const TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold)),
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
}
