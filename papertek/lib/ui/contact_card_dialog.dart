import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/show_provider.dart';

/// Popup dialog for viewing and editing contact details for a named role.
class ContactCardDialog extends ConsumerStatefulWidget {
  const ContactCardDialog({
    super.key,
    required this.roleKey,
    required this.roleLabel,
    required this.personName,
  });

  final String roleKey;

  /// Display label of the role (e.g. "Lighting Designer").
  final String roleLabel;

  /// Current name value from show_meta (for display only).
  final String? personName;

  @override
  ConsumerState<ContactCardDialog> createState() => _ContactCardDialogState();
}

class _ContactCardDialogState extends ConsumerState<ContactCardDialog> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _userIdCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(roleContactRepoProvider);
    if (repo == null) {
      setState(() => _loaded = true);
      return;
    }
    final contact = await repo.getContact(widget.roleKey);
    if (!mounted) return;
    if (contact != null) {
      _emailCtrl.text = contact.email ?? '';
      _phoneCtrl.text = contact.phone ?? '';
      _addressCtrl.text = contact.mailingAddress ?? '';
      _userIdCtrl.text = contact.paperTekUserId ?? '';
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final repo = ref.read(roleContactRepoProvider);
    if (repo == null) return;
    await repo.upsertContact(
      roleKey: widget.roleKey,
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      mailingAddress: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      paperTekUserId:
          _userIdCtrl.text.trim().isEmpty ? null : _userIdCtrl.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.badge_outlined,
              size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.roleLabel,
                    style: theme.textTheme.titleMedium),
                if (widget.personName != null &&
                    widget.personName!.isNotEmpty)
                  Text(widget.personName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                      )),
              ],
            ),
          ),
        ],
      ),
      content: _loaded
          ? SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ContactField(
                    ctrl: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _ContactField(
                    ctrl: _phoneCtrl,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _ContactField(
                    ctrl: _addressCtrl,
                    label: 'Mailing Address',
                    icon: Icons.home_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _ContactField(
                    ctrl: _userIdCtrl,
                    label: 'PaperTek User ID',
                    icon: Icons.link,
                    helperText: 'Future cloud account linking',
                  ),
                ],
              ),
            )
          : const SizedBox(
              width: 360,
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loaded ? _save : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.helperText,
  });

  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        helperText: helperText,
      ),
    );
  }
}
