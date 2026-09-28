import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/liens_legaux.dart';
import '../auth_providers.dart';
import 'message_erreur_auth.dart';

/// Après une connexion Google ou Apple : prénom et nom, et consentement
/// explicite avant de créer le profil.
class ConsentementScreen extends ConsumerStatefulWidget {
  const ConsentementScreen({super.key});

  @override
  ConsumerState<ConsentementScreen> createState() => _ConsentementScreenState();
}

class _ConsentementScreenState extends ConsumerState<ConsentementScreen> {
  final _formulaire = GlobalKey<FormState>();
  late final _nom = TextEditingController(
    text: ref.read(firebaseAuthProvider).currentUser?.displayName ?? '',
  );
  bool _consentement = false;
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final l10n = AppLocalizations.of(context);
    if (!_formulaire.currentState!.validate()) return;
    if (!_consentement) {
      setState(() => _erreur = l10n.consentementRequis);
      return;
    }
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .completerProfil(
            nom: _nom.text,
            langue: Localizations.localeOf(context).languageCode,
          );
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurAuth(l10n, e));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bienvenueFamille),
        actions: [
          TextButton(
            onPressed: () => ref.read(authRepositoryProvider).deconnexion(),
            child: Text(l10n.annuler),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formulaire,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.completerProfilIntro,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nom,
                  decoration: InputDecoration(labelText: l10n.champNom),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.validationNomRequis
                      : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _consentement,
                  onChanged: (v) => setState(() => _consentement = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.consentementTexte,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const LiensLegaux(
                  pages: [PageLegale.confidentialite, PageLegale.conditions],
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _erreur!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _occupe ? null : _valider,
                  child: Text(l10n.valider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
