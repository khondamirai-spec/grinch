enum ResourceType {
  pdf,
  audio,
  video,
  link,
  image,
  note,
}

extension ResourceTypeExtension on ResourceType {
  String get displayName {
    switch (this) {
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.audio:
        return 'Audio';
      case ResourceType.video:
        return 'Video';
      case ResourceType.link:
        return 'Link';
      case ResourceType.image:
        return 'Image';
      case ResourceType.note:
        return 'Note';
    }
  }

  String get icon {
    switch (this) {
      case ResourceType.pdf:
        return 'description';
      case ResourceType.audio:
        return 'headset';
      case ResourceType.video:
        return 'play_circle';
      case ResourceType.link:
        return 'link';
      case ResourceType.image:
        return 'image';
      case ResourceType.note:
        return 'edit_note';
    }
  }
}
