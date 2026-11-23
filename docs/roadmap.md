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

- [ ] Salle : un sol, un chemin fixe (`Path2D`), une entrée ennemie, une base avec des PV
- [ ] Un ennemi qui suit le chemin et retire des PV à la base en arrivant
- [ ] Une tour posée à la souris sur un emplacement, qui vise et tire
- [ ] Le personnage : déplacement ZQSD/WASD, attaque de mêlée
- [ ] Vagues : 3 vagues définies dans `data/`, bouton « lancer la vague », victoire / défaite
- [ ] Énergie : les ennemis en lâchent, le personnage la ramasse, elle sert à poser des tours
- [ ] 3 types de tours, 3 types d'ennemis, 1 sort à recharge pour le personnage
- [ ] Session de test : noter le ressenti dans `docs/decisions.md`

## Prochaine étape

Construire la salle de base (premier point de la liste ci-dessus).

## Journal

- 2026-11-23 : projet Godot créé (PR #1), documentation et agents en place.
- 2026-11-23 : carte d'étage conçue (`docs/design/map.md`) : génération façon Isaac, salles par étage, énergie seule monnaie, 3 emplacements de types de tours.
