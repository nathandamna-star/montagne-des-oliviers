import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/auth_providers.dart';
import '../demandes_providers.dart';
import '../domain/demande.dart';
import 'libelles_demandes.dart';

/// Nouvelle demande ([type] pré-choisi facultatif).
class NouvelleDemandeScreen extends ConsumerStatefulWidget {
  const NouvelleDemandeScreen({super.key, this.type});

  final TypeDemande? type;

  @override
  ConsumerState<NouvelleDemandeScreen> createState() =>
      _NouvelleDemandeScreenState();
}

class _NouvelleDemandeScreenState extends ConsumerState<NouvelleDemandeScreen> {
  final _message = TextEditingController();
  late TypeDemande? _type = widget.type;
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final l10n = AppLocalizations.of(context);
    if (_type == null) {
      setState(() => _erreur = l10n.choisirTypeDemande);
      return;
    }
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final nom = ref.read(profilProvider).value?.nom;
    if (uid == null || nom == null) return;
    final messager = ScaffoldMessenger.of(context);
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      await ref
          .read(demandesRepositoryProvider)
          .creer(uid: uid, nom: nom, type: _type!, message: _message.text);
      messager.showSnackBar(SnackBar(content: Text(l10n.demandeEnvoyee)));
      if (mounted) context.pop();
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nouvelleDemande)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.typeDemandeQuestion,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              RadioGroup<TypeDemande>(
                groupValue: _type,
                onChanged: (t) => setState(() => _type = t),
                child: Column(
                  children: [
                    for (final t in TypeDemande.values)
                      RadioListTile<TypeDemande>(
                        value: t,
                        secondary: Icon(iconeDemande(t)),
                        title: Text(l10n.libelleDemande(t)),
                      ),
                  ],
                ),
              ),
              if (_erreur != null)
                Text(
                  _erreur!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _message,
                decoration: InputDecoration(
                  labelText: l10n.messageFacultatif,
                  helperText: l10n.messageDemandeAide,
                  helperMaxLines: 2,
                ),
                minLines: 4,
                maxLines: null,
                maxLength: 5000,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _occupe ? null : _envoyer,
                child: Text(l10n.envoyerDemande),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
