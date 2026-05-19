import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Product_One_Widget extends StatefulWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onTap;
  final Function(ProductModel, int)? onAddToCart;
  final bool isLoading;

  const Product_One_Widget({
    super.key,
    required this.products,
    this.onTap,
    this.onAddToCart,
    this.isLoading = false,
  });

  @override
  State<Product_One_Widget> createState() => _Product_One_WidgetState();
}

class _Product_One_WidgetState extends State<Product_One_Widget> {
  final Map<String, int> _cartQuantities = {};

  void _addToCart(ProductModel product) {
    if (widget.onAddToCart == null) return;
    setState(() {
      _cartQuantities[product.id] = (_cartQuantities[product.id] ?? 0) + 1;
    });
    widget.onAddToCart?.call(product, _cartQuantities[product.id]!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No hay productos disponibles',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty && !widget.isLoading) {
      return _buildEmpty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Productos recomendados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: widget.isLoading
              ? _buildShimmer()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.products.length,
                  itemBuilder: (context, index) {
                    final product = widget.products[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final quantity = _cartQuantities[product.id] ?? 0;
    return GestureDetector(
      onTap: () => widget.onTap?.call(product),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SafeNetworkImage(
                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.hasDiscount)
                            Text(
                              '\$${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            product.hasDiscount
                                ? '\$${product.discountPrice!.toStringAsFixed(0)}'
                                : '\$${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: product.hasDiscount
                                  ? Colors.red
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      // Botón carrito
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: quantity > 0
                                ? const Color(0xFF1D4ED8)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: quantity > 0
                              ? Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              : const Icon(Icons.add_shopping_cart,
                                  size: 16, color: Colors.grey),
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
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
