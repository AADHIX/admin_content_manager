// lib/models/content_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ContentItem {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final DateTime? createdAt;

  ContentItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.createdAt,
  });

  /// Create a ContentItem from a Firestore document snapshot
  factory ContentItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentItem(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert a ContentItem to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of this ContentItem with updated fields
  ContentItem copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return ContentItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
