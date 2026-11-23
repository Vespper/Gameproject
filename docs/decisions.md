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
| 2026-11-23 | Carte d'étage | Génération façon Isaac : grille, salles ajoutées seulement sur des cases à un seul voisin (branches et culs-de-sac), salles spéciales dans les culs-de-sac, boss dans le plus éloigné. Détails dans `docs/design/map.md`. |
| 2026-11-23 | Salles par étage | Toujours : départ, boss, trésor, boutique, secrète. Élite garantie dès l'étage 2. Atelier ou repos. Le reste : combats. |
| 2026-11-23 | Vider l'étage | Pas obligatoire : on peut contourner des salles, on rate alors leur énergie et leur récompense. |
| 2026-11-23 | Monnaie | Une seule : l'énergie, pour tout le run (pose des tours, boutique, atelier). L'or est abandonné. |
| 2026-11-23 | Tours emportées | Ce qui suit le joueur, ce sont ses types de tours. Départ avec l'Archer seul. 3 emplacements de types ; au-delà il faut en remplacer un, sauf objet qui ajoute un emplacement. |
| 2026-11-23 | Salle secrète | Pas de bombes : mur fissuré ouvert en tirant dessus. |
