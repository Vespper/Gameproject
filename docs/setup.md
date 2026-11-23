# Poste de travail et commandes

## Machine de Vespper

- Windows. Disque système `F:`.
- **Godot 4.7.1** (version Standard, GDScript). Le projet s'ouvre via `project.godot`.
- **Blender** : `F:\Program Files\Blender Foundation\`.
- Clone local : `F:\godot-project\Gameproject`. Autres dossiers : `F:\godot-project\pong-godot` (essai), `F:\godot-project\Banque de son`.
- Git installé (`F:\Program Files\Git`).

## Lancer et tester

- Dans l'éditeur : **F5** lance le jeu, **F6** la scène ouverte.
- En ligne de commande (depuis le dossier du projet) :
  - Vérifier que tout se charge : `godot --headless --path . --quit`
  - Lancer un script de test : `godot --headless --path . -s res://tests/<test>.gd`
  - Importer les assets sans ouvrir l'éditeur : `godot --headless --path . --import`
- `godot` désigne l'exécutable Godot de la machine (sur Windows, le `.exe` téléchargé ; l'ajouter au PATH ou l'appeler avec son chemin complet).

## Récupérer une PR

Depuis `F:\godot-project\Gameproject` : `git fetch` puis `git checkout <branche>` (ou GitHub Desktop), puis rouvrir/rafraîchir dans Godot.
