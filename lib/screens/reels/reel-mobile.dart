// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_export.dart';
class ReelsPageMobile extends StatefulWidget {
  const ReelsPageMobile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReelsPageMobileState createState() => _ReelsPageMobileState();
}

class _ReelsPageMobileState extends State<ReelsPageMobile> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _reels = [
    {
      'id': 1,
      'username': 'dra_ana',
      'avatar': 'https://i.pravatar.cc/150?img=6',
      'likes': '124K',
      'comments': '1.2K',
      'caption': 'Endodoncia en 3 pasos 🦷 #odontologia',
    },
    {
      'id': 2,
      'username': 'dr_carlos',
      'avatar': 'https://i.pravatar.cc/150?img=7',
      'likes': '89K',
      'comments': '890',
      'caption': 'Cómo prevenir caries en niños 👶',
    },
    {
      'id': 3,
      'username': 'dra_laura',
      'avatar': 'https://i.pravatar.cc/150?img=8',
      'likes': '256K',
      'comments': '3.4K',
      'caption': 'Blanqueamiento dental: mitos y realidades ✨',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentRole = AppLogger.roleName(
      context.watch<AuthenticateProvider>().user?.role,
    );
    Provider.of<ValeriaProvider>(context, listen: false).observe('reels');

    return ScreenTrace(
      tag: 'REELS_SCREEN_MOBILE',
      message: 'Pantalla Reels mobile cargada. Preparando feed vertical de contenido.',
      role: currentRole,
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.black,
                    child: Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.3), size: 80),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 16,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(_reels[index]['avatar']),
                            ),
                            SizedBox(width: 8),
                            Text(
                              _reels[index]['username'],
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          _reels[index]['caption'],
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 16,
                    child: Column(
                      children: [
                        _buildActionButton(Icons.favorite, _reels[index]['likes']),
                        SizedBox(height: 20),
                        _buildActionButton(Icons.chat_bubble, _reels[index]['comments']),
                        SizedBox(height: 20),
                        _buildActionButton(Icons.send, 'Share'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text('Reels', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
