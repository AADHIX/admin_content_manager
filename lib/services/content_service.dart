// lib/services/content_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────
  // Firestore Collection Path
  // All public content lives at: app_data/public_content/items
  // ─────────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _contentCollection => _firestore
      .collection('app_data')
      .doc('public_content')
      .collection('items');

  // ─────────────────────────────────────────────────────────────
  // READ — Real-time Stream
  // ─────────────────────────────────────────────────────────────

  /// Stream of all content items, ordered by creation date (newest first).
  /// Both admins and authenticated users can listen to this stream.
  Stream<List<ContentItem>> getContentStream() {
    return _contentCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContentItem.fromFirestore(doc))
              .toList(),
        );
  }

  // ─────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────

  /// Add a new content item to Firestore.
  /// Only admins should call this (enforced by Firestore Security Rules).
  Future<void> addContent({
    required String imageUrl,
    required String title,
    required String description,
  }) async {
    await _contentCollection.add({
      'imageUrl': imageUrl.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────

  /// Update an existing content item in Firestore.
  /// Only admins should call this (enforced by Firestore Security Rules).
  Future<void> updateContent({
    required String docId,
    required String imageUrl,
    required String title,
    required String description,
  }) async {
    await _contentCollection.doc(docId).update({
      'imageUrl': imageUrl.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────────

  /// Delete a content item from Firestore by document ID.
  /// Only admins should call this (enforced by Firestore Security Rules).
  Future<void> deleteContent(String docId) async {
    await _contentCollection.doc(docId).delete();
  }
}
