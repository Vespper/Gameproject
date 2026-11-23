# Feuille de route

Mise à jour à chaque fin de session (skill `fin-de-session`). Garder ce fichier court : l'historique est dans git.

## Jalons

1. ✅ Mise en place du projet Godot
2. ✱ **Prototype gris d'une salle** (en cours) — question : jouer le personnage pendant la vague est-il amusant ?
3. ⬜ Plusieurs salles : portes, passage d'une salle à l'autre, récompense annoncée sur la porte
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

## Prochaine étape

Session de test de Vespper sur le prototype (F5) : noter le ressenti dans `docs/decisions.md`, puis équilibrer (les .tres dans `data/`).

## Journal

- 2026-11-23 : projet Godot créé (PR #1), documentation et agents en place.
- 2026-11-23 : prototype gris jouable d'une salle (chemin, base, 3 tours, 3 ennemis, 3 vagues, énergie à ramasser, mêlée + onde de givre). Test automatique : `tests/test_room_prototype.gd`.
- 2026-11-23 : retours de Vespper intégrés (vagues enchaînées, tir à distance, PV du personnage, pose libre, plus d'ennemis).
- 2026-11-23 : salle raccourcie (3 vagues courtes, ~45 s pour un joueur parfait), tours démontées en fin de salle avec 50 % du coût rendu.
- 2026-11-23 : salle plus petite (960 × 520, chemin ~25 % plus court), personnage de départ affaibli.
