# Décisions

Une ligne par décision, la plus récente en bas. Ce qui est écrit ici n'est plus à rediscuter, sauf si Vespper le rouvre.

| Date | Sujet | Décision |
|---|---|---|
| 2026-11-23 | Moteur | Godot 4 (GDScript). Unity second choix, Unreal écarté. Raison : scènes et données en texte, éditables par Claude. |
| 2026-11-23 | Dépôt | GitHub (`Vespper/Gameproject`). |
| 2026-11-23 | Structure d'un run | Étages façon Isaac (salles sur une grille, on passe les portes), chaque porte annonce sa salle ou sa récompense (façon Hades). Mini-carte. |
| 2026-11-23 | Personnage | La moitié du plaisir. Selon les objets, central ou accessoire d'un run à l'autre. |
| 2026-11-23 | Objets | Peuvent tout modifier : personnage, tours, environnement, ennemis. |
| 2026-11-23 | Chemin des ennemis | Fixe dans une salle, généré procéduralement selon des règles (comme les salles d'Isaac). |
| 2026-11-23 | Préparation | Durée propre à chaque type de salle. |
| 2026-11-23 | Tours | Emportées d'une salle à l'autre. À tester : usage unique ou limité. |
| 2026-11-23 | Durée d'un run | 20 à 30 min au début, plus long avec les déblocages. |
| 2026-11-23 | Contrôles | Clavier + souris ; manette plus tard. |
| 2026-11-23 | Style | Grim dark mais lisible : décor sombre et désaturé, éléments de jeu colorés à silhouette nette. 2D ou 3D pas encore tranché. |
| 2026-11-23 | Méthode | Prototype gris d'une salle d'abord ; itérer pas à pas. |
| 2026-11-23 | Vagues | Un seul lancement, puis les vagues s'enchaînent seules avec une pause fixe (non contrôlée par le joueur) après la dernière apparition de chaque vague. |
| 2026-11-23 | PV | Les PV du run sont ceux du personnage : il en perd au contact d'un ennemi et à chaque ennemi qui atteint la sortie. La « base » n'est plus qu'une sortie. |
| 2026-11-23 | Attaque du personnage | Tir à distance vers la souris (au lieu de la mêlée), plus un sort à recharge. |
| 2026-11-23 | Pose des tours | Libre, partout hors du chemin (pas d'emplacements prédéfinis). |
| 2026-11-23 | Durée d'une salle | Viser 1 à 1,5 min de combat. Pour l'instant 3 vagues courtes avec 5 s de pause (2 vagues reste une option à tester). |
| 2026-11-23 | Tours en fin de salle | Démontées automatiquement à la victoire ; le joueur récupère une part de leur coût en énergie (50 % pour l'instant, réglable). Récupérer l'énergie en salle doit rester un peu risqué. |
| 2026-11-23 | Personnage de départ | Volontairement un peu faible (tir 8 dégâts / 0,3 s, sort 20 dégâts / 8 s) : il se renforcera pendant le run. |
