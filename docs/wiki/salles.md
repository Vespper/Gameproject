# Salles

Règles de génération et présence par étage : `docs/design/map.md`.

| Salle | Statut | Rôle | Présence par étage |
|---|---|---|---|
| Combat | 🎮 En jeu (prototype) | Vagues d'ennemis, récompense annoncée sur la porte | Le reste des salles |
| Départ | 🎮 En jeu (prototype) | Point d'entrée, vide (tutoriel à l'étage 1) | 1 |
| Boss | 📐 Conçu | Fin d'étage, objet de boss, ouvre l'étage suivant | 1, cul-de-sac le plus éloigné |
| Trésor | 📐 Conçu | Un objet gratuit, sans combat | 1 |
| Boutique | 📐 Conçu | Achat en énergie : objets, types de tours, soin | 1 |
| Élite (mini-boss) | 📐 Conçu | Combat dur avec un ennemi spécial, objet rare garanti | Possible à l'étage 1, garantie dès l'étage 2 |
| Atelier | 📐 Conçu | Amélioration permanente d'un type de tour, en énergie | 1 chance sur 2 (sinon Repos) |
| Repos | 📐 Conçu | Soin du personnage | Si pas d'Atelier |
| Secrète | 📐 Conçu | Récompense généreuse, derrière un mur fissuré | 1, cachée |
| Puzzle | 💡 Idée | Peu de tours, placement exact | — |
| Événement | 💡 Idée | Texte et choix risqué, parfois une malédiction | — |
| Défi | 💡 Idée | Combat avec une contrainte (pas de tour d'un type, chrono…) pour une meilleure récompense | — |

## Combat (prototype)

Salle grise du prototype :

- Un chemin généré au hasard (graine de la salle) de l'entrée ennemie, collée à un mur latéral, à la sortie près du mur opposé ; tours posées librement hors du chemin et loin des portes.
- Règles du chemin (`scripts/floor/path_generator.gd`) : segments horizontaux et verticaux sur une grille de 80 px, toujours vers la sortie, 2 à 4 virages espacés d'au moins 2 cases, longueur entre 1 400 et 2 000 px, entrée et sortie loin du milieu des murs (portes).
- Une porte par côté relié sur la carte (1 à 4), avec le type de la salle derrière. Fermées dès qu'on entre dans un combat, ouvertes une fois la salle nettoyée.
- 3 vagues courtes qui s'enchaînent seules (5 s de pause), environ 1 min de combat.
- 100 d'énergie au départ ; les ennemis en lâchent, à ramasser.
- Chaque tour posée dans la salle augmente de 30 % le coût des suivantes (Archer : 40, 52, 64, 76…).
- Victoire : tours démontées, 25 % de ce qu'elles ont coûté rendu en énergie.

| Vague | Contenu (`data/waves/`) |
|---|---|
| 1 | 10 Rôdeurs, puis 4 Coureurs |
| 2 | 12 Rôdeurs, 8 Coureurs, 1 Brute |
| 3 | 14 Rôdeurs, 10 Coureurs, 3 Brutes |

Récompenses possibles sur la porte : objet commun, paquet d'énergie, nouveau type de tour, soin.
