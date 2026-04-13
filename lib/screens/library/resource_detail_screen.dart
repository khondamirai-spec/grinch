import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/resource_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/resource_model.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/audio_player_widget.dart';

class ResourceDetailScreen extends ConsumerStatefulWidget {
  final String resourceId;

  const ResourceDetailScreen({
    super.key,
    required this.resourceId,
  });

  @override
  ConsumerState<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends ConsumerState<ResourceDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  List<int>? _fileBytes;

  @override
  void initState() {
    super.initState();
    final resource = ref.read(resourceProvider)[widget.resourceId];
    _titleController = TextEditingController(text: resource?.title ?? '');
    _descriptionController = TextEditingController(text: resource?.description ?? '');
    _tagsController = TextEditingController(text: resource?.tags.join(', ') ?? '');

    // Load file bytes if local
    if (resource?.isLocal == true) {
      _fileBytes = StorageService().getResourceFile(widget.resourceId);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    ref.read(resourceProvider.notifier).updateResource(
          widget.resourceId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          tags: tags,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resource updated successfully')),
    );
  }

  void _deleteResource() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure you want to delete this resource? This will also remove it from all linked tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(resourceProvider.notifier).deleteResource(widget.resourceId);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resource = ref.watch(resourceProvider)[widget.resourceId];

    if (resource == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resource Not Found')),
        body: const Center(child: Text('Resource not found')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Resource Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resource Viewer
                    _buildResourceViewer(resource),
                    const SizedBox(height: 24),

                    // Title
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Resource Title',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: _descriptionController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Add description or notes...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 24),

                    // Tags
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated)',
                        hintText: 'e.g., biology, exam-prep',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Linked Tasks
                    Text(
                      'Linked Tasks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildLinkedTasksList(resource),
                    const SizedBox(height: 16),

                    // Date Added
                    Text(
                      'Added on ${resource.createdAt.month}/${resource.createdAt.day}/${resource.createdAt.year}',
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteResource,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Resource'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.priorityHigh,
                          side: const BorderSide(color: AppColors.priorityHigh),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceViewer(Resource resource) {
    switch (resource.type) {
      case ResourceType.pdf:
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, size: 64, color: AppColors.pdfBg),
                const SizedBox(height: 16),
                Text(
                  'PDF Viewer',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF rendering will be displayed here',
                  style: Theme.of(context).textTheme.caption?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
        );

      case ResourceType.audio:
        return AudioPlayerWidget(
          source: resource.source,
          isLocal: resource.isLocal,
          fileBytes: _fileBytes != null ? Uint8List.fromList(_fileBytes!) : null,
        );

      case ResourceType.video:
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle, size: 64, color: AppColors.videoBg),
                const SizedBox(height: 16),
                Text(
                  'Video Player',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        );

      case ResourceType.link:
        return GestureDetector(
          onTap: () => _openLink(resource.source),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.linkBg.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: AppColors.linkBg, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'External Link',
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource.source,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new, color: AppColors.linkBg),
              ],
            ),
          ),
        );

      case ResourceType.image:
        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 64, color: AppColors.imageBg),
                const SizedBox(height: 16),
                Text(
                  'Image Viewer',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        );

      case ResourceType.note:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.noteBg.withOpacity(0.3)),
          ),
          child: Text(
            resource.description ?? 'No content',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
    }
  }

  Widget _buildLinkedTasksList(Resource resource) {
    final tasks = ref.watch(taskProvider);
    final linkedTasks = tasks.values
        .where((task) => task.linkedResourceIds.contains(resource.id))
        .toList();

    if (linkedTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No tasks link to this resource',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: linkedTasks.length,
      itemBuilder: (context, index) {
        final task = linkedTasks[index];
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.isCompleted ? AppColors.primaryAccent : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
