import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../format_date.dart';
import '../services/lanceur.dart';

enum PageLegale { confidentialite, conditions, aide }

/// Page légale publiée sur le site de l'église, dans la langue de l'app.
Uri adressePageLegale(PageLegale page, String langue) => Uri.parse(
  'https://montagne-des-oliviers.web.app/legal/${page.name}'
  '${langue == 'nl' ? '?langue=nl' : ''}',
);

extension LibellesPagesLegales on AppLocalizations {
  String pageLegale(PageLegale p) => switch (p) {
    PageLegale.confidentialite => politiqueConfidentialite,
    PageLegale.conditions => conditionsUtilisation,
    PageLegale.aide => aideEtContact,
  };
}

/// Liens vers la politique de confidentialité, les conditions et l'aide.
class LiensLegaux extends ConsumerWidget {
  const LiensLegaux({super.key, this.pages = PageLegale.values});

  final List<PageLegale> pages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (final p in pages)
          TextButton(
            onPressed: () => ref
                .read(lanceurProvider)
                .ouvrir(adressePageLegale(p, context.langue)),
            child: Text(l10n.pageLegale(p)),
          ),
      ],
    );
  }
}
