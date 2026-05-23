import 'package:flutter/material.dart';
import 'package:medident/core/models/contract-request-model.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-contract-provider.dart';

class AdminContractsScreen extends StatefulWidget {
  const AdminContractsScreen({super.key});

  @override
  State<AdminContractsScreen> createState() => _AdminContractsScreenState();
}

class _AdminContractsScreenState extends State<AdminContractsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminContractProvider>();
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF007AFF),
            unselectedLabelColor: const Color(0xFF86868B),
            indicatorColor: const Color(0xFF007AFF),
            tabs: [
              Tab(text: 'Pendientes (${provider.pendingRequests.length})'),
              Tab(text: 'Aprobados (${provider.approvedRequests.length})'),
              const Tab(text: 'Suscriptores'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _PendingTab(provider: provider),
              _ApprovedTab(provider: provider),
              _SubscribersTab(provider: provider),
            ],
          ),
        ),
      ],
    );
  }
}

class _PendingTab extends StatelessWidget {
  final AdminContractProvider provider;
  const _PendingTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final pending = provider.pendingRequests;
    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Color(0xFF34C759)),
            SizedBox(height: 16),
            Text('No hay solicitudes pendientes',
                style: TextStyle(fontSize: 16, color: Color(0xFF86868B))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) => _ContractCard(
        request: pending[index],
        onTap: () => _showDetail(context, pending[index]),
      ),
    );
  }

  void _showDetail(BuildContext context, ContractRequestModel request) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ContractDetailPage(request: request),
    ));
  }
}

class _ApprovedTab extends StatelessWidget {
  final AdminContractProvider provider;
  const _ApprovedTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final approved = provider.approvedRequests;
    if (approved.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF86868B)),
            SizedBox(height: 16),
            Text('No hay solicitudes aprobadas',
                style: TextStyle(fontSize: 16, color: Color(0xFF86868B))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: approved.length,
      itemBuilder: (context, index) => _ContractCard(
        request: approved[index],
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _ContractDetailPage(request: approved[index], isHistorical: true),
        )),
      ),
    );
  }
}

class _SubscribersTab extends StatefulWidget {
  final AdminContractProvider provider;
  const _SubscribersTab({required this.provider});

  @override
  State<_SubscribersTab> createState() => _SubscribersTabState();
}

class _SubscribersTabState extends State<_SubscribersTab> {
  @override
  Widget build(BuildContext context) {
    final active = widget.provider.activeSubscriptions;
    if (active.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Color(0xFF86868B)),
            SizedBox(height: 16),
            Text('No hay suscriptores activos',
                style: TextStyle(fontSize: 16, color: Color(0xFF86868B))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: active.length,
      itemBuilder: (context, index) => _SubscriberCard(
        request: active[index],
        provider: widget.provider,
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  final ContractRequestModel request;
  final VoidCallback onTap;

  const _ContractCard({required this.request, required this.onTap});

  Color _statusColor() {
    switch (request.status) {
      case ContractRequestStatus.pending_review:
        return const Color(0xFFFF9500);
      case ContractRequestStatus.approved:
        return const Color(0xFF34C759);
      case ContractRequestStatus.rejected:
        return const Color(0xFFFF3B30);
      case ContractRequestStatus.suspended:
        return const Color(0xFFFF3B30);
    }
  }

  IconData _statusIcon() {
    switch (request.status) {
      case ContractRequestStatus.pending_review:
        return Icons.hourglass_empty;
      case ContractRequestStatus.approved:
        return Icons.check_circle;
      case ContractRequestStatus.rejected:
        return Icons.cancel;
      case ContractRequestStatus.suspended:
        return Icons.pause_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_statusIcon(), color: _statusColor(), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.dentistName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.installationDateFormatted,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF86868B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContractDetailPage extends StatefulWidget {
  final ContractRequestModel request;
  final bool isHistorical;

  const _ContractDetailPage({required this.request, this.isHistorical = false});

  @override
  State<_ContractDetailPage> createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends State<_ContractDetailPage> {
  final _notesController = TextEditingController();
  bool _isProcessing = false;
  String? _actionError;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() {
      _isProcessing = true;
      _actionError = null;
    });
    try {
      await context.read<AdminContractProvider>().approveRequest(
            widget.request.id!,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contrato aprobado. Suscripción activa por 1 mes.'),
            backgroundColor: Color(0xFF34C759),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _actionError = e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    setState(() {
      _isProcessing = true;
      _actionError = null;
    });
    try {
      await context.read<AdminContractProvider>().rejectRequest(
            widget.request.id!,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contrato rechazado'),
            backgroundColor: Color(0xFFFF3B30),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _actionError = e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Scaffold(
      appBar: AppBar(
        title: Text('${r.dentistName} - ${r.status.label}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Odontólogo', r.dentistName),
            _infoRow('Email', r.dentistEmail),
            if (r.dentistPhone != null) _infoRow('Teléfono', r.dentistPhone!),
            const SizedBox(height: 16),
            _infoRow('Instalación', '${r.installationDateFormatted} a las ${r.installationTimeFormatted}'),
            const SizedBox(height: 16),
            _infoRow('Estado', r.status.label),
            if (r.reviewedBy != null) _infoRow('Revisado por', r.reviewedBy!),
            if (r.adminNotes != null && r.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _infoRow('Notas del admin', r.adminNotes!),
            ],
            if (r.subscriptionExpiresAt != null) ...[
              const SizedBox(height: 16),
              _infoRow('Suscripción hasta', _formatDate(r.subscriptionExpiresAt!)),
            ],
            const SizedBox(height: 24),
            if (!widget.isHistorical && r.status == ContractRequestStatus.pending_review) ...[
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Agregá un comentario...',
                ),
                maxLines: 3,
              ),
              if (_actionError != null) ...[
                const SizedBox(height: 8),
                Text(_actionError!, style: const TextStyle(color: Color(0xFFFF3B30))),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _approve,
                        icon: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_outline),
                        label: const Text('Aprobar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34C759),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _reject,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Rechazar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Color(0xFF86868B), fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Color(0xFF1D1D1F), fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SubscriberCard extends StatelessWidget {
  final ContractRequestModel request;
  final AdminContractProvider provider;

  const _SubscriberCard({required this.request, required this.provider});

  void _confirmDeactivate(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar suscripción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Desactivar servicio de ${request.dentistName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                border: OutlineInputBorder(),
                hintText: 'Ej: Falta de pago',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await provider.deactivateSubscription(
                request.userId,
                reason: reasonController.text.isNotEmpty ? reasonController.text : 'Falta de pago',
                notes: reasonController.text.isNotEmpty ? reasonController.text : null,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Suscripción desactivada'),
                    backgroundColor: Color(0xFFFF3B30),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
            child: const Text('Desactivar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expired = request.subscriptionExpiresAt != null &&
        request.subscriptionExpiresAt!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: expired
                    ? const Color(0xFFFF3B30).withOpacity(0.1)
                    : const Color(0xFF34C759).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                expired ? Icons.error_outline : Icons.person,
                color: expired ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.dentistName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.dentistEmail,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF86868B)),
                  ),
                  if (request.subscriptionExpiresAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Expira: ${request.installationDateFormatted}',
                      style: TextStyle(
                        fontSize: 12,
                        color: expired ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!expired)
              TextButton(
                onPressed: () => _confirmDeactivate(context),
                child: const Text('Desactivar', style: TextStyle(color: Color(0xFFFF3B30))),
              ),
          ],
        ),
      ),
    );
  }
}
