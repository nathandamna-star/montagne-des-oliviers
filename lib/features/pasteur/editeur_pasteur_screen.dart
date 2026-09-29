import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/domain_traduction.dart';
import '../../shared/widgets/champs_traduits.dart';
import '../actualites/actualites_providers.dart';
import '../auth/auth_providers.dart';
import '../parametres/parametres_eglise.dart';

/// Administrateur : nom, photo et présentation du pasteur principal.
class EditeurPasteurScreen extends ConsumerStatefulWidget {
  const EditeurPasteurScreen({super.key});

  @override
  ConsumerState<EditeurPasteurScreen> createState() =>
      _EditeurPasteurScreenState();
}

class _EditeurPasteurScreenState extends ConsumerState<EditeurPasteurScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _fr = TextEditingController();
  final _nl = TextEditingController();
  String? _photoUrl;
  bool _charge = false;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    ref.read(firestoreProvider).doc('parametres/eglise').get().then((d) {
      if (!mounted) return;
      final p = ParametresEglise.depuis(d.data());
      setState(() {
        _nom.text = p.pasteurNom;
        _fr.text = p.pasteurPresentation['fr'] ?? '';
        _nl.text = p.pasteurPresentation['nl'] ?? '';
        _photoUrl = p.pasteurPhotoUrl;
        _charge = true;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [_nom, _fr, _nl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _photo() async {
    final url = await ref
        .read(envoiPhotosProvider)
        .choisirEtEnvoyer(
          'parametres/pasteur-${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
    if (url != null && mounted) setState(() => _photoUrl = url);
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await enregistrerPasteur(
        ref.read(firestoreProvider),
        nom: _nom.text,
        photoUrl: _photoUrl,
        presentation: Traduction.ecrire(_fr.text, _nl.text),
      );
      messager.showSnackBar(SnackBar(content: Text(l10n.enregistre)));
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notrePasteur)),
      body: !_charge
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formulaire,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            foregroundImage: _photoUrl == null
                                ? null
                                : NetworkImage(_photoUrl!),
                            onForegroundImageError: _photoUrl == null
                                ? null
                                : (_, _) {},
                            child: const Icon(Icons.person, size: 40),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _photo,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: Text(l10n.photo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nom,
                        decoration: InputDecoration(labelText: l10n.champNom),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.presentation,
                        fr: _fr,
                        nl: _nl,
                        lignes: 10,
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
