import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Un texte en français (obligatoire) et sa traduction néerlandaise
/// (facultative : sinon le français est affiché).
class ChampsTraduits extends StatelessWidget {
  const ChampsTraduits({
    super.key,
    required this.libelle,
    required this.fr,
    required this.nl,
    this.lignes = 1,
    this.obligatoire = true,
  });

  final String libelle;
  final TextEditingController fr;
  final TextEditingController nl;
  final int lignes;
  final bool obligatoire;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: fr,
          decoration: InputDecoration(labelText: '$libelle (FR)'),
          minLines: lignes,
          maxLines: lignes == 1 ? 1 : null,
          textCapitalization: TextCapitalization.sentences,
          validator: (v) => obligatoire && (v ?? '').trim().isEmpty
              ? l10n.champObligatoire
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nl,
          decoration: InputDecoration(
            labelText: '$libelle (NL)',
            helperText: l10n.traductionFacultative,
          ),
          minLines: lignes,
          maxLines: lignes == 1 ? 1 : null,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
