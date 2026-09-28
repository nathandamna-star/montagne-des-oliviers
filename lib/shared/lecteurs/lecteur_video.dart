import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/preferences.dart';
import '../../l10n/app_localizations.dart';
import 'position.dart';

/// Lecteur vidéo : lecture, barre de progression, plein écran, reprise.
class LecteurVideo extends ConsumerStatefulWidget {
  const LecteurVideo({super.key, required this.url, required this.cle});

  final String url;
  final String cle;

  @override
  ConsumerState<LecteurVideo> createState() => _LecteurVideoState();
}

class _LecteurVideoState extends ConsumerState<LecteurVideo> {
  late final _controleur = VideoPlayerController.networkUrl(
    Uri.parse(widget.url),
  );
  late final _positions = PositionLecture(ref.read(sharedPreferencesProvider));
  var _pret = false;
  var _erreur = false;

  @override
  void initState() {
    super.initState();
    _controleur.initialize().then(
      (_) async {
        await _controleur.seekTo(_positions.lire(widget.cle));
        if (mounted) setState(() => _pret = true);
      },
      onError: (_) {
        if (mounted) setState(() => _erreur = true);
      },
    );
  }

  @override
  void dispose() {
    if (_pret) {
      _positions.ecrire(
        widget.cle,
        _controleur.value.position,
        _controleur.value.duration,
      );
    }
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_erreur) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.erreurLecture),
        ),
      );
    }
    if (!_pret) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _Video(
        controleur: _controleur,
        pleinEcran: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              body: Center(child: _Video(controleur: _controleur)),
            ),
          ),
        ),
      ),
    );
  }
}

class _Video extends StatelessWidget {
  const _Video({required this.controleur, this.pleinEcran});

  final VideoPlayerController controleur;
  final VoidCallback? pleinEcran;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AspectRatio(
      aspectRatio: controleur.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(controleur),
          ValueListenableBuilder(
            valueListenable: controleur,
            builder: (context, valeur, _) => Positioned.fill(
              child: Center(
                child: IconButton.filled(
                  iconSize: 36,
                  tooltip: valeur.isPlaying ? l10n.pause : l10n.lecture,
                  icon: Icon(valeur.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: valeur.isPlaying
                      ? controleur.pause
                      : controleur.play,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: VideoProgressIndicator(
                  controleur,
                  allowScrubbing: true,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              if (pleinEcran != null)
                IconButton(
                  tooltip: l10n.pleinEcran,
                  color: Colors.white,
                  icon: const Icon(Icons.fullscreen),
                  onPressed: pleinEcran,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
