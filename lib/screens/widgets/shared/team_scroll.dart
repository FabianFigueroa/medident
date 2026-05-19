import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String? photoUrl;

  const TeamMember({
    required this.id,
    required this.name,
    this.role = '',
    this.photoUrl,
  });
}

class TeamHorizontalScroll extends StatelessWidget {
  final List<TeamMember> members;
  final String title;
  final String emptyMessage;

  const TeamHorizontalScroll({
    super.key,
    required this.members,
    this.title = 'Nuestro Equipo',
    this.emptyMessage = 'Sin miembros',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                emptyMessage,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 115,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final m = members[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: m.photoUrl != null && m.photoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: m.photoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const CircularProgressIndicator(),
                                errorWidget: (_, __, ___) => Icon(Icons.person, color: Colors.grey[400]),
                              )
                            : Icon(Icons.person, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 75,
                        child: Column(children: [
                          Text(
                            m.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          if (m.role.isNotEmpty)
                            Text(
                              m.role,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                            ),
                        ]),
                      ),
                    ]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
