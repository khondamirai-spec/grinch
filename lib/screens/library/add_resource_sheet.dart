import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/resource_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/resource_type.dart';

class AddResourceSheet extends ConsumerStatefulWidget {
  const AddResourceSheet({super.key});

  @override
  ConsumerState<AddResourceSheet> createState() => _AddResourceSheetState();
}

class _AddResourceSheetState extends ConsumerState<AddResourceSheet> {
  ResourceType? _selectedType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _tagsController = TextEditingController();
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    List<String>? extensions;
    switch (_selectedType) {
      case ResourceType.pdf:
        extensions = ['pdf'];
        break;
      case ResourceType.audio:
        extensions = ['mp3', 'wav', 'ogg'];
        break;
      case ResourceType.video:
        extensions = ['mp4', 'webm'];
        break;
      case ResourceType.image:
        extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        break;
      default:
        break;
    }

    try {
      final file = await FileService.pickFile(
        allowedExtensions: extensions,
      );

      if (file != null) {
        if (file.size > 50 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds 50MB. Please choose a smaller file.'),
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileBytes = file.bytes;
          if (_titleController.text.isEmpty) {
            _titleController.text = file.name.split('.').first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  void _saveResource() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resource type')),
      );
      return;
    }

    String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedType != ResourceType.link && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file')),
      );
      return;
    }

    if (_selectedType == ResourceType.link && _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a URL')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (_selectedType == ResourceType.link) {
      ref.read(resourceProvider.notifier).addResource(
            title: title,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            type: _selectedType!,
            source: _urlController.text.trim(),
            isLocal: false,
            tags: tags,
          );
    } else if (_selectedType == ResourceType.note) {
      ref.read(resourceProvider.notifier).addResource(
            title: title,
            description: _descriptionController.text.trim(),
            type: _selectedType!,
            source: 'note',
            isLocal: false,
            tags: tags,
          );
    } else {
      ref.read(resourceProvider.notifier).addResource(
            title: title,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            type: _selectedType!,
            source: _selectedFile!.name,
            isLocal: true,
            tags: tags,
            fileData: _fileBytes,
          );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resource saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Resource',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Type Selector
            Text(
              'Resource Type',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _TypeSelectorButton(
                  type: ResourceType.pdf,
                  icon: Icons.description,
                  isSelected: _selectedType == ResourceType.pdf,
                  onTap: () => setState(() => _selectedType = ResourceType.pdf),
                ),
                _TypeSelectorButton(
                  type: ResourceType.audio,
                  icon: Icons.headset,
                  isSelected: _selectedType == ResourceType.audio,
                  onTap: () => setState(() => _selectedType = ResourceType.audio),
                ),
                _TypeSelectorButton(
                  type: ResourceType.video,
                  icon: Icons.play_circle,
                  isSelected: _selectedType == ResourceType.video,
                  onTap: () => setState(() => _selectedType = ResourceType.video),
                ),
                _TypeSelectorButton(
                  type: ResourceType.link,
                  icon: Icons.link,
                  isSelected: _selectedType == ResourceType.link,
                  onTap: () => setState(() => _selectedType = ResourceType.link),
                ),
                _TypeSelectorButton(
                  type: ResourceType.image,
                  icon: Icons.image,
                  isSelected: _selectedType == ResourceType.image,
                  onTap: () => setState(() => _selectedType = ResourceType.image),
                ),
                _TypeSelectorButton(
                  type: ResourceType.note,
                  icon: Icons.edit_note,
                  isSelected: _selectedType == ResourceType.note,
                  onTap: () => setState(() => _selectedType = ResourceType.note),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // File Upload or URL Input
            if (_selectedType != null && _selectedType != ResourceType.link && _selectedType != ResourceType.note) ...[
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedFile != null
                          ? AppColors.primaryAccent
                          : AppColors.textTertiary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _selectedFile != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.primaryAccent, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFile!.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              FileService.getFileSizeFormatted(_selectedFile!.size),
                              style: Theme.of(context).textTheme.caption?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text(
                              'Upload File',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
            ] else if (_selectedType == ResourceType.link) ...[
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://...',
                ),
              ),
            ] else if (_selectedType == ResourceType.note) ...[
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Note Content',
                  hintText: 'Type your notes here...',
                ),
                maxLines: 6,
              ),
            ],

            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Chapter 5 — Biology',
              ),
            ),
            const SizedBox(height: 16),

            // Description (not for notes)
            if (_selectedType != ResourceType.note)
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add notes about this resource...',
                ),
                maxLines: 3,
              ),
            if (_selectedType != ResourceType.note) const SizedBox(height: 16),

            // Tags
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                hintText: 'e.g., biology, exam-prep',
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveResource,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save to Library'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TypeSelectorButton extends StatelessWidget {
  final ResourceType type;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelectorButton({
    required this.type,
    required this.icon,
    required this.isSelected,
    required this.onTap,
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
    if (isSelected) return Colors.white;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.textTertiary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: _getIconColor()),
            const SizedBox(height: 4),
            Text(
              type.displayName,
              style: Theme.of(context).textTheme.caption?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
