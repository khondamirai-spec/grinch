import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/resource_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/resource_type.dart';
import '../../widgets/resource_card.dart';
import '../../widgets/empty_state.dart';
import 'add_resource_sheet.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  ResourceType? _selectedFilter;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final resources = ref.watch(resourceProvider);
    final filteredResources = ref.read(resourceProvider.notifier).getAllResources(
          typeFilter: _selectedFilter,
          searchQuery: _searchQuery,
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text(
                    'My Library',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() => _isSearching = !_isSearching);
                      if (_isSearching == false) {
                        setState(() => _searchQuery = '');
                      }
                    },
                    icon: Icon(_isSearching ? Icons.close : Icons.search),
                  ),
                ],
              ),
            ),

            // Search Bar
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Search by title, description, or tags...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.clear),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'All',
                    count: resources.length,
                    isSelected: _selectedFilter == null,
                    onTap: () => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'PDFs',
                    count: resources.values.where((r) => r.type == ResourceType.pdf).length,
                    icon: Icons.description,
                    isSelected: _selectedFilter == ResourceType.pdf,
                    onTap: () => setState(() => _selectedFilter = ResourceType.pdf),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Audio',
                    count: resources.values.where((r) => r.type == ResourceType.audio).length,
                    icon: Icons.headset,
                    isSelected: _selectedFilter == ResourceType.audio,
                    onTap: () => setState(() => _selectedFilter = ResourceType.audio),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Video',
                    count: resources.values.where((r) => r.type == ResourceType.video).length,
                    icon: Icons.play_circle,
                    isSelected: _selectedFilter == ResourceType.video,
                    onTap: () => setState(() => _selectedFilter = ResourceType.video),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Links',
                    count: resources.values.where((r) => r.type == ResourceType.link).length,
                    icon: Icons.link,
                    isSelected: _selectedFilter == ResourceType.link,
                    onTap: () => setState(() => _selectedFilter = ResourceType.link),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Images',
                    count: resources.values.where((r) => r.type == ResourceType.image).length,
                    icon: Icons.image,
                    isSelected: _selectedFilter == ResourceType.image,
                    onTap: () => setState(() => _selectedFilter = ResourceType.image),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Notes',
                    count: resources.values.where((r) => r.type == ResourceType.note).length,
                    icon: Icons.edit_note,
                    isSelected: _selectedFilter == ResourceType.note,
                    onTap: () => setState(() => _selectedFilter = ResourceType.note),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Resource Grid
            Expanded(
              child: filteredResources.isEmpty
                  ? EmptyState(
                      title: _searchQuery.isNotEmpty || _selectedFilter != null
                          ? 'No matching resources'
                          : 'Your library is empty',
                      subtitle: _searchQuery.isNotEmpty || _selectedFilter != null
                          ? 'Try adjusting your filters or search terms'
                          : 'Upload your first study material to get started!',
                      icon: Icons.folder_open,
                      onAction: _searchQuery.isNotEmpty || _selectedFilter != null
                          ? null
                          : () => _showAddResourceSheet(),
                      actionLabel: _searchQuery.isNotEmpty || _selectedFilter != null
                          ? null
                          : 'Add Material',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredResources.length,
                      itemBuilder: (context, index) {
                        return ResourceCard(resource: filteredResources[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddResourceSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Resource'),
      ),
    );
  }

  void _showAddResourceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddResourceSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.textTertiary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: Theme.of(context).textTheme.caption?.copyWith(
                    color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
