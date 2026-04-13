import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/resource_model.dart';
import '../theme/app_colors.dart';
import '../widgets/resource_type_icon.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;

  const ResourceCard({
    super.key,
    required this.resource,
  });

  Color _getBackgroundColor() {
    switch (resource.type) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/library/${resource.id}');
      },
      onLongPress: () {
        _showQuickOptions(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon area
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: ResourceTypeIcon(
                  type: resource.type,
                  size: 64,
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (resource.timesReferenced > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Used in ${resource.timesReferenced} task${resource.timesReferenced > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.caption?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  if (resource.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: resource.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$tag',
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (resource.tags.length > 2)
                      Text(
                        '+${resource.tags.length - 2} more',
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Resource'),
              onTap: () {
                Navigator.pop(context);
                context.push('/library/${resource.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.priorityHigh),
              title: const Text('Delete Resource', style: TextStyle(color: AppColors.priorityHigh)),
              onTap: () {
                Navigator.pop(context);
                // Delete resource
              },
            ),
          ],
        ),
      ),
    );
  }
}
