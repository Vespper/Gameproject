# Poste de travail et commandes

## Machine de Vespper

- Windows. (chemins dans docs/setup.local.md)
- **Godot 4.7.1** (version Standard, GDScript). Le projet s'ouvre via `project.godot`.
- **Blender** : `<dossier de Blender>\`.
- Clone local : `<dossier du clone>`. Autres dossiers : `<autre projet>` (essai), `<dossier de sons>`.
- Git installé (`<dossier de Git>`).

## Lancer et tester

- Dans l'éditeur : **F5** lance le jeu, **F6** la scène ouverte.
- En ligne de commande (depuis le dossier du projet) :
  - Vérifier que tout se charge : `godot --headless --path . --quit`
  - Lancer un script de test : `godot --headless --path . -s res://tests/<test>.gd`
  - Importer les assets sans ouvrir l'éditeur : `godot --headless --path . --import`
- `godot` désigne l'exécutable Godot de la machine (sur Windows, le `.exe` téléchargé ; l'ajouter au PATH ou l'appeler avec son chemin complet).

## Récupérer une PR

Depuis `<dossier du clone>` : `git fetch` puis `git checkout <branche>` (ou GitHub Desktop), puis rouvrir/rafraîchir dans Godot.
