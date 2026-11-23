# Poste de travail et commandes

Les chemins propres à une machine (où est installé Godot, Blender, le clone) ne sont **pas** versionnés : ils vont dans `docs/setup.local.md` et `tools/local.env`, ignorés par git.

## Première installation

1. Godot 4.7 (version *Standard*, GDScript). Sous Windows, garder aussi la version **console** (`..._console.exe`, même dossier) : c'est elle qu'utilisent les scripts.
2. Copier `tools/local.env.example` en `tools/local.env` et y mettre le chemin de Godot (console).
3. Copier `docs/setup.local.example.md` en `docs/setup.local.md` et le remplir (chemins, outils installés).

## Scripts (`tools/`)

Scripts bash : sous Windows, les lancer depuis **Git Bash** (installé avec Git). Ils n'affichent que l'essentiel (erreurs, résultats).

| Commande | Rôle |
|---|---|
| `tools/check.sh` | Importe le projet et charge tous les scripts : affiche les erreurs avec fichier et ligne, sinon « OK ». |
| `tools/test.sh` | Lance les tests automatiques `tests/test_*.gd` en headless et affiche leur ligne « Résultat ». |
| `tools/test.sh tests/x.gd -- passive` | Un seul test, avec des arguments passés au test. |
| `tools/run.sh` | Lance le jeu (ou une scène : `tools/run.sh res://scenes/…tscn`). |

Godot est trouvé dans cet ordre : variable `GODOT`, puis `tools/local.env`, puis `godot` / `godot4` dans le PATH.

## Dans l'éditeur

**F5** lance le jeu, **F6** la scène ouverte.

## Récupérer une PR

Dans le dossier du clone : `git fetch` puis `git checkout <branche>` (ou GitHub Desktop), puis revenir dans Godot.
