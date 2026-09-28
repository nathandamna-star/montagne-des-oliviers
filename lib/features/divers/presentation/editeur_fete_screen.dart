import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/horloge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../auth/auth_providers.dart';
import '../divers_providers.dart';
import '../domain/fete.dart';
import 'libelles_divers.dart';

/// Annoncer (« nouvelle ») ou modifier une fête.
class EditeurFeteScreen extends ConsumerStatefulWidget {
  const EditeurFeteScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditeurFeteScreen> createState() => _EditeurFeteScreenState();
}

class _EditeurFeteScreenState extends ConsumerState<EditeurFeteScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _lieu = TextEditingController();
  final _description = TextEditingController();
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _occupe = false;
  TypeFete _type = TypeFete.anniversaire;
  late DateTime _date;
  Fete? _existante;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(diversRepositoryProvider);
    _nouvelle = widget.id == 'nouvelle';
    _id = _nouvelle ? repo.nouvelId() : widget.id;
    final n = ref.read(horlogeProvider)();
    // Par défaut : samedi prochain, 15 h.
    final jours = (DateTime.saturday - n.weekday) % 7;
    _date = DateTime(n.year, n.month, n.day + (jours == 0 ? 7 : jours), 15);
    if (_nouvelle) {
      _charge = true;
    } else {
      repo.lire(_id).then((f) {
        if (!mounted || f == null) return;
        setState(() {
          _existante = f;
          _titre.text = f.titre;
          _lieu.text = f.lieu;
          _description.text = f.description;
          _type = f.type;
          _date = f.date;
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _titre.dispose();
    _lieu.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final jour = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (jour == null || !mounted) return;
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (heure == null) return;
    setState(
      () => _date = DateTime(
        jour.year,
        jour.month,
        jour.day,
        heure.hour,
        heure.minute,
      ),
    );
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final nom = ref.read(profilProvider).value?.nom;
    if (uid == null || nom == null) return;
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      final f = Fete(
        id: _id,
        titre: _titre.text,
        type: _type,
        date: _date,
        lieu: _lieu.text,
        description: _description.text,
        uid: _existante?.uid ?? uid,
        nom: _existante?.nom ?? nom,
      );
      final repo = ref.read(diversRepositoryProvider);
      await (_nouvelle ? repo.creer(f) : repo.modifier(f));
      messager.showSnackBar(SnackBar(content: Text(l10n.enregistre)));
      if (mounted) context.pop();
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _supprimer() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supprimerFete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.supprimer),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(diversRepositoryProvider).supprimer(_id);
    if (mounted) context.pop();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_nouvelle ? l10n.annoncerFete : l10n.modifier),
        actions: [
          if (!_nouvelle)
            IconButton(
              tooltip: l10n.supprimer,
              onPressed: _supprimer,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
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
                      DropdownButtonFormField<TypeFete>(
                        initialValue: _type,
                        decoration: InputDecoration(
                          labelText: l10n.typeEvenementChamp,
                        ),
                        items: [
                          for (final t in TypeFete.values)
                            DropdownMenuItem(
                              value: t,
                              child: Text(l10n.libelleFete(t)),
                            ),
                        ],
                        onChanged: (t) => setState(() => _type = t ?? _type),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titre,
                        decoration: InputDecoration(
                          labelText: l10n.champTitre,
                          hintText: l10n.titreFeteAide,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(l10n.dateEtHeure),
                        subtitle: Text(
                          '${context.dateLongue(_date)}, ${context.heure(_date)}',
                        ),
                        trailing: const Icon(Icons.edit_calendar_outlined),
                        onTap: _choisirDate,
                      ),
                      TextFormField(
                        controller: _lieu,
                        decoration: InputDecoration(labelText: l10n.lieu),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _description,
                        decoration: InputDecoration(
                          labelText: l10n.champDescription,
                        ),
                        minLines: 2,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _occupe ? null : _enregistrer,
                        child: Text(
                          _nouvelle ? l10n.annoncer : l10n.enregistrer,
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
