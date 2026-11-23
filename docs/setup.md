# Poste de travail et commandes

## Machine de Vespper

- Windows. Disque système `F:`.
- **Godot 4.7.1** (version Standard, GDScript) : `F:\Program Files (x86)\Godot_v4.7.1-stable\Godot_v4.7.1-stable_win64.exe`. Version console (affiche les erreurs dans le terminal, à utiliser en ligne de commande) : `Godot_v4.7.1-stable_win64_console.exe` dans le même dossier. Le projet s'ouvre via `project.godot`.
- **Blender** : `F:\Program Files\Blender Foundation\`.
- Clone local : `F:\godot-project\Gameproject`. Autres dossiers : `F:\godot-project\pong-godot` (essai), `F:\godot-project\Banque de son`.
- Git installé (`F:\Program Files\Git`).

## Lancer et tester

- Dans l'éditeur : **F5** lance le jeu, **F6** la scène ouverte.
- En ligne de commande (depuis le dossier du projet) :
  - Vérifier que tout se charge : `godot --headless --path . --quit`
  - Lancer un script de test : `godot --headless --path . -s res://tests/<test>.gd`
  - Importer les assets sans ouvrir l'éditeur : `godot --headless --path . --import`
- `godot` désigne la version console de Godot. Sous Windows (PowerShell) : `& "F:\Program Files (x86)\Godot_v4.7.1-stable\Godot_v4.7.1-stable_win64_console.exe" --headless --path . --quit`, ou ajouter ce dossier au PATH.

## Récupérer une PR

Depuis `F:\godot-project\Gameproject` : `git fetch` puis `git checkout <branche>` (ou GitHub Desktop), puis rouvrir/rafraîchir dans Godot.
