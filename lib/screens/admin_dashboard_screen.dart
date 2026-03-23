import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/content_item.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../screens/login_screens.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _authService = AuthService();
  final _contentService = ContentService();

  bool _isSubmitting = false;

  // When non-null, we're in "edit mode" for this item
  ContentItem? _editingItem;

  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────

  void _clearForm() {
    _formKey.currentState?.reset();
    _imageUrlController.clear();
    _titleController.clear();
    _descriptionController.clear();
    setState(() => _editingItem = null);
  }

  void _populateForm(ContentItem item) {
    _imageUrlController.text = item.imageUrl;
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    setState(() => _editingItem = item);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFFFF6B2C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── CRUD Operations ─────────────────────────────────────────

  Future<void> _addContent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _contentService.addContent(
        imageUrl: _imageUrlController.text,
        title: _titleController.text,
        description: _descriptionController.text,
      );
      _clearForm();
      _showSnackBar('Content added successfully!');
    } catch (e) {
      _showSnackBar('Error adding content: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateContent() async {
    if (_editingItem == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _contentService.updateContent(
        docId: _editingItem!.id,
        imageUrl: _imageUrlController.text,
        title: _titleController.text,
        description: _descriptionController.text,
      );
      _clearForm();
      _showSnackBar('Content updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating content: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmAndDelete(ContentItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE53935),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Content',
                style: TextStyle(
                  color: Color(0xFF1A0A00),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEDD5C8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _contentService.deleteContent(item.id);
        if (_editingItem?.id == item.id) _clearForm();
        _showSnackBar('Content deleted.');
      } catch (e) {
        _showSnackBar('Error deleting content: $e', isError: true);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B2C), Color(0xFFFF9A5C)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'dashboard',
                style: TextStyle(
                  color: Color(0xFF1A0A00),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, color: Color(0xFF000000), size: 18),
                SizedBox(width: 4),
                Text(
                  'Logout',
                  style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Input Form ────────────────────────────────────
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: _buildInputForm(),
              ),
            ),
          ),

          // ── Divider ───────────────────────────────────────
          Container(height: 1, color: const Color(0xFFEDD5C8)),

          // ── Content List ──────────────────────────────────
          const Flexible(
            flex: 1,
            child: _ContentListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    final isEditing = _editingItem != null;
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_note : Icons.add_circle_outline,
                  color: const Color(0xFFFF6B2C),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isEditing ? 'Edit Content' : 'Add New Content',
                    style: const TextStyle(
                      color: Color(0xFF1A0A00),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isEditing) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: _clearForm,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Image URL field
            _buildFormField(
              controller: _imageUrlController,
              label: 'Image URL',
              hint: 'https://example.com/image.jpg',
              icon: Icons.image_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter an image URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Title field
            _buildFormField(
              controller: _titleController,
              label: 'Title',
              hint: 'Content title',
              icon: Icons.title,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Description field
            _buildFormField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Write a detailed description...',
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Action Button
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : (isEditing ? _updateContent : _addContent),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        isEditing ? Icons.save_outlined : Icons.add,
                        size: 20,
                      ),
                label: Text(
                  isEditing ? 'Update Content' : 'Add Content',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Color(0xFF1A0A00), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: Color(0xFF000000),
            fontSize: 16,
            fontWeight: FontWeight.w600),
        hintText: hint,
        hintStyle: const TextStyle(
            color: Color(0xFF000000),
            fontSize: 16,
            fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: const Color(0xFF000000), size: 20),
        filled: true,
        fillColor: const Color(0xFFFFF8F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF000000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF000000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF6B2C), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        errorStyle: const TextStyle(
            color: Color(0xFFE53935),
            fontSize: 16,
            fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }
}

// Separate widget for content list to better manage state and prevent rebuild issues
class _ContentListView extends StatelessWidget {
  const _ContentListView();

  @override
  Widget build(BuildContext context) {
    final contentService = ContentService();

    return StreamBuilder<List<ContentItem>>(
      stream: contentService.getContentStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B2C)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading content:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE53935)),
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 60,
                  color: Color(0xFF000000),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'No content yet.\nUse the form above to add some!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9A7060),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _buildContentCard(context, items[index]),
        );
      },
    );
  }

  Widget _buildContentCard(BuildContext context, ContentItem item) {
    // Get parent state to check if this item is being edited
    final parentState =
        context.findAncestorStateOfType<_AdminDashboardScreenState>();
    final isCurrentlyEditing = parentState?._editingItem?.id == item.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentlyEditing
              ? const Color(0xFFFF6B2C)
              : const Color(0xFFEDD5C8),
          width: isCurrentlyEditing ? 1.5 : 1,
        ),
        boxShadow: isCurrentlyEditing
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B2C).withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 180,
                color: const Color(0xFFFFF0E8),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B2C),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                color: const Color(0xFFFFF0E8),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: Color(0xFFBFA090),
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Image unavailable',
                      style: TextStyle(
                        color: Color(0xFFBFA090),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content + Actions
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF1A0A00),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Edit button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => parentState?._populateForm(item),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF6B2C).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFFFF6B2C),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => parentState?._confirmAndDelete(item),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE53935).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE53935),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
