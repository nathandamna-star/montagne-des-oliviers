import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../groupes/domain/groupe.dart';
import '../groupes/groupes_providers.dart';
import 'parametres_eglise.dart';

/// Administrateur : groupe d'intercession, Facebook, YouTube.
class ParametresEgliseScreen extends ConsumerStatefulWidget {
  const ParametresEgliseScreen({super.key});

  @override
  ConsumerState<ParametresEgliseScreen> createState() =>
      _ParametresEgliseScreenState();
}

class _ParametresEgliseScreenState
    extends ConsumerState<ParametresEgliseScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _facebook = TextEditingController();
  final _youtube = TextEditingController();
  final _email = TextEditingController();
  String? _intercession;
  String? _cuisine;
  bool _charge = false;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    ref.read(firestoreProvider).doc('parametres/eglise').get().then((d) {
      if (!mounted) return;
      final p = ParametresEglise.depuis(d.data());
      setState(() {
        _intercession = p.groupeIntercessionId;
        _cuisine = p.groupeCuisineId;
        _facebook.text = p.facebookUrl;
        _youtube.text = p.youtubeUrl;
        _email.text = p.emailContact;
        _charge = true;
      });
    });
  }

  @override
  void dispose() {
    _facebook.dispose();
    _youtube.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await enregistrerParametresEglise(
        ref.read(firestoreProvider),
        groupeIntercessionId: _intercession,
        groupeCuisineId: _cuisine,
        facebookUrl: _facebook.text,
        youtubeUrl: _youtube.text,
        emailContact: _email.text,
      );
      messager.showSnackBar(SnackBar(content: Text(l10n.enregistre)));
      if (mounted) context.pop();
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  String? _lien(String? v) {
    final t = (v ?? '').trim();
    return t.isEmpty || lienAppelValide(t)
        ? null
        : AppLocalizations.of(context).lienInvalide;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tous = ref.watch(tousGroupesProvider).value ?? const <Groupe>[];
    final groupes = [
      for (final g in tous)
        if (g.type == TypeGroupe.intercession) g,
    ];
    final cuisines = [
      for (final g in tous)
        if (g.type == TypeGroupe.cuisine) g,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parametresEglise)),
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
                      DropdownButtonFormField<String?>(
                        initialValue: groupes.any((g) => g.id == _intercession)
                            ? _intercession
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.groupeIntercessionChamp,
                          helperText: l10n.groupeIntercessionAide,
                          helperMaxLines: 3,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.aucun),
                          ),
                          for (final g in groupes)
                            DropdownMenuItem(value: g.id, child: Text(g.nom)),
                        ],
                        onChanged: (v) => setState(() => _intercession = v),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: cuisines.any((g) => g.id == _cuisine)
                            ? _cuisine
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.groupeCuisineChamp,
                          helperText: l10n.groupeCuisineAide,
                          helperMaxLines: 3,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.aucun),
                          ),
                          for (final g in cuisines)
                            DropdownMenuItem(value: g.id, child: Text(g.nom)),
                        ],
                        onChanged: (v) => setState(() => _cuisine = v),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _facebook,
                        decoration: InputDecoration(
                          labelText: l10n.pageFacebook,
                          hintText: 'https://www.facebook.com/…',
                        ),
                        keyboardType: TextInputType.url,
                        validator: _lien,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _youtube,
                        decoration: InputDecoration(
                          labelText: l10n.chaineYoutube,
                          hintText: 'https://www.youtube.com/@…',
                        ),
                        keyboardType: TextInputType.url,
                        validator: _lien,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: l10n.emailContact,
                          helperText: l10n.emailContactAide,
                          helperMaxLines: 3,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final t = (v ?? '').trim();
                          return t.isEmpty ||
                                  RegExp(r'^[^\s@]+@[^\s@]+\.[a-zA-Z]{2,}$')
                                      .hasMatch(t)
                              ? null
                              : l10n.emailInvalide;
                        },
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
