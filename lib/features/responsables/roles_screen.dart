import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../auth/data/fonctions_roles.dart';
import '../auth/domain/role.dart';
import '../profil/libelles_roles.dart';

/// Administrateur : attribuer ou retirer les rôles d'un compte (par e-mail).
class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _roles = <Role>{};
  bool _occupe = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    if (!_formulaire.currentState!.validate()) return;
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await ref.read(fonctionsRolesProvider).definirRoles(_email.text, {
        ..._roles,
      });
      messager.showSnackBar(
        SnackBar(content: Text(l10n.rolesEnregistres(_email.text.trim()))),
      );
    } on ErreurRoles catch (e) {
      messager.showSnackBar(
        SnackBar(
          content: Text(switch (e.code) {
            'introuvable' => l10n.rolesCompteIntrouvable,
            'refuse' => l10n.rolesRefuse,
            'reseau' => l10n.erreurReseau,
            _ => l10n.erreurInconnue,
          }),
        ),
      );
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.rolesTitre)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formulaire,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.rolesAide, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: l10n.champEmail),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (v) =>
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch((v ?? '').trim())
                      ? null
                      : l10n.validationEmail,
                ),
                const SizedBox(height: 16),
                for (final r in Role.values)
                  CheckboxListTile(
                    value: _roles.contains(r),
                    onChanged: (v) => setState(
                      () => v == true ? _roles.add(r) : _roles.remove(r),
                    ),
                    title: Text(l10n.libelleRole(r)),
                    subtitle: Text(switch (r) {
                      Role.admin => l10n.roleAdminAide,
                      Role.secretariat => l10n.roleSecretariatAide,
                      Role.tresorier => l10n.roleTresorierAide,
                    }),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _occupe ? null : _enregistrer,
                  child: Text(l10n.enregistrer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
