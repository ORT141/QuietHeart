// lib/tales_data.dart
class Tale {
  final String titleKey;
  final String authorKey;
  final int originalIndex;

  Tale(this.titleKey, this.authorKey, this.originalIndex);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tale &&
          runtimeType == other.runtimeType &&
          titleKey == other.titleKey &&
          originalIndex == other.originalIndex;

  @override
  int get hashCode => titleKey.hashCode ^ originalIndex.hashCode;
}

final List<Tale> tales = <Tale>[
  Tale('tale1Title', 'tale1Author', 0),
  Tale('tale2Title', 'tale2Author', 1),
  Tale('tale3Title', 'tale3Author', 2),
];
