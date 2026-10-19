import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../actualites/actualites_providers.dart';
import '../../auth/auth_providers.dart';
import '../domain/groupe.dart';
import '../groupes_providers.dart';

/// Discussion privée d'un groupe.
class DiscussionScreen extends ConsumerStatefulWidget {
  const DiscussionScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends ConsumerState<DiscussionScreen> {
  final _texte = TextEditingController();
  bool _envoi = false;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  Future<void> _avecAttente(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _envoi = true);
    try {
      await action();
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.envoiEchoue)));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  Future<void> _envoyer({String? fichierUrl}) async {
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final nom = ref.read(profilProvider).value?.nom;
    if (uid == null || nom == null) return;
    final texte = fichierUrl == null ? _texte.text.trim() : '';
    if (texte.isEmpty && fichierUrl == null) return;
    await _avecAttente(() async {
      await ref
          .read(groupesRepositoryProvider)
          .envoyer(
            widget.id,
            uid: uid,
            nom: nom,
            texte: texte,
            fichierUrl: fichierUrl,
          );
      if (fichierUrl == null) _texte.clear();
    });
  }

  Future<void> _envoyerPhoto() async {
    await _avecAttente(() async {
      final url = await ref
          .read(envoiPhotosProvider)
          .choisirEtEnvoyer(
            'groupes/${widget.id}/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
      if (url != null) await _envoyer(fichierUrl: url);
    });
  }

  Future<void> _effacer(MessageGroupe m) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.effacerMessage),
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
    if (ok == true) {
      await ref.read(groupesRepositoryProvider).effacerMessage(widget.id, m.id);
    }
  }

  /// Appui long sur un message : effacer (auteur, administrateur du groupe),
  /// signaler ou bloquer son auteur (messages des autres).
  Future<void> _actions(MessageGroupe m, {required bool peutEffacer}) async {
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final moi = m.auteur == uid;
    final choix = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!moi) ...[
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(l10n.signalerMessage),
                onTap: () => Navigator.pop(context, 'signaler'),
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: Text(l10n.bloquerPersonne(m.nom)),
                onTap: () => Navigator.pop(context, 'bloquer'),
              ),
            ],
            if (peutEffacer)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.effacerLeMessage),
                onTap: () => Navigator.pop(context, 'effacer'),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (choix) {
      case 'signaler':
        await _signaler(m);
      case 'bloquer':
        await _bloquer(m);
      case 'effacer':
        await _effacer(m);
    }
  }

  Future<void> _signaler(MessageGroupe m) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    final texteMotif = await showDialog<String>(
      context: context,
      builder: (context) => const _DialogueSignalement(),
    );
    if (texteMotif == null) return;
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    if (uid == null) return;
    try {
      await ref
          .read(groupesRepositoryProvider)
          .signaler(
            groupeId: widget.id,
            groupeNom: ref.read(groupeProvider(widget.id)).value?.nom ?? '',
            message: m,
            motif: texteMotif,
            par: uid,
          );
      messager.showSnackBar(SnackBar(content: Text(l10n.messageSignale)));
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.envoiEchoue)));
    }
  }

  Future<void> _bloquer(MessageGroupe m) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bloquerPersonne(m.nom)),
        content: Text(l10n.bloquerTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.bloquer),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    if (uid == null) return;
    try {
      await ref.read(groupesRepositoryProvider).bloquer(uid, m.auteur);
      messager.showSnackBar(
        SnackBar(content: Text(l10n.personneBloquee(m.nom))),
      );
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.envoiEchoue)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final groupe = ref.watch(groupeProvider(widget.id)).value;
    // Les messages des personnes bloquées sont masqués.
    final bloques = ref.watch(bloquesProvider);
    final messages = [
      for (final m
          in ref.watch(messagesGroupeProvider(widget.id)).value ?? const [])
        if (!bloques.contains(m.auteur)) m,
    ];
    final admin = groupe?.estAdmin(uid) ?? false;

    // Discussion ouverte : tout est lu.
    final dernier = groupe?.dernierMessage?.le;
    if (dernier != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref
            .read(lecturesGroupesProvider.notifier)
            .marquerLu(widget.id, dernier),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(groupe?.nom ?? l10n.discussion)),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.aucunMessageGroupe,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final moi = m.auteur == uid;
                      final couleurTexte = moi
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface;
                      return Align(
                        alignment: moi
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: () =>
                              _actions(m, peutEffacer: moi || admin),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: moi
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerLowest,
                                border: moi
                                    ? null
                                    : Border.all(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!moi)
                                    Text(
                                      m.nom,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  if (m.fichierUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        m.fichierUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Icon(
                                          Icons.broken_image_outlined,
                                          color: couleurTexte,
                                        ),
                                      ),
                                    ),
                                  if (m.texte.isNotEmpty)
                                    // Texte simple : l'appui long ouvre les
                                    // actions (signaler, bloquer, effacer).
                                    Text(
                                      m.texte,
                                      style: TextStyle(color: couleurTexte),
                                    ),
                                  if (m.createdAt != null)
                                    Text(
                                      '${context.dateCourte(m.createdAt!)} ${context.heure(m.createdAt!)}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: couleurTexte.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_envoi) const LinearProgressIndicator(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.envoyerPhoto,
                    icon: const Icon(Icons.photo_outlined),
                    onPressed: _envoi ? null : _envoyerPhoto,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _texte,
                      decoration: InputDecoration(
                        hintText: l10n.ecrireMessage,
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 5000,
                      buildCounter: (
                        _, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    tooltip: l10n.envoyerMessage,
                    icon: const Icon(Icons.send),
                    onPressed: _envoi ? null : () => _envoyer(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Motif du signalement (facultatif) ; renvoie null si l'on annule.
class _DialogueSignalement extends StatefulWidget {
  const _DialogueSignalement();

  @override
  State<_DialogueSignalement> createState() => _DialogueSignalementState();
}

class _DialogueSignalementState extends State<_DialogueSignalement> {
  final _motif = TextEditingController();

  @override
  void dispose() {
    _motif.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.signalerMessage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.signalerTexte),
          const SizedBox(height: 12),
          TextField(
            key: const Key('motifSignalement'),
            controller: _motif,
            decoration: InputDecoration(labelText: l10n.motifSignalement),
            maxLength: 1000,
            maxLines: 3,
            minLines: 1,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _motif.text),
          child: Text(l10n.signaler),
        ),
      ],
    );
  }
}
