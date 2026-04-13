import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/resource_type.dart';

class ResourceTypeIcon extends StatelessWidget {
  final ResourceType type;
  final double size;

  const ResourceTypeIcon({
    super.key,
    required this.type,
    this.size = 48,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case ResourceType.pdf:
        return AppColors.pdfBg.withOpacity(0.15);
      case ResourceType.audio:
        return AppColors.audioBg.withOpacity(0.15);
      case ResourceType.video:
        return AppColors.videoBg.withOpacity(0.15);
      case ResourceType.link:
        return AppColors.linkBg.withOpacity(0.15);
      case ResourceType.image:
        return AppColors.imageBg.withOpacity(0.15);
      case ResourceType.note:
        return AppColors.noteBg.withOpacity(0.15);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case ResourceType.pdf:
        return AppColors.pdfBg;
      case ResourceType.audio:
        return AppColors.audioBg;
      case ResourceType.video:
        return AppColors.videoBg;
      case ResourceType.link:
        return AppColors.linkBg;
      case ResourceType.image:
        return AppColors.imageBg;
      case ResourceType.note:
        return AppColors.noteBg;
    }
  }

  IconData _getIconData() {
    switch (type) {
      case ResourceType.pdf:
        return Icons.description;
      case ResourceType.audio:
        return Icons.headset;
      case ResourceType.video:
        return Icons.play_circle;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.image:
        return Icons.image;
      case ResourceType.note:
        return Icons.edit_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIconData(),
        size: size * 0.5,
        color: _getIconColor(),
      ),
    );
  }
}
