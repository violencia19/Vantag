import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:vantag/l10n/app_localizations.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).photoSelectError)));
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      backgroundColor: context.vantColors.surface,
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
                  color: context.vantColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.profilePhotoTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.vantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildOption(
                icon: CupertinoIcons.camera,
                label: l10n.takePhotoOption,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: CupertinoIcons.photo,
                label: l10n.chooseFromGalleryOption,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null) ...[
                const SizedBox(height: 12),
                _buildOption(
                  icon: CupertinoIcons.trash,
                  label: l10n.removePhotoOption,
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
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDestructive
                ? context.vantColors.error.withValues(alpha: 0.1)
                : context.vantColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? context.vantColors.error
                    : context.vantColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? context.vantColors.error
                      : context.vantColors.textPrimary,
                ),
              ),
            ],
          ),
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
              color: context.vantColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.vantColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.vantColors.primary,
                        ),
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
                          CupertinoIcons.person,
                          size: widget.size * 0.48,
                          color: context.vantColors.primary,
                        );
                      },
                    )
                  : Icon(
                      CupertinoIcons.person,
                      size: widget.size * 0.48,
                      color: context.vantColors.primary,
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
                  color: context.vantColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.vantColors.background,
                    width: 2,
                  ),
                ),
                child: Icon(
                  CupertinoIcons.camera,
                  size: widget.size * 0.16,
                  color: context.vantColors.background,
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

  const SmallProfilePhoto({super.key, this.size = 24});

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
