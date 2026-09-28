import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_providers.dart';
import 'features/notifications/notifications_providers.dart';
import 'l10n/app_localizations.dart';

class MontagneDesOliviersApp extends ConsumerStatefulWidget {
  const MontagneDesOliviersApp({super.key});

  @override
  ConsumerState<MontagneDesOliviersApp> createState() =>
      _MontagneDesOliviersAppState();
}

class _MontagneDesOliviersAppState
    extends ConsumerState<MontagneDesOliviersApp> {
  StreamSubscription<Map<String, dynamic>>? _touchees;

  @override
  void initState() {
    super.initState();
    final notifications = ref.read(notificationsServiceProvider);
    // Toucher une notification ouvre l'annonce ou l'événement.
    _touchees = notifications.notificationsTouchees.listen((d) {
      final id = d['id'];
      if (id is! String) return;
      final router = ref.read(routerProvider);
      switch (d['type']) {
        case 'actualite':
          router.push(Routes.actualite(id));
        case 'evenement':
          router.push(Routes.evenement(id));
        case 'groupe':
          router.push(Routes.discussion(id));
        case 'demande':
          router.push(
            d['vue'] == 'gestion'
                ? Routes.gererDemande(id)
                : Routes.maDemande(id),
          );
        case 'priere':
          router.push(Routes.maPriere(id));
        case 'preparation':
          router.push(Routes.preparation(id));
        case 'candidat':
          final uid = d['uid'];
          if (uid is String) router.push(Routes.candidat(id, uid));
        case 'fete':
          router.push(Routes.fete(id));
        case 'rencontre':
          final rid = d['rid'];
          if (rid is String) router.push(Routes.rencontre(id, rid));
      }
    });
    // Annonces pour tous ; annonces des membres et jeton après connexion.
    ref.listenManual(utilisateurFirebaseProvider, (avant, apres) {
      final ancien = avant?.value?.uid;
      final nouveau = apres.value?.uid;
      if (ancien == nouveau && avant != null) return;
      if (ancien != null && nouveau == null) notifications.desactiver(ancien);
      notifications.activer(langue: _langue(), uid: nouveau);
    }, fireImmediately: true);
  }

  static String _langue() =>
      PlatformDispatcher.instance.locale.languageCode == 'nl' ? 'nl' : 'fr';

  @override
  void dispose() {
    _touchees?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair,
      darkTheme: AppTheme.sombre,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Néerlandais si le téléphone est en néerlandais, sinon français.
      localeResolutionCallback: (locale, supportees) {
        for (final l in supportees) {
          if (l.languageCode == locale?.languageCode) return l;
        }
        return const Locale('fr');
      },
    );
  }
}
