import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class DotsIndicator extends StatelessWidget {
  //
  final int dotsCount;
  final int position;
  //
  const DotsIndicator({
    super.key,
    required this.dotsCount,
    required this.position,
  });
  //
  Widget _buildDot(int index) {
    return   Container(
      margin:  EdgeInsets.symmetric(horizontal: 4.0),
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: position == index ? AppColors.white : Colors.white.withOpacity(0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotsCount, (index) => _buildDot(index)),
    );
  }
}
