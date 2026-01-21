import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../services/services.dart';
import '../theme/theme.dart';

/// Profil fotoğrafı widget'ı
/// Tıklanabilir, fotoğraf seçme/çekme özellikli
class ProfilePhotoWidget extends StatefulWidget {
  final double size;
  final bool editable;
  final VoidCallback? onPhotoChanged;

  const ProfilePhotoWidget({
    super.key,
    this.size = 100,
    this.editable = true,
    this.onPhotoChanged,
  });

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final path = await _profileService.getProfilePhotoPath();
    if (mounted) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      final savedPath = await _profileService.saveProfilePhoto(
        File(pickedFile.path),
      );

      if (mounted) {
        setState(() {
          _photoPath = savedPath;
          _isLoading = false;
        });
        widget.onPhotoChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf seçilemedi')),
        );
      }
    }
  }

  Future<void> _deletePhoto() async {
    await _profileService.deleteProfilePhoto();
    if (mounted) {
      setState(() => _photoPath = null);
      widget.onPhotoChanged?.call();
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Profil Fotoğrafı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildOption(
                icon: PhosphorIconsDuotone.camera,
                label: 'Kameradan çek',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: PhosphorIconsDuotone.image,
                label: 'Galeriden seç',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null) ...[
                const SizedBox(height: 12),
                _buildOption(
                  icon: PhosphorIconsDuotone.trash,
                  label: 'Fotoğrafı kaldır',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _deletePhoto();
                  },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.editable ? _showOptions : null,
      child: Stack(
        children: [
          // Ana fotoğraf/ikon alanı
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _photoPath != null
                      ? Image.file(
                          File(_photoPath!),
                          fit: BoxFit.cover,
                          width: widget.size,
                          height: widget.size,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              PhosphorIconsDuotone.user,
                              size: widget.size * 0.48,
                              color: AppColors.primary,
                            );
                          },
                        )
                      : Icon(
                          PhosphorIconsDuotone.user,
                          size: widget.size * 0.48,
                          color: AppColors.primary,
                        ),
            ),
          ),
          // Düzenleme ikonu
          if (widget.editable)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: widget.size * 0.32,
                height: widget.size * 0.32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                child: Icon(
                  PhosphorIconsDuotone.camera,
                  size: widget.size * 0.16,
                  color: AppColors.background,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Küçük profil fotoğrafı (navigation bar için)
class SmallProfilePhoto extends StatefulWidget {
  final double size;

  const SmallProfilePhoto({
    super.key,
    this.size = 24,
  });

  @override
  State<SmallProfilePhoto> createState() => _SmallProfilePhotoState();
}

class _SmallProfilePhotoState extends State<SmallProfilePhoto> {
  final _profileService = ProfileService();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final path = await _profileService.getProfilePhotoPath();
    if (mounted) {
      setState(() => _photoPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_photoPath == null) {
      return const SizedBox.shrink(); // Fotoğraf yoksa boş döndür
    }

    return ClipOval(
      child: Image.file(
        File(_photoPath!),
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
