import 'package:flutter/material.dart';
import '../../../../main_export.dart';

///////////////////////////////////////////////////////////////////
  Widget ToggleChipWidget({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap, required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEAF0FF) : AppColors.grey100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: active ? const Color(0xFF3A7AFE) : const Color(0xFFE7EAEE),
              width: active ? 1.4 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color:
                    active ? const Color(0xFF3A7AFE) : AppColors.grey600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Ubuntu-Medium',
                  color:
                      active ? const Color(0xFF3A7AFE) : AppColors.grey600,
                )),
          ],
        ),
      ),
    );
  }

