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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final groupe = ref.watch(groupeProvider(widget.id)).value;
    final messages =
        ref.watch(messagesGroupeProvider(widget.id)).value ?? const [];
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
                          onLongPress: moi || admin ? () => _effacer(m) : null,
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
                                    SelectableText(
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
