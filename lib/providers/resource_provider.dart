import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/resource_model.dart';
import '../services/storage_service.dart';
import 'task_provider.dart';
import '../utils/resource_type.dart';

const _uuid = Uuid();

final resourceProvider = StateNotifierProvider<ResourceNotifier, Map<String, Resource>>((ref) {
  return ResourceNotifier(ref.watch(storageServiceProvider));
});

class ResourceNotifier extends StateNotifier<Map<String, Resource>> {
  final StorageService _storage;

  ResourceNotifier(this._storage) : super({}) {
    _loadResources();
  }

  void _loadResources() {
    final resourcesJson = _storage.getAllResources();
    final resources = <String, Resource>{};
    resourcesJson.forEach((key, value) {
      try {
        resources[key] = Resource.fromJson(Map<String, dynamic>.from(value));
      } catch (e) {
        // Skip invalid resources
      }
    });
    state = resources;
  }

  void addResource({
    required String title,
    String? description,
    required ResourceType type,
    required String source,
    bool isLocal = true,
    List<String> tags = const [],
    Uint8List? fileData,
  }) {
    final resource = Resource(
      id: _uuid.v4(),
      title: title,
      description: description,
      type: type,
      source: source,
      isLocal: isLocal,
      createdAt: DateTime.now(),
      tags: tags,
    );

    _storage.saveResource(resource.id, resource.toJson());

    if (isLocal && fileData != null) {
      _storage.saveResourceFile(resource.id, fileData);
    }

    state = {...state, resource.id: resource};
  }

  void updateResource(String id, {
    String? title,
    String? description,
    List<String>? tags,
  }) {
    final resource = state[id];
    if (resource == null) return;

    final updatedResource = resource.copyWith(
      title: title,
      description: description,
      tags: tags,
    );

    _storage.saveResource(id, updatedResource.toJson());
    state = {...state, id: updatedResource};
  }

  void deleteResource(String id) {
    final resource = state[id];
    if (resource == null) return;

    // Remove references from tasks
    _storage.deleteResource(id);
    _storage.deleteResourceFile(id);

    final newState = Map<String, Resource>.from(state);
    newState.remove(id);
    state = newState;
  }

  List<Resource> getAllResources({ResourceType? typeFilter, String? searchQuery}) {
    var resources = state.values.toList();

    if (typeFilter != null) {
      resources = resources.where((r) => r.type == typeFilter).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      resources = resources.where((r) {
        return r.title.toLowerCase().contains(query) ||
            (r.description?.toLowerCase().contains(query) ?? false) ||
            r.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    resources.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return resources;
  }

  Resource? getResource(String id) {
    return state[id];
  }

  void incrementTimesReferenced(String id) {
    final resource = state[id];
    if (resource == null) return;

    final updatedResource = resource.copyWith(
      timesReferenced: resource.timesReferenced + 1,
    );

    _storage.saveResource(id, updatedResource.toJson());
    state = {...state, id: updatedResource};
  }
}
