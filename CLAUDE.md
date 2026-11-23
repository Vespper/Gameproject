# Gameproject — mémo pour Claude

Roguelike tower defense en **Godot 4.7 / GDScript**, premier jeu de Vespper. On avance de salle en salle (étages façon Isaac, portes qui annoncent la récompense), on pose des tours, et le personnage combat pendant les vagues.

Réponds et documente **en français**. Code (identifiants) en anglais, commentaires en français.

## Charger seulement ce qui sert

Ne lis pas tout `docs/` d'office. Ouvre le fichier utile à la tâche :

| Besoin | Fichier |
|---|---|
| Où on en est, tâche suivante | `docs/roadmap.md` |
| Règles du jeu, systèmes, salles, objets | `docs/design/gdd.md` |
| Carte d'étage, types de salles, économie d'énergie | `docs/design/map.md` |
| Catalogue du contenu (salles, tours, ennemis, objets, personnages) et ses stats | `docs/wiki/` (commencer par `README.md`) |
| Style visuel, palette, lisibilité | `docs/design/art-direction.md` |
| Organisation du code, scènes, données | `docs/architecture.md` |
| Style GDScript, nommage, git | `docs/conventions.md` |
| Poste de travail, commandes | `docs/setup.md` (chemins de la machine : `docs/setup.local.md`, non versionné) |
| Décisions déjà prises (ne pas les rediscuter) | `docs/decisions.md` |

## Règles qui s'appliquent toujours

- Itérer pas à pas : une petite étape jouable à la fois, une PR par étape.
- Prouver qu'**une salle** est amusante avant carte, objets ou style final.
- Données de jeu dans `data/*.tres` (Resources), pas en dur dans le code.
- Quand on ajoute ou change du contenu (tour, ennemi, salle, objet, personnage), mettre à jour sa ligne dans `docs/wiki/` dans la même PR.
- Une scène et son script dans le même dossier, fichiers en `snake_case`.
- Ne jamais committer `.godot/` ni éditer `project.godot` à la main sans raison.
- Vespper teste dans l'éditeur (F5) : décrire à chaque PR quoi tester et quoi ressentir.
- Fin de session : lancer la skill `fin-de-session` pour mettre à jour `docs/roadmap.md` (et `docs/decisions.md` si une décision a été prise).

## Scripts (préférer à des commandes Godot écrites à la main)

- `tools/check.sh` : erreurs de script (fichier et ligne), sinon « OK ». À lancer après chaque modification de `.gd`, `.tscn` ou `.tres`.
- `tools/test.sh` : tests headless `tests/test_*.gd`, n'affiche que les résultats.
- `tools/run.sh` : lance le jeu.

Une commande répétée plusieurs fois ou à la sortie trop longue mérite un script dans `tools/` : l'ajouter et le lister ici.

## Données privées

Le dépôt est public : aucun chemin de la machine, nom de dossier personnel ou identifiant dans les fichiers versionnés. Ils vont dans `docs/setup.local.md` ou `tools/local.env`.

## Agents

- `godot-dev` : écrire ou corriger scènes et GDScript.
- `game-designer` : règles, équilibrage, contenu (tours, ennemis, objets), mise à jour du GDD.
