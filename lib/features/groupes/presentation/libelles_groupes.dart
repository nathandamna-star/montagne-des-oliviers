import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/groupe.dart';
import '../domain/rencontre.dart';

extension LibellesGroupes on AppLocalizations {
  String libelleTypeGroupe(TypeGroupe t) => switch (t) {
    TypeGroupe.cellule => groupeCellule,
    TypeGroupe.intercession => groupeIntercession,
    TypeGroupe.jeunes => groupeJeunes,
    TypeGroupe.femmes => groupeFemmes,
    TypeGroupe.hommes => groupeHommes,
    TypeGroupe.louange => groupeLouange,
    TypeGroupe.moderation => groupeModeration,
    TypeGroupe.media => groupeMedia,
    TypeGroupe.entraide => groupeEntraide,
    TypeGroupe.autre => groupeAutre,
  };
}

IconData iconeGroupe(TypeGroupe t) => switch (t) {
  TypeGroupe.cellule => Icons.home_outlined,
  TypeGroupe.intercession => Icons.volunteer_activism_outlined,
  TypeGroupe.jeunes => Icons.bolt_outlined,
  TypeGroupe.femmes => Icons.woman_outlined,
  TypeGroupe.hommes => Icons.man_outlined,
  TypeGroupe.louange => Icons.music_note_outlined,
  TypeGroupe.moderation => Icons.record_voice_over_outlined,
  TypeGroupe.media => Icons.videocam_outlined,
  TypeGroupe.entraide => Icons.handshake_outlined,
  TypeGroupe.autre => Icons.groups_outlined,
};

extension LibellesRencontres on AppLocalizations {
  String libelleRencontre(TypeRencontre t) => switch (t) {
    TypeRencontre.reunion => rencontreReunion,
    TypeRencontre.repetition => rencontreRepetition,
    TypeRencontre.moderation => rencontreModeration,
    TypeRencontre.appel => rencontreAppel,
  };

  String libelleReponse(Reponse r) => switch (r) {
    Reponse.oui => reponseOui,
    Reponse.non => reponseNon,
    Reponse.peutetre => reponsePeutEtre,
  };
}

IconData iconeRencontre(TypeRencontre t) => switch (t) {
  TypeRencontre.reunion => Icons.groups_outlined,
  TypeRencontre.repetition => Icons.music_note_outlined,
  TypeRencontre.moderation => Icons.record_voice_over_outlined,
  TypeRencontre.appel => Icons.call_outlined,
};
