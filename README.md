# Gameproject

Mon premier jeu vidéo : un **tower defense roguelike** fait avec **Godot 4**.

## Le concept en bref

- On avance **de salle en salle**, comme dans *The Binding of Isaac*.
- Dans chaque salle, on pose des tours pour repousser des vagues d'ennemis.
- Les **portes** de sortie annoncent la récompense qui attend derrière : à chaque salle, on choisit son chemin.
- Ambiance **grim dark mais lisible** : décors sombres et désaturés, éléments de jeu (tours, ennemis, projectiles) colorés avec des silhouettes bien nettes.

## Ouvrir le projet sous Windows

1. Télécharger **Godot 4** (version *Standard*, pas *.NET*) sur <https://godotengine.org/download/windows/>. Le projet est prévu pour Godot 4.5 ou plus récent (Vespper utilise la 4.7.1).
2. Dézipper le fichier et lancer `Godot_v4.x-stable_win64.exe` (pas d'installation nécessaire).
3. Récupérer le projet sur l'ordinateur, au choix :
   - avec **GitHub Desktop** : *File → Clone repository* puis choisir `Gameproject` ;
   - ou en ligne de commande : `git clone https://github.com/Vespper/Gameproject.git` ;
   - ou sans Git : bouton vert *Code → Download ZIP* sur GitHub, puis dézipper.
4. Dans le gestionnaire de projets de Godot : **Importer**, puis sélectionner le fichier `project.godot` à la racine du dossier.
5. Le projet s'ouvre dans l'éditeur. Appuyer sur **F5** (ou le bouton ▶ en haut à droite) pour lancer le jeu : un écran sombre avec « Gameproject — ça marche ! » doit apparaître.

> La première ouverture crée un dossier `.godot/` : c'est un cache, il est ignoré par Git, c'est normal.

## Organisation des dossiers

```
assets/          Tout ce qui est « média », importé tel quel
  sprites/       Images, spritesheets
  audio/music/   Musiques
  audio/sfx/     Bruitages
  fonts/         Polices
  shaders/       Effets visuels (.gdshader)
scenes/          Les scènes Godot (.tscn), avec leur script (.gd) à côté
  main/          Scène de démarrage du jeu
  rooms/         Les salles
  towers/        Les tours
  enemies/       Les ennemis
  ui/            Menus, interface (HUD)
scripts/         Scripts qui ne sont pas liés à une scène précise
  autoload/      Scripts globaux toujours chargés (état de la partie, etc.)
data/            Données du jeu (stats des tours, récompenses…) en ressources .tres
docs/            Documentation (design, architecture, feuille de route)
```

Règle simple : **une scène et son script vivent dans le même dossier** (par exemple `scenes/towers/archer_tower.tscn` et `scenes/towers/archer_tower.gd`). Les fichiers sont nommés en `snake_case` (minuscules et tirets bas).

Les fichiers `.gitkeep` servent juste à garder les dossiers vides dans Git ; on peut les supprimer quand le dossier contient autre chose.

## Documentation

- [Feuille de route et prochaine étape](docs/roadmap.md)
- [Game design](docs/design/gdd.md) · [Direction artistique](docs/design/art-direction.md)
- [Architecture](docs/architecture.md) · [Conventions](docs/conventions.md) · [Poste de travail](docs/setup.md)
- [Décisions prises](docs/decisions.md)

## Travailler avec Claude Code

`CLAUDE.md` est volontairement court : il indique quel fichier de `docs/` lire selon la tâche, pour ne pas recharger tout le contexte à chaque session.

- Agents (`.claude/agents/`) : `godot-dev` pour le code et les scènes, `game-designer` pour les règles et l'équilibrage.
- Skills (`.claude/skills/`) : `/prochaine-etape` pour reprendre le travail, `/fin-de-session` pour mettre à jour la feuille de route avant de partir.
