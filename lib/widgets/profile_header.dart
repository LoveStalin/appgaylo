import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/edit_profile_screen.dart';
import '../main.dart';

class ProfileHeader extends StatefulWidget {
  final User user;
  final String? bio;
  final File? avatarImage;
  final VoidCallback onAvatarChanged;
  final Function(String?) onBioChanged;

  const ProfileHeader({
    super.key,
    required this.user,
    this.bio,
    this.avatarImage,
    required this.onAvatarChanged,
    required this.onBioChanged,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late File? _avatarImage;
  late String? _bio;

  @override
  void initState() {
    super.initState();
    _avatarImage = widget.avatarImage;
    _bio = widget.bio;
  }

  Future<void> _pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file != null) {
        final picked = File(file.path);
        setState(() => _avatarImage = picked);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar_path', picked.path);
        } catch (_) {}
        widget.onAvatarChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editBio() async {
    final controller = TextEditingController(text: _bio ?? '');
    if (!mounted) return;
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Bio'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Viết điều gì đó về bạn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (res != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bio', res);
      if (!mounted) return;
      setState(() => _bio = res);
      widget.onBioChanged(res);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bio đã được cập nhật')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        GestureDetector(
          onTap: _pickAvatar,
          child: CircleAvatar(
            radius: 56,
            backgroundColor: Colors.white,
            backgroundImage: _avatarImage != null
                ? FileImage(_avatarImage!) as ImageProvider
                : (widget.user.photoURL != null
                      ? NetworkImage(widget.user.photoURL!)
                      : null),
            child: _avatarImage == null && widget.user.photoURL == null
                ? const Icon(Icons.person, size: 56, color: Colors.pink)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.user.displayName ?? widget.user.email ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );

                if (result == true) {
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              child: const Text("Edit"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _editBio,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: (_bio ?? '').isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _bio!,
                          style: TextStyle(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.edit, size: 14, color: Colors.grey[500]),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        L(context, 'add_bio'),
                        style: TextStyle(
                          color: Colors.pink[300],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.add_comment,
                        size: 14,
                        color: Colors.pink[300],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
