import '../utils/resource_type.dart';

class Resource {
  final String id;
  String title;
  String? description;
  final ResourceType type;
  final String source;
  final bool isLocal;
  final DateTime createdAt;
  String? thumbnailKey;
  int timesReferenced;
  List<String> tags;

  Resource({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.source,
    this.isLocal = true,
    required this.createdAt,
    this.thumbnailKey,
    this.timesReferenced = 0,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'source': source,
      'isLocal': isLocal,
      'createdAt': createdAt.toIso8601String(),
      'thumbnailKey': thumbnailKey,
      'timesReferenced': timesReferenced,
      'tags': tags,
    };
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: ResourceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ResourceType.note,
      ),
      source: json['source'] as String,
      isLocal: json['isLocal'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      thumbnailKey: json['thumbnailKey'] as String?,
      timesReferenced: json['timesReferenced'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Resource copyWith({
    String? id,
    String? title,
    String? description,
    ResourceType? type,
    String? source,
    bool? isLocal,
    DateTime? createdAt,
    String? thumbnailKey,
    int? timesReferenced,
    List<String>? tags,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      source: source ?? this.source,
      isLocal: isLocal ?? this.isLocal,
      createdAt: createdAt ?? this.createdAt,
      thumbnailKey: thumbnailKey ?? this.thumbnailKey,
      timesReferenced: timesReferenced ?? this.timesReferenced,
      tags: tags ?? this.tags,
    );
  }
}
