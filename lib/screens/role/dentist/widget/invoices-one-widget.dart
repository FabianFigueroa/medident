import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class Invoices_One_Widget extends StatefulWidget {
  final List<dynamic> invoices;
  final Function(dynamic)? onTap;
  final Function(String, String)? onStatusChange;
  final Function(dynamic)? onDownloadPdf;
  final bool isLoading;

  const Invoices_One_Widget({
    super.key,
    required this.invoices,
    this.onTap,
    this.onStatusChange,
    this.onDownloadPdf,
    this.isLoading = false,
  });

  @override
  State<Invoices_One_Widget> createState() => _Invoices_One_WidgetState();
}

class _Invoices_One_WidgetState extends State<Invoices_One_Widget> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredInvoices = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredInvoices = widget.invoices;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant Invoices_One_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoices != widget.invoices) {
      _filteredInvoices = _isSearching
          ? _filterInvoices(_searchController.text)
          : widget.invoices;
    }
  }

  List<dynamic> _filterInvoices(String query) {
    if (query.isEmpty) return widget.invoices;
    final q = query.toLowerCase();
    return widget.invoices.where((i) {
      final number = (i['invoiceNumber'] ?? '').toString().toLowerCase();
      final patient = (i['patientName'] ?? '').toString().toLowerCase();
      return number.contains(q) || patient.contains(q);
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _filteredInvoices = _filterInvoices(_searchController.text);
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFEA580C);
      case 'paid':
        return const Color(0xFF22C55E);
      case 'overdue':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'paid':
        return 'Pagada';
      case 'overdue':
        return 'Vencida';
      default:
        return status;
    }
  }

  Future<void> _showStatusDialog(dynamic inv) async {
    final statuses = ['pending', 'paid', 'overdue'];
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) {
            final color = _getStatusColor(s);
            return ListTile(
              leading: Icon(Icons.receipt_long, color: color, size: 18),
              title: Text(_getStatusLabel(s)),
              onTap: () => Navigator.pop(context, s),
            );
          }).toList(),
        ),
      ),
    );
    if (result != null) {
      widget.onStatusChange?.call(inv['id'] ?? '', result);
    }
  }

  Future<void> _downloadPdf(dynamic inv) async {
    if (widget.onDownloadPdf == null) return;
    widget.onDownloadPdf?.call(inv);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descargando factura...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No hay facturas',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.invoices.isEmpty && !widget.isLoading) {
      return _buildEmpty();
    }

    final pendingCount = widget.invoices.where((i) => i['status'] == 'pending').length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Facturas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (!_isSearching)
                  GestureDetector(
                    onTap: () => setState(() => _isSearching = true),
                    child: const Icon(Icons.search, size: 20, color: Color(0xFF6366F1)),
                  ),
                if (_isSearching) ...[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _isSearching = false);
                    },
                    child: const Icon(Icons.close, size: 18),
                  ),
                ] else if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$pendingCount por pagar',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFEA580C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Invoices list
            widget.isLoading
                ? _buildShimmer()
                : Column(
                    children: _filteredInvoices.take(3).map((inv) => _buildInvoiceItem(context, inv)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(BuildContext context, dynamic inv) {
    final bool isPending = inv['status'] == 'pending';
    final String invoiceNumber = inv['invoiceNumber'] ?? 'N/A';
    final String patientName = inv['patientName'] ?? 'Paciente';
    final double total = (inv['total'] ?? 0).toDouble();
    final String date = inv['date'] ?? '';

    return InkWell(
      onTap: () => widget.onTap?.call(inv),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isPending ? const Color(0xFFFFF5F5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Icono según estado
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getStatusColor(inv['status'] ?? '').withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.description,
                color: _getStatusColor(inv['status'] ?? ''),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoiceNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patientName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Total y acciones
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: isPending && widget.onStatusChange != null
                          ? () => _showStatusDialog(inv)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(inv['status'] ?? '').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusLabel(inv['status'] ?? ''),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(inv['status'] ?? ''),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _downloadPdf(inv),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.download, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(3, (index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
