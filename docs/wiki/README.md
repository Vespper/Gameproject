# Wiki du jeu

Le catalogue de tout ce qui existe ou pourrait exister dans le jeu : salles, tours, ennemis, objets, personnages. On le complète au fur et à mesure, idées comprises.

Les règles générales restent dans `docs/design/gdd.md` et `docs/design/map.md` ; ici, on liste le **contenu**, une entrée par élément.

## Pages

| Page | Contenu |
|---|---|
| [Salles](salles.md) | Types de salles d'un étage |
| [Tours](tours.md) | Types de tours et leurs stats |
| [Ennemis](ennemis.md) | Ennemis, élites, boss |
| [Objets](objets.md) | Objets et synergies |
| [Personnages](personnages.md) | Personnages jouables et leurs sorts |
| [Effets](effets.md) | Effets de statut (gel, poison, feu…), combos, résistances |

## Statuts

| Statut | Sens |
|---|---|
| 💡 Idée | Juste une idée, rien de décidé. On peut en ajouter librement. |
| 📐 Conçu | Règles décidées (dans le GDD, `map.md` ou `decisions.md`), pas encore dans le jeu. |
| 🎮 En jeu | Existe dans le jeu ou le prototype. Les stats viennent de `data/*.tres`. |

## Règles pour tenir le wiki

- Une entrée = un nom, un statut, une phrase de rôle (à quoi ça sert pour le joueur), puis les détails.
- Les stats d'une entrée 🎮 sont **recopiées de `data/`** : la source de vérité reste le fichier `.tres`. Quand on change une valeur dans Godot, on met la ligne du wiki à jour dans la même PR.
- Une idée qui n'est plus retenue : on la barre avec la raison, plutôt que de l'effacer.
- Les identifiants (nom du fichier `.tres`) sont en anglais, le reste en français.
