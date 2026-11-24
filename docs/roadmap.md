# Feuille de route

Mise à jour à chaque fin de session (skill `fin-de-session`). Garder ce fichier court : l'historique est dans git.

## Jalons

1. ✅ Mise en place du projet Godot
2. ✱ **Prototype gris d'une salle** (en cours) — question : jouer le personnage pendant la vague est-il amusant ?
3. ✱ Plusieurs salles : portes, passage d'une salle à l'autre, récompense annoncée sur la porte
4. ⬜ Mini-run : un étage de 8 à 10 salles, 3 types de salles (combat, boutique, boss), 10 à 15 objets avec quelques synergies — question : a-t-on envie de relancer ?
5. ⬜ Vertical slice : un étage complet avec le style final, sons, interface, un boss
6. ⬜ Production : 3 à 4 étages, 60 à 100 objets, plusieurs personnages, méta-progression

## Jalon 2 — prototype d'une salle (formes simples, pas de graphismes)

Chaque étape = une PR testable avec F5.

- [x] Salle : un sol, un chemin fixe (`Path2D`), une entrée ennemie, une base avec des PV
- [x] Un ennemi qui suit le chemin et retire des PV à la base en arrivant
- [x] Une tour posée à la souris (librement, hors du chemin), qui vise et tire
- [x] Le personnage : déplacement ZQSD/WASD, tir à distance, PV (contact et ennemis qui passent)
- [x] Vagues : 3 vagues définies dans `data/`, un seul lancement puis enchaînement, victoire / défaite
- [x] Énergie : les ennemis en lâchent, le personnage la ramasse, elle sert à poser des tours
- [x] 3 types de tours, 3 types d'ennemis, 1 sort à recharge pour le personnage
- [ ] Session de test : noter le ressenti dans `docs/decisions.md`

## Jalon 3 — plusieurs salles

- [x] Étage généré (5 salles pour l'instant), portes visibles en entrant (1 à 4), passage d'une salle à l'autre, mini-carte
- [x] Chemin des ennemis généré au hasard dans chaque salle
- [x] PV et énergie conservés d'une salle à l'autre
- [x] Économie resserrée : remboursement 25 %, moins d'énergie par ennemi, coût +30 % par tour posée dans la salle
- [x] Personnage de base en données (`data/characters/base.tres`), stats visibles dans le HUD, départ avec l'Archer seul
- [x] Trésor (objet gratuit) et boutique (objets, type de tour, soin) dans l'étage (7 salles), 11 objets de statistique
- [x] Coût des tours en salle : +35 % par tour (au lieu de +30 %)
- [ ] Récompense annoncée sur la porte (objet, énergie, type de tour, soin)
- [ ] Salle de boss (à concevoir : le cul-de-sac le plus éloigné lui est déjà réservé)
- [ ] Liste des effets de statut et des archétypes d'ennemis validée par Vespper (`docs/wiki/effets.md`)

## Prochaine étape

Test de Vespper (F5) : trésor et boutique, prix, effet des objets sur les stats affichées, difficulté avec l'Archer seul au départ. Puis concevoir la salle de boss, ou la récompense annoncée sur la porte.

## Journal

- 2026-11-23 : prototype gris jouable d'une salle (chemin, base, 3 tours, 3 ennemis, 3 vagues, énergie à ramasser, mêlée + onde de givre). Test automatique : `tests/test_room_prototype.gd`.
- 2026-11-23 : retours de Vespper intégrés (vagues enchaînées, tir à distance, PV du personnage, pose libre, plus d'ennemis).
- 2026-11-23 : salle raccourcie (3 vagues courtes, ~45 s pour un joueur parfait), tours démontées en fin de salle avec 50 % du coût rendu.
- 2026-11-23 : salle plus petite (960 × 520, chemin ~25 % plus court), personnage de départ affaibli.
- 2026-11-23 : carte d'étage conçue (`docs/design/map.md`) : génération façon Isaac, salles par étage, énergie seule monnaie, 3 emplacements de types de tours.
- 2026-11-23 : chemins de la machine retirés du dépôt (fichiers locaux ignorés), scripts `tools/check.sh`, `tools/test.sh`, `tools/run.sh`.
- 2026-11-24 : enchaînement de salles : étage de 5 salles, portes, chemin généré, PV et énergie conservés, mini-carte. Tests `test_run.gd` et `test_floor_and_paths.gd`. Liste d'effets et d'archétypes proposée dans le wiki (idées).
- 2026-11-24 : économie resserrée après le test de Vespper (trop de tours dès la 2e salle).
- 2026-11-24 : personnage de base en données avec stats affichées, trésor, boutique, 11 objets, étage de 7 salles, coût des tours +35 % par tour. Test `test_shop_and_treasure.gd`.
