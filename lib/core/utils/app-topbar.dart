import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class CustomTopBar extends StatelessWidget {
  final List<IconData> icons;
  final List<IconData> selectedIcons;
  final int selectedIndex;
  final Function(int) onTap;
  final TabController tabController;

  const CustomTopBar({
    super.key,
    required this.icons,
    required this.selectedIcons,
    required this.selectedIndex,
    required this.onTap,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicator: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 3.0),
        ),
      ),
      tabs: List.generate(icons.length, (i) {
        final iconData = i == selectedIndex ? selectedIcons[i] : icons[i];
        return Tab(
          icon: Icon(
            iconData,
            color: i == selectedIndex ? AppColors.primary : Colors.grey.shade600,
            size: 30.0,
          ),
        );
      }),
      onTap: onTap,
    );
  }
}
