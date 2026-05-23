import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Appbar_Center_Widget extends StatelessWidget implements PreferredSizeWidget {
  final HugeIcon? leftIcon;
  final HugeIcon? rightIcon;
  final String? title;
  final Widget? titleWidget;
  final TextAlign textAlign;
  final VoidCallback? leftIconTap;
  final VoidCallback? rightIconTap;
  final Color? gradientColorStart;
  final Color? gradientColorEnd;
  final double iconSize;
  final TextStyle? titleStyle;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showGradientTitle;

  const Appbar_Center_Widget({
    Key? key,
    this.leftIcon,
    this.rightIcon,
    this.title,
    this.titleWidget,
    this.textAlign = TextAlign.center,
    this.leftIconTap,
    this.rightIconTap,
    this.iconSize = 24,
    this.gradientColorStart,
    this.gradientColorEnd,
    this.titleStyle,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.backgroundColor,
    this.showGradientTitle = true,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: Container(
        height: height,
        width: double.infinity,
        padding: padding,
        child: Row(
          children: [
            _buildLeftSection(),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCenterSection(context), // Pasamos el context
            ),
            _buildRightSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    if (leftIcon == null) {
      return const SizedBox(width: 48);
    }
    
    return Semantics(
      button: true,
      enabled: leftIconTap != null,
      onTap: leftIconTap,
      label: 'Botón izquierdo',
      child: GestureDetector(
        onTap: leftIconTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: HugeIcon(
            icon: leftIcon!.icon,
            color: Colors.grey,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildRightSection() {
    if (rightIcon == null) {
      return const SizedBox(width: 48);
    }
    
    return Semantics(
      button: true,
      enabled: rightIconTap != null,
      onTap: rightIconTap,
      label: 'Botón derecho',
      child: GestureDetector(
        onTap: rightIconTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: HugeIcon(
            icon: rightIcon!.icon,
            color: Colors.grey.withOpacity(0.7),
            size: iconSize - 4,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterSection(BuildContext context) { // Recibe el context
    if (titleWidget != null) {
      return titleWidget!;
    }
    
    if (title == null) {
      return const SizedBox.shrink();
    }
    
    if (showGradientTitle && (gradientColorStart != null || gradientColorEnd != null)) {
      return _buildGradientTitle(title!);
    }
    
    return Text(
      title!,
      textAlign: textAlign,
      style: titleStyle ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ) ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: Colors.black,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildGradientTitle(String titleText) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          gradientColorStart ?? Colors.blue,
          gradientColorEnd ?? Colors.purple,
        ],
      ).createShader(bounds),
      child: Text(
        titleText,
        textAlign: textAlign,
        style: titleStyle ??
            const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: Colors.white,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
