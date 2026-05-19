import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/screens/widgets/new-post/create_newposts_widget.dart';

class AdminHomeDesktop extends StatelessWidget {
  const AdminHomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    const summaryCards = [
      _SummaryCardData(
        title: 'Usuarios activos',
        value: '12,480',
        delta: '+18%',
        detail: '842 nuevos esta semana',
        icon: Icons.verified_user_outlined,
        accent: Color(0xFF3A7AFE),
      ),
      _SummaryCardData(
        title: 'Posts revisados',
        value: '1,284',
        delta: '+9%',
        detail: '36 pendientes de moderacion',
        icon: Icons.library_books_outlined,
        accent: Color(0xFF111827),
      ),
      _SummaryCardData(
        title: 'Reportes abiertos',
        value: '27',
        delta: '-11%',
        detail: '4 requieren accion inmediata',
        icon: Icons.flag_outlined,
        accent: Color(0xFFFF7A59),
      ),
      _SummaryCardData(
        title: 'Ingresos del mes',
        value: '\$48.2K',
        delta: '+22%',
        detail: 'Meta mensual al 78%',
        icon: Icons.insights_outlined,
        accent: Color(0xFF0EA5A4),
      ),
    ];

    const moderationItems = [
      _ModerationItemData(
        title: 'Post reportado por informacion sensible',
        subtitle: 'Publicado hace 14 min por @clinica_norte',
        severity: 'Alta',
        status: 'Revisar ahora',
        icon: Icons.report_gmailerrorred_outlined,
      ),
      _ModerationItemData(
        title: 'Cuenta con picos anormales de publicaciones',
        subtitle: 'Actividad detectada en 3 ciudades en menos de 1 hora',
        severity: 'Media',
        status: 'Ver actividad',
        icon: Icons.person_search_outlined,
      ),
      _ModerationItemData(
        title: 'Comentario ofensivo marcado por la comunidad',
        subtitle: '7 usuarios lo reportaron en la ultima hora',
        severity: 'Baja',
        status: 'Enviar a cola',
        icon: Icons.mode_comment_outlined,
      ),
    ];

    const activityFeed = [
      _FeedItemData(
        title: 'Se elimino un post por duplicidad',
        subtitle: 'Moderacion automatica completada en 23 segundos',
        time: 'Hace 5 min',
      ),
      _FeedItemData(
        title: 'Nuevo admin secundario invitado',
        subtitle: 'Invitacion enviada a control@ipsmedident.com.co',
        time: 'Hace 18 min',
      ),
      _FeedItemData(
        title: 'Pico de trafico en modulo de reels',
        subtitle: 'Aumento del 34% frente al promedio diario',
        time: 'Hace 39 min',
      ),
      _FeedItemData(
        title: 'Backup de contenido finalizado',
        subtitle: 'Sin errores en almacenamiento ni en indices',
        time: 'Hace 1 h',
      ),
    ];

    const pendingApprovals = [
      _ApprovalItemData(
        name: 'Clinica Dental Aurora',
        category: 'Verificacion empresarial',
        meta: '3 documentos pendientes',
        status: 'Pendiente',
      ),
      _ApprovalItemData(
        name: 'Dra. Andrea Ruiz',
        category: 'Cambio de role a doctor',
        meta: 'Solicitud enviada hoy',
        status: 'En validacion',
      ),
      _ApprovalItemData(
        name: 'Laboratorio Sonrisa',
        category: 'Apertura de cuenta comercial',
        meta: 'Requiere revisar NIT',
        status: 'Pendiente',
      ),
    ];

    const watchlist = [
      _WatchlistItemData(
        name: '@medilive_col',
        detail: 'Aumento de reportes por spam visual',
        status: 'En observacion',
      ),
      _WatchlistItemData(
        name: '@ortho_plus',
        detail: 'Solicito verificacion avanzada',
        status: 'Pendiente',
      ),
      _WatchlistItemData(
        name: '@doctorxpress',
        detail: 'Cambio brusco en frecuencia de posts',
        status: 'Revisar',
      ),
    ];

    const alerts = [
      _MiniAlertData(
        title: '3 cuentas requieren auditoria',
        subtitle: 'Cruce de actividad sospechosa en roles internos',
      ),
      _MiniAlertData(
        title: 'Storage con una alerta leve',
        subtitle: 'Tiempo de respuesta por encima del umbral esperado',
      ),
      _MiniAlertData(
        title: '8 posts esperan decision manual',
        subtitle: 'La IA no encontro suficiente confianza para moderar',
      ),
    ];

    const governanceItems = [
      _GovernanceItemData(
        title: 'Politicas de contenido',
        detail: '12 reglas activas y 2 pendientes de revision legal',
        status: 'Estable',
      ),
      _GovernanceItemData(
        title: 'Revision de verificaciones',
        detail: '18 solicitudes premium esperan aprobacion manual',
        status: 'Pendiente',
      ),
      _GovernanceItemData(
        title: 'Auditoria interna',
        detail: 'Ultimo cierre completado sin hallazgos criticos',
        status: 'Completada',
      ),
    ];

    const regionalStats = [
      _RegionStatData(region: 'Bogota', value: '38%', trend: '+6%'),
      _RegionStatData(region: 'Medellin', value: '24%', trend: '+3%'),
      _RegionStatData(region: 'Cali', value: '16%', trend: '-2%'),
      _RegionStatData(region: 'Barranquilla', value: '11%', trend: '+4%'),
    ];

    const agendaItems = [
      _AgendaItemData(
        hour: '09:00',
        title: 'Revision de casos criticos',
        detail: 'Prioridad alta en moderacion manual',
      ),
      _AgendaItemData(
        hour: '11:30',
        title: 'Comite de seguridad',
        detail: 'Validar politicas y bloqueos del dia',
      ),
      _AgendaItemData(
        hour: '16:00',
        title: 'Cierre operativo',
        detail: 'Exportar reporte global para direccion',
      ),
    ];

    return ScreenTrace(
      tag: 'ADMIN_HOME_DESKTOP',
      role: 'admin',
      message: 'Dashboard desktop de admin cargado. Mostrando control operativo, moderacion y metricas globales.',
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F6F8),
              Color(0xFFEEF1F4),
              Color(0xFFF8F9FB),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          const _AdminIdentityRail(),
                          const SizedBox(height: 16),
                          const _QuickSnapshotPanel(),
                          const SizedBox(height: 16),
                          _QuickActionsPanel(
                            actions: const [
                              _QuickActionData(
                                title: 'Suspender cuenta',
                                subtitle: 'Bloqueo temporal por incumplimiento',
                                icon: Icons.person_off_outlined,
                              ),
                              _QuickActionData(
                                title: 'Ocultar post',
                                subtitle: 'Retiro inmediato mientras se revisa',
                                icon: Icons.visibility_off_outlined,
                              ),
                              _QuickActionData(
                                title: 'Exportar reporte',
                                subtitle: 'Descarga PDF de moderacion y uso',
                                icon: Icons.file_download_outlined,
                              ),
                              _QuickActionData(
                                title: 'Crear anuncio',
                                subtitle: 'Mensaje interno para todos los roles',
                                icon: Icons.campaign_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _WatchlistPanel(items: watchlist),
                          const SizedBox(height: 16),
                          _RegionalPulsePanel(items: regionalStats),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _AdminHeroPanel(),
                          const SizedBox(height: 20),
                          _buildCreatePost(context),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: summaryCards
                                .map((item) => _SummaryCard(data: item))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          const _PerformancePanel(),
                          const SizedBox(height: 20),
                          _ModerationQueuePanel(items: moderationItems),
                          const SizedBox(height: 20),
                          _ApprovalsPanel(items: pendingApprovals),
                          const SizedBox(height: 20),
                          _GovernancePanel(items: governanceItems),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _SystemHealthPanel(activityFeed: activityFeed),
                          const SizedBox(height: 16),
                          const _NotificationPulsePanel(),
                          const SizedBox(height: 16),
                          _EscalationAlertsPanel(items: alerts),
                          const SizedBox(height: 16),
                          const _TeamInsightsPanel(),
                          const SizedBox(height: 16),
                          _AgendaPanel(items: agendaItems),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePost(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    return Create_Newposts_Widget(
      userId: user?.uid ?? '',
      userName: user?.fullName ?? 'Admin',
      userPhoto: user?.imageUrl ?? '',
      promoScope: 'global',
    );
  }
}

class _AdminHeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF4F7FB),
          ],
        ),
        border: Border.all(color: const Color(0xFFE4E8EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Centro de control admin',
                    style: TextStyle(
                      color: Color(0xFF2E5BFF),
                      fontFamily: 'Ubuntu-Medium',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Supervisa contenido, cuentas, alertas y crecimiento desde un solo dashboard.',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.15,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Este home debe concentrar lo critico del rol admin: moderacion, salud operativa, aprobaciones, actividad del sistema y accesos rapidos para intervenir cualquier cuenta o post.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: const [
                    _PrimaryPillButton(
                      label: 'Abrir cola critica',
                      icon: Icons.grid_view_rounded,
                    ),
                    SizedBox(width: 12),
                    _SecondaryPillButton(
                      label: 'Ver reporte global',
                      icon: Icons.insert_chart_outlined_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _StatusMetric(
                    title: 'Moderacion automatica',
                    value: '98.2%',
                    progress: 0.98,
                    accent: Color(0xFF2E5BFF),
                  ),
                  SizedBox(height: 14),
                  _StatusMetric(
                    title: 'Salud de servidores',
                    value: '99.4%',
                    progress: 0.99,
                    accent: Color(0xFF0EA5A4),
                  ),
                  SizedBox(height: 14),
                  _StatusMetric(
                    title: 'Casos resueltos hoy',
                    value: '146',
                    progress: 0.73,
                    accent: Color(0xFFFF7A59),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminIdentityRail extends StatelessWidget {
  const _AdminIdentityRail();

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Rol activo',
      subtitle: 'Vista exclusiva para supervision, control y decisiones globales.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF111827),
                  child: Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrador principal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                          fontFamily: 'Ubuntu-Bold',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Permisos para editar, eliminar o reportar cualquier cuenta o post.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: 'Ubuntu-Regular',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _MiniRoleMetric(
            title: 'Entidades bajo control',
            value: 'Todas',
            subtitle: 'Posts, perfiles, reportes y alertas',
          ),
          const SizedBox(height: 10),
          const _MiniRoleMetric(
            title: 'Nivel de acceso',
            value: 'Total',
            subtitle: 'Sin restricciones por modulo',
          ),
        ],
      ),
    );
  }
}

class _QuickSnapshotPanel extends StatelessWidget {
  const _QuickSnapshotPanel();

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Snapshot rapido',
      subtitle: 'Lo mas importante antes de entrar al contenido central.',
      child: const Column(
        children: [
          _SnapshotRow(label: 'Moderacion pendiente', value: '36'),
          SizedBox(height: 10),
          _SnapshotRow(label: 'Cuentas observadas', value: '12'),
          SizedBox(height: 10),
          _SnapshotRow(label: 'Escalamientos hoy', value: '8'),
          SizedBox(height: 10),
          _SnapshotRow(label: 'Incidentes criticos', value: '2'),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData data;

  const _SummaryCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
        borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: data.accent, size: 21),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    data.delta,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF111827),
                      fontFamily: 'Ubuntu-Medium',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontFamily: 'Ubuntu-Regular',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFF0F172A),
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.detail,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                fontFamily: 'Ubuntu-Regular',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformancePanel extends StatelessWidget {
  const _PerformancePanel();

  @override
  Widget build(BuildContext context) {
    const points = [52, 58, 64, 61, 73, 78, 75, 88, 92, 86, 94, 97];

    return _AdminSectionCard(
      title: 'Panorama operativo',
      subtitle: 'Metricas clave del sistema durante las ultimas 12 horas.',
      trailing: const _GhostTag(label: 'Actualizado hace 2 min'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: _MiniInsight(
                  label: 'Tasa de aprobacion',
                  value: '94%',
                  accent: Color(0xFF2E5BFF),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniInsight(
                  label: 'Contenido saludable',
                  value: '97.6%',
                  accent: Color(0xFF0EA5A4),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniInsight(
                  label: 'Tickets escalados',
                  value: '12',
                  accent: Color(0xFFFF7A59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Actividad global',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF111827),
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vista resumida del comportamiento de uso, revisiones y carga del sistema.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'Ubuntu-Regular',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 210,
            child: CustomPaint(
              painter: _TrendChartPainter(
                values: points,
                lineColor: const Color(0xFF111827),
                fillColor: const Color(0x143A7AFE),
                gridColor: const Color(0xFFE5E7EB),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _ChartLabel('08h'),
                        _ChartLabel('10h'),
                        _ChartLabel('12h'),
                        _ChartLabel('14h'),
                        _ChartLabel('16h'),
                        _ChartLabel('18h'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  final List<_QuickActionData> actions;

  const _QuickActionsPanel({
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Acciones rapidas',
      subtitle: 'Controles pensados para intervenir sin navegar demasiado.',
      child: Column(
        children: actions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuickActionTile(data: action),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WatchlistPanel extends StatelessWidget {
  final List<_WatchlistItemData> items;

  const _WatchlistPanel({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Watchlist',
      subtitle: 'Cuentas o espacios que merecen seguimiento inmediato.',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WatchlistTile(data: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RegionalPulsePanel extends StatelessWidget {
  final List<_RegionStatData> items;

  const _RegionalPulsePanel({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Pulso regional',
      subtitle: 'Distribucion de actividad y crecimiento por ciudad.',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RegionStatTile(data: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ModerationQueuePanel extends StatelessWidget {
  final List<_ModerationItemData> items;

  const _ModerationQueuePanel({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Cola de moderacion prioritaria',
      subtitle: 'Casos que el admin debe poder eliminar, editar, reportar o escalar.',
      trailing: const _GhostTag(label: '27 abiertos'),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModerationTile(data: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SystemHealthPanel extends StatelessWidget {
  final List<_FeedItemData> activityFeed;

  const _SystemHealthPanel({
    required this.activityFeed,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Salud del sistema',
      subtitle: 'Capas tecnicas y trazabilidad reciente para detectar roturas rapido.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HealthStrip(),
          const SizedBox(height: 18),
          const Text(
            'Actividad reciente',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
          const SizedBox(height: 12),
          ...activityFeed.map((item) => _FeedTile(data: item)),
        ],
      ),
    );
  }
}

class _NotificationPulsePanel extends StatelessWidget {
  const _NotificationPulsePanel();

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Pulso de notificaciones',
      subtitle: 'Flujo de eventos y avisos relevantes del ecosistema.',
      child: const Column(
        children: [
          _PulseRow(title: 'Reportes nuevos', value: '14', accent: Color(0xFFFF7A59)),
          SizedBox(height: 12),
          _PulseRow(title: 'Solicitudes de soporte', value: '23', accent: Color(0xFF3A7AFE)),
          SizedBox(height: 12),
          _PulseRow(title: 'Alertas IA', value: '6', accent: Color(0xFF0EA5A4)),
        ],
      ),
    );
  }
}

class _EscalationAlertsPanel extends StatelessWidget {
  final List<_MiniAlertData> items;

  const _EscalationAlertsPanel({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Alertas de escalamiento',
      subtitle: 'Resumen de riesgos antes de tomar decisiones manuales.',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MiniAlertTile(data: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GovernancePanel extends StatelessWidget {
  final List<_GovernanceItemData> items;

  const _GovernancePanel({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Gobernanza del contenido',
      subtitle: 'Estado de politicas, verificaciones y auditoria del ecosistema.',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GovernanceTile(data: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ApprovalsPanel extends StatelessWidget {
  final List<_ApprovalItemData> items;

  const _ApprovalsPanel({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Aprobaciones y solicitudes',
      subtitle: 'Nuevas altas, validaciones y cambios de rol pendientes.',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ApprovalTile(data: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TeamInsightsPanel extends StatelessWidget {
  const _TeamInsightsPanel();

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Equipo y cobertura',
      subtitle: 'Un resumen rapido de turnos, capacidad y respuesta.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CoverageRow(
            title: 'Moderadores conectados',
            value: '18',
            progress: 0.72,
            accent: Color(0xFF3A7AFE),
          ),
          SizedBox(height: 14),
          _CoverageRow(
            title: 'Soporte en linea',
            value: '11',
            progress: 0.58,
            accent: Color(0xFF0EA5A4),
          ),
          SizedBox(height: 14),
          _CoverageRow(
            title: 'Casos con SLA en riesgo',
            value: '6',
            progress: 0.31,
            accent: Color(0xFFFF7A59),
          ),
          SizedBox(height: 20),
          _TeamGrid(),
        ],
      ),
    );
  }
}

class _AgendaPanel extends StatelessWidget {
  final List<_AgendaItemData> items;

  const _AgendaPanel({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminSectionCard(
      title: 'Agenda del admin',
      subtitle: 'Tareas clave del dia para control y seguimiento.',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AgendaTile(data: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AdminSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _AdminSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF111827),
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontFamily: 'Ubuntu-Regular',
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PrimaryPillButton({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'Ubuntu-Medium',
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SecondaryPillButton({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF111827), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13,
              fontFamily: 'Ubuntu-Medium',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color accent;

  const _StatusMetric({
    required this.title,
    required this.value,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontFamily: 'Ubuntu-Regular',
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}

class _MiniRoleMetric extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MiniRoleMetric({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontFamily: 'Ubuntu-Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostTag extends StatelessWidget {
  final String label;

  const _GhostTag({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4B5563),
          fontFamily: 'Ubuntu-Medium',
        ),
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  final String label;
  final String value;

  const _SnapshotRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'Ubuntu-Regular',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF111827),
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniInsight extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MiniInsight({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'Ubuntu-Regular',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF111827),
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionData data;

  const _QuickActionTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  final _WatchlistItemData data;

  const _WatchlistTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
              ),
              _GhostTag(label: data.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.detail,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'Ubuntu-Regular',
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionStatTile extends StatelessWidget {
  final _RegionStatData data;

  const _RegionStatTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.region,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Participacion ${data.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
              ],
            ),
          ),
          _GhostTag(label: data.trend),
        ],
      ),
    );
  }
}

class _ModerationTile extends StatelessWidget {
  final _ModerationItemData data;

  const _ModerationTile({
    required this.data,
  });

  Color get _severityColor {
    switch (data.severity) {
      case 'Alta':
        return const Color(0xFFFF7A59);
      case 'Media':
        return const Color(0xFF3A7AFE);
      default:
        return const Color(0xFF0EA5A4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: _severityColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _severityColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Prioridad ${data.severity}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _severityColor,
                          fontFamily: 'Ubuntu-Medium',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        data.status,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF111827),
                          fontFamily: 'Ubuntu-Medium',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthStrip extends StatelessWidget {
  const _HealthStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _HealthItem(
            title: 'API',
            value: 'Estable',
            accent: Color(0xFF0EA5A4),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HealthItem(
            title: 'Auth',
            value: '99.9%',
            accent: Color(0xFF3A7AFE),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HealthItem(
            title: 'Storage',
            value: '1 alerta',
            accent: Color(0xFFFF7A59),
          ),
        ),
      ],
    );
  }
}

class _HealthItem extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _HealthItem({
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'Ubuntu-Regular',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF111827),
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRow extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _PulseRow({
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF111827),
                fontFamily: 'Ubuntu-Medium',
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF111827),
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAlertTile extends StatelessWidget {
  final _MiniAlertData data;

  const _MiniAlertTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF111827),
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'Ubuntu-Regular',
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernanceTile extends StatelessWidget {
  final _GovernanceItemData data;

  const _GovernanceTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _GhostTag(label: data.status),
        ],
      ),
    );
  }
}

class _FeedTile extends StatelessWidget {
  final _FeedItemData data;

  const _FeedTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            data.time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
              fontFamily: 'Ubuntu-Regular',
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalTile extends StatelessWidget {
  final _ApprovalItemData data;

  const _ApprovalTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEFF3F8),
            child: Text(
              data.name.substring(0, 1),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.meta,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.status,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF111827),
                fontFamily: 'Ubuntu-Medium',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  final _AgendaItemData data;

  const _AgendaTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data.hour,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageRow extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color accent;

  const _CoverageRow({
    required this.title,
    required this.value,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF111827),
                  fontFamily: 'Ubuntu-Medium',
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}

class _TeamGrid extends StatelessWidget {
  const _TeamGrid();

  @override
  Widget build(BuildContext context) {
    const team = [
      ('Moderacion', '8 en turno'),
      ('Seguridad', '3 activos'),
      ('Soporte', '11 en linea'),
      ('Ops', '4 revisando'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: team.length,
      itemBuilder: (context, index) {
        final item = team[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.$1,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF111827),
                  fontFamily: 'Ubuntu-Bold',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.$2,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontFamily: 'Ubuntu-Regular',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String label;

  const _ChartLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF9CA3AF),
        fontFamily: 'Ubuntu-Regular',
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<int> values;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _TrendChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minValue = values.reduce((a, b) => a < b ? a : b).toDouble();
    final range = (maxValue - minValue).clamp(1, double.infinity);
    final stepX = values.length == 1 ? size.width : size.width / (values.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < values.length; i++) {
      final normalized = (values[i] - minValue) / range;
      final x = stepX * i;
      final y = size.height - (normalized * (size.height - 24)) - 20;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    final pointPaint = Paint()..color = lineColor;
    for (var i = 0; i < values.length; i++) {
      final normalized = (values[i] - minValue) / range;
      final x = stepX * i;
      final y = size.height - (normalized * (size.height - 24)) - 20;
      canvas.drawCircle(Offset(x, y), 4.5, pointPaint);
      canvas.drawCircle(
        Offset(x, y),
        9,
        Paint()..color = lineColor.withValues(alpha: 0.10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _SummaryCardData {
  final String title;
  final String value;
  final String delta;
  final String detail;
  final IconData icon;
  final Color accent;

  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.delta,
    required this.detail,
    required this.icon,
    required this.accent,
  });
}

class _ModerationItemData {
  final String title;
  final String subtitle;
  final String severity;
  final String status;
  final IconData icon;

  const _ModerationItemData({
    required this.title,
    required this.subtitle,
    required this.severity,
    required this.status,
    required this.icon,
  });
}

class _FeedItemData {
  final String title;
  final String subtitle;
  final String time;

  const _FeedItemData({
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _ApprovalItemData {
  final String name;
  final String category;
  final String meta;
  final String status;

  const _ApprovalItemData({
    required this.name,
    required this.category,
    required this.meta,
    required this.status,
  });
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _WatchlistItemData {
  final String name;
  final String detail;
  final String status;

  const _WatchlistItemData({
    required this.name,
    required this.detail,
    required this.status,
  });
}

class _MiniAlertData {
  final String title;
  final String subtitle;

  const _MiniAlertData({
    required this.title,
    required this.subtitle,
  });
}

class _GovernanceItemData {
  final String title;
  final String detail;
  final String status;

  const _GovernanceItemData({
    required this.title,
    required this.detail,
    required this.status,
  });
}

class _RegionStatData {
  final String region;
  final String value;
  final String trend;

  const _RegionStatData({
    required this.region,
    required this.value,
    required this.trend,
  });
}

class _AgendaItemData {
  final String hour;
  final String title;
  final String detail;

  const _AgendaItemData({
    required this.hour,
    required this.title,
    required this.detail,
  });
}
