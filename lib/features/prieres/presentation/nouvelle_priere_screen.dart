import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/auth_providers.dart';
import '../../parametres/parametres_eglise.dart';
import '../domain/priere.dart';
import '../prieres_providers.dart';

class NouvellePriereScreen extends ConsumerStatefulWidget {
  const NouvellePriereScreen({super.key});

  @override
  ConsumerState<NouvellePriereScreen> createState() =>
      _NouvellePriereScreenState();
}

class _NouvellePriereScreenState extends ConsumerState<NouvellePriereScreen> {
  final _texte = TextEditingController();
  PartagePriere _partage = PartagePriere.pasteurs;
  bool _anonyme = false;
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  Future<void> _envoyer(String? groupeIntercession) async {
    final l10n = AppLocalizations.of(context);
    if (_texte.text.trim().isEmpty) {
      setState(() => _erreur = l10n.champObligatoire);
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
      final partage = groupeIntercession == null
          ? PartagePriere.pasteurs
          : _partage;
      await ref
          .read(prieresRepositoryProvider)
          .creer(
            uid: uid,
            nom: nom,
            texte: _texte.text,
            anonyme: partage == PartagePriere.intercession && _anonyme,
            partage: partage,
            groupeId: groupeIntercession,
          );
      messager.showSnackBar(SnackBar(content: Text(l10n.sujetConfie)));
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
    final intercession = ref
        .watch(parametresEgliseProvider)
        .value
        ?.groupeIntercessionId;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nouveauSujet)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _texte,
                decoration: InputDecoration(
                  labelText: l10n.sujetPriereChamp,
                  errorText: _erreur,
                ),
                minLines: 4,
                maxLines: null,
                maxLength: 5000,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              Text(l10n.quiPeutLeLire, style: theme.textTheme.titleMedium),
              RadioGroup<PartagePriere>(
                groupValue: intercession == null
                    ? PartagePriere.pasteurs
                    : _partage,
                onChanged: (p) => setState(() => _partage = p ?? _partage),
                child: Column(
                  children: [
                    RadioListTile<PartagePriere>(
                      value: PartagePriere.pasteurs,
                      title: Text(l10n.partagePasteurs),
                      subtitle: Text(l10n.partagePasteursAide),
                    ),
                    RadioListTile<PartagePriere>(
                      value: PartagePriere.intercession,
                      enabled: intercession != null,
                      title: Text(l10n.partageIntercession),
                      subtitle: Text(
                        intercession == null
                            ? l10n.pasDeGroupeIntercession
                            : l10n.partageIntercessionAide,
                      ),
                    ),
                  ],
                ),
              ),
              if (intercession != null &&
                  _partage == PartagePriere.intercession)
                SwitchListTile(
                  title: Text(l10n.resterAnonyme),
                  subtitle: Text(l10n.resterAnonymeAide),
                  value: _anonyme,
                  onChanged: (v) => setState(() => _anonyme = v),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _occupe ? null : () => _envoyer(intercession),
                child: Text(l10n.confierSujet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
