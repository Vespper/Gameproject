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
| 2026-11-23 | Carte d'étage | Génération façon Isaac : grille, salles ajoutées seulement sur des cases à un seul voisin (branches et culs-de-sac), salles spéciales dans les culs-de-sac, boss dans le plus éloigné. Détails dans `docs/design/map.md`. |
| 2026-11-23 | Salles par étage | Toujours : départ, boss, trésor, boutique, secrète. Élite garantie dès l'étage 2. Atelier ou repos. Le reste : combats. |
| 2026-11-23 | Vider l'étage | Pas obligatoire : on peut contourner des salles, on rate alors leur énergie et leur récompense. |
| 2026-11-23 | Monnaie | Une seule : l'énergie, pour tout le run (pose des tours, boutique, atelier). L'or est abandonné. |
| 2026-11-23 | Tours emportées | Ce qui suit le joueur, ce sont ses types de tours. Départ avec l'Archer seul. 3 emplacements de types ; au-delà il faut en remplacer un, sauf objet qui ajoute un emplacement. |
| 2026-11-23 | Salle secrète | Pas de bombes : mur fissuré ouvert en tirant dessus. |
