import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'data/boutique_repository.dart';
import 'domain/boutique.dart';

final boutiqueRepositoryProvider = Provider<BoutiqueRepository>(
  (ref) => BoutiqueRepository(ref.watch(firestoreProvider)),
);

/// Tout le catalogue (y compris les livres épuisés).
final catalogueProvider = StreamProvider<List<Livre>>(
  (ref) => ref.watch(boutiqueRepositoryProvider).livres(),
);

final livreProvider = StreamProvider.family<Livre?, String>(
  (ref, id) => ref.watch(boutiqueRepositoryProvider).livre(id),
);

final mesCommandesProvider = StreamProvider<List<Commande>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(boutiqueRepositoryProvider).mesCommandes(uid);
});

final commandeProvider = StreamProvider.family<Commande?, String>(
  (ref, id) => ref.watch(boutiqueRepositoryProvider).commande(id),
);

final toutesCommandesProvider = StreamProvider<List<Commande>>(
  (ref) => ref.watch(boutiqueRepositoryProvider).toutesCommandes(),
);

/// Panier : livre → quantité (gardé tant que l'app est ouverte).
class Panier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  void ajouter(String livreId) =>
      state = {...state, livreId: ((state[livreId] ?? 0) + 1).clamp(1, 20)};

  void retirer(String livreId) {
    final q = (state[livreId] ?? 0) - 1;
    state = {
      for (final e in state.entries)
        if (e.key != livreId) e.key: e.value,
      if (q > 0) livreId: q,
    };
  }

  void vider() => state = const {};
}

final panierProvider = NotifierProvider<Panier, Map<String, int>>(Panier.new);
