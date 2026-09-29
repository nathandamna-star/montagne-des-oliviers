import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/format_date.dart';
import '../../shared/services/lanceur.dart';
import '../../shared/widgets/etat_vide.dart';
import '../../shared/widgets/liens_legaux.dart';
import '../auth/auth_providers.dart';
import '../eglise/blocs_eglise.dart';
import 'contact.dart';

extension LibellesContact on AppLocalizations {
  String sujetContact(SujetContact s) => switch (s) {
    SujetContact.priere => themePriere,
    SujetContact.delivrance => themeDelivrance,
    SujetContact.guerison => themeGuerison,
    SujetContact.accompagnement => sujetAccompagnement,
    SujetContact.question => sujetQuestionDirect,
    SujetContact.autre => themeAutre,
  };
}

/// « Nous contacter » : chacun, même sans compte, écrit sa situation et
/// laisse ses coordonnées ; un pasteur le recontacte.
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key, this.sujet});

  final String? sujet;

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _telephone = TextEditingController();
  final _message = TextEditingController();
  late SujetContact _sujet =
      SujetContact.values.where((s) => s.name == widget.sujet).firstOrNull ??
      SujetContact.accompagnement;
  bool _consentement = false;
  bool _occupe = false;
  bool _envoye = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    final user = ref.read(utilisateurFirebaseProvider).value;
    _nom.text = ref.read(profilProvider).value?.nom ?? user?.displayName ?? '';
    _email.text = user?.email ?? '';
  }

  @override
  void dispose() {
    for (final c in [_nom, _email, _telephone, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _envoyer() async {
    final l10n = AppLocalizations.of(context);
    if (!_formulaire.currentState!.validate()) return;
    if (_email.text.trim().isEmpty && _telephone.text.trim().isEmpty) {
      setState(() => _erreur = l10n.contactCoordonneesRequises);
      return;
    }
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
          .read(contactRepositoryProvider)
          .envoyer(
            nom: _nom.text,
            email: _email.text,
            telephone: _telephone.text,
            sujet: _sujet,
            message: _message.text,
            uid: ref.read(utilisateurFirebaseProvider).value?.uid,
          );
      if (mounted) setState(() => _envoye = true);
    } catch (_) {
      if (mounted) setState(() => _erreur = l10n.erreurInconnue);
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nousContacter)),
      body: _envoye
          ? EtatVide(
              icone: Icons.mark_email_read_outlined,
              texte: l10n.contactMerci,
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formulaire,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(l10n.contactIntro, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      Text(
                        l10n.contactSujet,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in SujetContact.values)
                            ChoiceChip(
                              label: Text(l10n.sujetContact(s)),
                              selected: _sujet == s,
                              onSelected: (_) => setState(() => _sujet = s),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _message,
                        minLines: 5,
                        maxLines: 12,
                        maxLength: 3000,
                        decoration: InputDecoration(
                          labelText: l10n.contactMessage,
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      TextFormField(
                        controller: _nom,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(labelText: l10n.champNom),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: l10n.email),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _telephone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: l10n.telephone),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _consentement,
                        onChanged: (v) =>
                            setState(() => _consentement = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          l10n.contactConsentement,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const LiensLegaux(pages: [PageLegale.confidentialite]),
                      if (_erreur != null)
                        Text(
                          _erreur!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _occupe ? null : _envoyer,
                        icon: const Icon(Icons.send),
                        label: Text(l10n.envoyer),
                      ),
                      const SizedBox(height: 24),
                      const NousTrouver(),
                      const SizedBox(height: 12),
                      const WhatsAppDirect(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// Pasteurs : messages reçus par « Nous contacter ».
class MessagesRecusScreen extends ConsumerStatefulWidget {
  const MessagesRecusScreen({super.key});

  @override
  ConsumerState<MessagesRecusScreen> createState() =>
      _MessagesRecusScreenState();
}

class _MessagesRecusScreenState extends ConsumerState<MessagesRecusScreen> {
  bool _tous = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid ?? '';
    final messages = [
      for (final m in ref.watch(messagesContactProvider).value ?? const [])
        if (_tous || !m.traite) m,
    ];
    final lanceur = ref.read(lanceurProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.messagesRecus)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l10n.aTraiter)),
              ButtonSegment(value: true, label: Text(l10n.tous)),
            ],
            selected: {_tous},
            onSelectionChanged: (s) => setState(() => _tous = s.first),
          ),
          const SizedBox(height: 8),
          if (messages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.aucunMessage, textAlign: TextAlign.center),
            ),
          for (final m in messages)
            Card(
              child: ExpansionTile(
                leading: Icon(
                  m.traite ? Icons.check_circle : Icons.mark_email_unread,
                  color: m.traite ? null : theme.colorScheme.primary,
                ),
                title: Text('${l10n.sujetContact(m.sujet)} · ${m.nom}'),
                subtitle: m.createdAt == null
                    ? null
                    : Text(context.dateLongue(m.createdAt!)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(m.message),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (m.email.isNotEmpty)
                        ActionChip(
                          avatar: const Icon(Icons.email_outlined),
                          label: Text(m.email),
                          onPressed: () => lanceur.ouvrir(
                            Uri(scheme: 'mailto', path: m.email),
                          ),
                        ),
                      if (m.telephone.isNotEmpty)
                        ActionChip(
                          avatar: const Icon(Icons.phone_outlined),
                          label: Text(m.telephone),
                          onPressed: () => lanceur.ouvrir(
                            Uri(scheme: 'tel', path: m.telephone),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(contactRepositoryProvider)
                        .marquerTraite(m.id, traite: !m.traite, par: uid),
                    child: Text(
                      m.traite ? l10n.remettreATraiter : l10n.marquerTraite,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
