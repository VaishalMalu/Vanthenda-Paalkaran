import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/routing/app_routes.dart';

class VendorSetupScreen extends ConsumerStatefulWidget {
  const VendorSetupScreen({super.key});

  @override
  ConsumerState<VendorSetupScreen> createState() =>
      _VendorSetupScreenState();
}

class _VendorSetupScreenState
    extends ConsumerState<VendorSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  Uint8List? _logoBytes;
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _logoBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Not authenticated');

      String? logoUrl;
      if (_logoBytes != null) {
        final path = 'vendor-logos/$userId.jpg';
        await SupabaseService.client.storage
            .from('vendor-logos')
            .uploadBinary(path, _logoBytes!,
                fileOptions: const FileOptions(
                    contentType: 'image/jpeg', upsert: true));
        logoUrl = SupabaseService.client.storage
            .from('vendor-logos')
            .getPublicUrl(path);
      }

      // Create vendor profile
      await SupabaseService.client.from('vendors').upsert({
        'id': userId,
        'business_name': _businessNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        if (logoUrl != null) 'logo_url': logoUrl,
      });

      // Update user role
      await SupabaseService.client.rpc(
        'set_user_role',
        params: {'p_role': 'vendor'},
      );

      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Set Up Your Profile',
                  style: AppTypography.textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about your milk delivery business',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Logo picker
                Center(
                  child: GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: _logoBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.memory(_logoBytes!,
                                  fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined,
                                    color: AppColors.primary, size: 28),
                                const SizedBox(height: 4),
                                Text('Add Logo',
                                    style: AppTypography.textTheme.labelSmall
                                        ?.copyWith(
                                            color: AppColors.primary)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _businessNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Business Name',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Get Started'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
