import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/domain_traduction.dart';
import '../../shared/format_date.dart';
import '../../shared/widgets/champs_traduits.dart';
import '../auth/auth_providers.dart';
import '../groupes/domain/groupe.dart';
import '../parametres/parametres_eglise.dart';
import 'blocs_eglise.dart';

/// Administrateur : présentation de l'église, rencontre en direct de la
/// semaine et liens WhatsApp de la communauté.
class EditeurRubriquesScreen extends ConsumerStatefulWidget {
  const EditeurRubriquesScreen({super.key});

  @override
  ConsumerState<EditeurRubriquesScreen> createState() =>
      _EditeurRubriquesScreenState();
}

class _EditeurRubriquesScreenState
    extends ConsumerState<EditeurRubriquesScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _egliseFr = TextEditingController();
  final _egliseNl = TextEditingController();
  final _heure = TextEditingController();
  final _lien = TextEditingController();
  final _descFr = TextEditingController();
  final _descNl = TextEditingController();
  final _liens = <(TextEditingController, TextEditingController)>[];
  final _programme = <(TextEditingController, TextEditingController)>[];
  final _adresse = TextEditingController();
  final _telephone = TextEditingController();
  final _whatsapp = TextEditingController();
  int? _jour;
  bool _charge = false;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    ref.read(firestoreProvider).doc('parametres/eglise').get().then((d) {
      if (!mounted) return;
      final p = ParametresEglise.depuis(d.data());
      setState(() {
        _egliseFr.text = p.eglisePresentation['fr'] ?? '';
        _egliseNl.text = p.eglisePresentation['nl'] ?? '';
        _jour = p.interactionJour;
        _heure.text = p.interactionHeure;
        _lien.text = p.interactionLien;
        _descFr.text = p.interactionDescription['fr'] ?? '';
        _descNl.text = p.interactionDescription['nl'] ?? '';
        for (final (titre, horaire) in programmeEffectif(
          p,
          AppLocalizations.of(context),
        )) {
          _programme.add((
            TextEditingController(text: titre),
            TextEditingController(text: horaire),
          ));
        }
        _adresse.text = p.adresse;
        _telephone.text = p.telephone;
        _whatsapp.text = p.whatsappDirect;
        for (final (titre, url) in p.liensCommunaute) {
          _liens.add((
            TextEditingController(text: titre),
            TextEditingController(text: url),
          ));
        }
        _charge = true;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [_egliseFr, _egliseNl, _heure, _lien, _descFr, _descNl]) {
      c.dispose();
    }
    for (final (a, b) in [..._liens, ..._programme]) {
      a.dispose();
      b.dispose();
    }
    for (final c in [_adresse, _telephone, _whatsapp]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _valideLien(String? v) {
    final t = (v ?? '').trim();
    return t.isEmpty || lienAppelValide(t)
        ? null
        : AppLocalizations.of(context).lienInvalide;
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await enregistrerRubriques(
        ref.read(firestoreProvider),
        eglisePresentation: Traduction.ecrire(_egliseFr.text, _egliseNl.text)
          ..removeWhere((_, v) => v.isEmpty),
        interactionJour: _jour,
        interactionHeure: _heure.text,
        interactionLien: _lien.text,
        interactionDescription: Traduction.ecrire(_descFr.text, _descNl.text)
          ..removeWhere((_, v) => v.isEmpty),
        liensCommunaute: [
          for (final (titre, url) in _liens)
            if (url.text.trim().isNotEmpty) (titre.text, url.text),
        ],
        programme: [
          for (final (titre, horaire) in _programme)
            if (titre.text.trim().isNotEmpty) (titre.text, horaire.text),
        ],
        adresse: _adresse.text,
        telephone: _telephone.text,
        whatsappDirect: _whatsapp.text,
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
    final theme = Theme.of(context);
    // Noms des jours dans la langue de l'app (lundi = 1).
    final jours = DateFormat.EEEE(context.langue);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contenuEglise)),
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
                      Text(l10n.notreEglise, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ChampsTraduits(
                        libelle: l10n.presentation,
                        fr: _egliseFr,
                        nl: _egliseNl,
                        lignes: 8,
                        obligatoire: false,
                      ),
                      Text(
                        l10n.presentationEgliseAide,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.notreProgramme,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final (i, (titre, horaire)) in _programme.indexed)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: titre,
                                  decoration: InputDecoration(
                                    labelText: l10n.activite,
                                  ),
                                ),
                                TextFormField(
                                  controller: horaire,
                                  decoration: InputDecoration(
                                    labelText: l10n.horaire,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => setState(() {
                                      final (a, b) = _programme.removeAt(i);
                                      a.dispose();
                                      b.dispose();
                                    }),
                                    icon: const Icon(Icons.delete_outline),
                                    label: Text(l10n.retirer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => setState(
                          () => _programme.add((
                            TextEditingController(),
                            TextEditingController(),
                          )),
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.ajouterActivite),
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.nousTrouver, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _adresse,
                        decoration: InputDecoration(labelText: l10n.adresse),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _telephone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: l10n.telephone),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _whatsapp,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: l10n.whatsappDirect,
                          hintText: 'https://wa.me/32…',
                        ),
                        validator: _valideLien,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.rencontreDirect,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int?>(
                        initialValue: _jour,
                        decoration: InputDecoration(labelText: l10n.jour),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.aucun),
                          ),
                          for (var j = 1; j <= 7; j++)
                            DropdownMenuItem(
                              value: j,
                              // 1er janvier 2024 = lundi.
                              child: Text(jours.format(DateTime(2024, 1, j))),
                            ),
                        ],
                        onChanged: (v) => setState(() => _jour = v),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _heure,
                        decoration: InputDecoration(
                          labelText: l10n.heure,
                          hintText: '20:00',
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (_jour == null && t.isEmpty) return null;
                          return heureValide(t) ? null : l10n.heureInvalide;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lien,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: l10n.lienRencontre,
                          hintText: 'https://…',
                        ),
                        validator: _valideLien,
                      ),
                      const SizedBox(height: 8),
                      ChampsTraduits(
                        libelle: l10n.description,
                        fr: _descFr,
                        nl: _descNl,
                        lignes: 3,
                        obligatoire: false,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.communauteWhatsApp,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final (i, (titre, url)) in _liens.indexed)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: titre,
                                  decoration: InputDecoration(
                                    labelText: l10n.nomDuLien,
                                  ),
                                ),
                                TextFormField(
                                  controller: url,
                                  keyboardType: TextInputType.url,
                                  decoration: InputDecoration(
                                    labelText: l10n.lienWhatsApp,
                                    hintText: 'https://chat.whatsapp.com/…',
                                  ),
                                  validator: _valideLien,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => setState(() {
                                      final (a, b) = _liens.removeAt(i);
                                      a.dispose();
                                      b.dispose();
                                    }),
                                    icon: const Icon(Icons.delete_outline),
                                    label: Text(l10n.retirer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => setState(
                          () => _liens.add((
                            TextEditingController(),
                            TextEditingController(),
                          )),
                        ),
                        icon: const Icon(Icons.add_link),
                        label: Text(l10n.ajouterLien),
                      ),
                      const SizedBox(height: 24),
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
