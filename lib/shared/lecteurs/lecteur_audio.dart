import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/preferences.dart';
import '../../l10n/app_localizations.dart';
import 'lecteurs.dart';
import 'position.dart';

/// Lecteur audio : lecture, avance/recul de 15 s, vitesse, reprise là où on
/// s'était arrêté. Continue écran verrouillé (session audio « musique »).
class LecteurAudio extends ConsumerStatefulWidget {
  const LecteurAudio({super.key, required this.url, required this.cle});

  final String url;
  final String cle;

  @override
  ConsumerState<LecteurAudio> createState() => _LecteurAudioState();
}

class _LecteurAudioState extends ConsumerState<LecteurAudio> {
  final _lecteur = AudioPlayer();
  late final _positions = PositionLecture(ref.read(sharedPreferencesProvider));
  Timer? _sauvegarde;
  var _erreur = false;

  @override
  void initState() {
    super.initState();
    _preparer();
    _sauvegarde = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _enregistrerPosition(),
    );
  }

  Future<void> _preparer() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _lecteur.setUrl(
        widget.url,
        initialPosition: _positions.lire(widget.cle),
      );
    } catch (_) {
      if (mounted) setState(() => _erreur = true);
    }
  }

  void _enregistrerPosition() =>
      _positions.ecrire(widget.cle, _lecteur.position, _lecteur.duration);

  @override
  void dispose() {
    _sauvegarde?.cancel();
    _enregistrerPosition();
    _lecteur.dispose();
    super.dispose();
  }

  void _deplacer(Duration ecart) {
    final duree = _lecteur.duration ?? Duration.zero;
    var cible = _lecteur.position + ecart;
    if (cible < Duration.zero) cible = Duration.zero;
    if (duree > Duration.zero && cible > duree) cible = duree;
    _lecteur.seek(cible);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (_erreur) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.erreurLecture),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<Duration?>(
          stream: _lecteur.durationStream,
          builder: (context, dureeSnap) {
            final duree = dureeSnap.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _lecteur.positionStream,
              builder: (context, positionSnap) {
                var position = positionSnap.data ?? Duration.zero;
                if (position > duree) position = duree;
                return Column(
                  children: [
                    Slider(
                      value: duree.inMilliseconds == 0
                          ? 0
                          : position.inMilliseconds / duree.inMilliseconds,
                      onChanged: duree == Duration.zero
                          ? null
                          : (v) => _lecteur.seek(duree * v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuree(position),
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          formatDuree(duree),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: l10n.reculer15,
                          icon: const Icon(Icons.replay_10),
                          onPressed: () =>
                              _deplacer(const Duration(seconds: -15)),
                        ),
                        const SizedBox(width: 12),
                        StreamBuilder<PlayerState>(
                          stream: _lecteur.playerStateStream,
                          builder: (context, etat) {
                            final joue = etat.data?.playing ?? false;
                            final charge =
                                etat.data?.processingState ==
                                    ProcessingState.loading ||
                                etat.data?.processingState ==
                                    ProcessingState.buffering;
                            return IconButton.filled(
                              iconSize: 40,
                              tooltip: joue ? l10n.pause : l10n.lecture,
                              icon: charge
                                  ? const SizedBox.square(
                                      dimension: 40,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Icon(joue ? Icons.pause : Icons.play_arrow),
                              onPressed: joue
                                  ? () {
                                      _lecteur.pause();
                                      _enregistrerPosition();
                                    }
                                  : _lecteur.play,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: l10n.avancer15,
                          icon: const Icon(Icons.forward_10),
                          onPressed: () =>
                              _deplacer(const Duration(seconds: 15)),
                        ),
                        const SizedBox(width: 12),
                        StreamBuilder<double>(
                          stream: _lecteur.speedStream,
                          builder: (context, vitesse) =>
                              PopupMenuButton<double>(
                                tooltip: l10n.vitesse,
                                initialValue: vitesse.data ?? 1,
                                onSelected: _lecteur.setSpeed,
                                itemBuilder: (_) => [
                                  for (final v in [0.75, 1.0, 1.25, 1.5])
                                    PopupMenuItem(value: v, child: Text('×$v')),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text('×${vitesse.data ?? 1}'),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
