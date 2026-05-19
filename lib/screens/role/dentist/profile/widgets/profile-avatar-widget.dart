import 'package:flutter/material.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-schudel-model.dart';
import 'theme.dart';

// ─────────────────────────────────────────
//  ProfileAvatarStories Widget
//  Sección 2 del SchudelWidget
//  Estilo: Facebook/Instagram Stories ring
// ─────────────────────────────────────────

class ProfileAvatarStories extends StatelessWidget {
  final List<UserSchudelModel> doctors;
  final UserSchudelModel currentUser;
  final Function(UserSchudelModel)? onDoctorTap;
  final Function()? onAddStory;

  const ProfileAvatarStories({
    super.key,
    required this.doctors,
    required this.currentUser,
    this.onDoctorTap,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: doctors.length + 1, // +1 para el usuario actual (Yo)
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Primer ítem: el usuario actual con botón "+"
            return _MyAvatarItem(
              user: currentUser,
              onAdd: onAddStory,
            );
          }
          final doctor = doctors[index - 1];
          return _DoctorStoryItem(
            doctor: doctor,
            onTap: () => onDoctorTap?.call(doctor),
          );
        },
      ),
    );
  }
}

// ── Mi avatar (con badge "+") ──
class _MyAvatarItem extends StatelessWidget {
  final UserSchudelModel user;
  final VoidCallback? onAdd;

  const _MyAvatarItem({required this.user, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Anillo activo (gradiente iOS)
              _StoryRing(
                isSeen: false,
                isActive: true,
                child: _AvatarCircle(user: user),
              ),
              // Badge "+"
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Yo',
            style: AppTypography.caption2.copyWith(
              color: AppColors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar de un doctor ──
class _DoctorStoryItem extends StatelessWidget {
  final UserSchudelModel doctor;
  final VoidCallback? onTap;

  const _DoctorStoryItem({required this.doctor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StoryRing(
            isSeen: doctor.storyIsSeen,
            isActive: doctor.hasActiveStory,
            isBusy: _isDoctorBusy(doctor),
            child: _AvatarCircle(user: doctor),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 56,
            child: Text(
              doctor.firstName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption2.copyWith(
                color: AppColors.gray1,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Doctores con cita "In Progress" se muestran como "ocupados" (anillo naranja)
  bool _isDoctorBusy(UserSchudelModel doctor) {
    // Puedes conectar esto a los appointments reales si lo deseas
    return !doctor.storyIsSeen && doctor.hasActiveStory &&
        doctor.avatarColor == AppColors.orange;
  }
}

// ── Anillo de Story (el "ring" estilo Instagram) ──
class _StoryRing extends StatelessWidget {
  final bool isSeen;
  final bool isActive;
  final bool isBusy;
  final Widget child;

  const _StoryRing({
    required this.isSeen,
    required this.isActive,
    this.isBusy = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      // Sin story activo: anillo gris simple
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.gray5,
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: child,
        ),
      );
    }

    if (isBusy) {
      // Ocupado: anillo naranja/amarillo animado
      return _GradientRing(
        colors: const [Color(0xFFFF9500), Color(0xFFFFCC02), Color(0xFFFF9500)],
        child: child,
      );
    }

    if (isSeen) {
      // Story visto: anillo gris claro
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.gray4,
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: child,
        ),
      );
    }

    // Story no visto: anillo gradiente azul/índigo (iOS style)
    return _GradientRing(
      colors: const [
        Color(0xFF007AFF),
        Color(0xFF34AADC),
        Color(0xFF007AFF),
        Color(0xFF5856D6),
      ],
      child: child,
    );
  }
}

// ── Anillo con gradiente (usando CustomPaint) ──
class _GradientRing extends StatelessWidget {
  final List<Color> colors;
  final Widget child;

  const _GradientRing({required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientRingPainter(colors: colors),
      child: Container(
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(1.5),
          child: child,
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  final List<Color> colors;

  const _GradientRingPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 2.5;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0,
        endAngle: 3.14159 * 2,
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Círculo de avatar con iniciales ──
class _AvatarCircle extends StatelessWidget {
  final UserSchudelModel user;

  const _AvatarCircle({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          user.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsCircle(),
        ),
      );
    }
    return _initialsCircle();
  }

  Widget _initialsCircle() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: user.avatarColor,
      ),
      child: Center(
        child: Text(
          user.initials,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
