import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_providers.dart';
import 'data/groupes_repository.dart';
import 'domain/groupe.dart';

final groupesRepositoryProvider = Provider<GroupesRepository>(
  (ref) => GroupesRepository(ref.watch(firestoreProvider)),
);

final mesGroupesProvider = StreamProvider<List<Groupe>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(groupesRepositoryProvider).mesGroupes(uid);
});

/// Groupes ouverts dont la personne n'est pas (encore) membre.
final autresGroupesProvider = StreamProvider<List<Groupe>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null || ref.watch(profilProvider).value == null) {
    return Stream.value(const []);
  }
  return ref
      .watch(groupesRepositoryProvider)
      .ouverts()
      .map(
        (l) => [
          for (final g in l)
            if (!g.estMembre(uid)) g,
        ],
      );
});

final tousGroupesProvider = StreamProvider<List<Groupe>>(
  (ref) => ref.watch(groupesRepositoryProvider).tous(),
);

final groupeProvider = StreamProvider.family<Groupe?, String>(
  (ref, id) => ref.watch(groupesRepositoryProvider).groupe(id),
);

final messagesGroupeProvider =
    StreamProvider.family<List<MessageGroupe>, String>(
      (ref, id) => ref.watch(groupesRepositoryProvider).messages(id),
    );

/// uid → nom de tous les comptes (membres connectés seulement).
final annuaireProvider = StreamProvider<Map<String, String>>((ref) {
  if (ref.watch(profilProvider).value == null) return Stream.value(const {});
  return ref.watch(groupesRepositoryProvider).annuaire();
});

/// Dernière lecture de chaque discussion, gardée sur le téléphone
/// (pour la pastille des messages non lus).
class LecturesGroupes extends Notifier<Map<String, int>> {
  static const _prefixe = 'lu_groupe_';

  @override
  Map<String, int> build() {
    _charger();
    return const {};
  }

  Future<void> _charger() async {
    final p = await SharedPreferences.getInstance();
    state = {
      for (final k in p.getKeys())
        if (k.startsWith(_prefixe))
          k.substring(_prefixe.length): p.getInt(k) ?? 0,
    };
  }

  Future<void> marquerLu(String groupeId, DateTime le) async {
    final ms = le.millisecondsSinceEpoch;
    if ((state[groupeId] ?? 0) >= ms) return;
    state = {...state, groupeId: ms};
    final p = await SharedPreferences.getInstance();
    await p.setInt('$_prefixe$groupeId', ms);
  }
}

final lecturesGroupesProvider =
    NotifierProvider<LecturesGroupes, Map<String, int>>(LecturesGroupes.new);

/// Vrai si le dernier message du groupe est d'un autre et pas encore lu.
final nonLuProvider = Provider.family<bool, Groupe>((ref, g) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  final dm = g.dernierMessage;
  if (dm == null || dm.auteur == uid) return false;
  final lu = ref.watch(lecturesGroupesProvider)[g.id] ?? 0;
  return dm.le.millisecondsSinceEpoch > lu;
});
