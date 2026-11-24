# Tours

On possède des **types** de tours (3 emplacements, plus avec certains objets) ; en salle, on pose autant de tours de ces types que l'énergie le permet. Le personnage de base commence avec l'Archer seul. Voir `docs/design/map.md`.

Stats des tours 🎮 recopiées de `data/towers/*.tres` (prototype). Cadence en tirs par seconde, portée et vitesses en pixels.

| Tour | Statut | Rôle | Coût | Prix boutique | Dégâts | Cadence | Portée | Effet |
|---|---|---|---|---|---|---|---|---|
| Archer (`archer`) | 🎮 En jeu | Tir simple, tour de départ | 40 | — | 12 | 1,5 | 170 | — |
| Givre (`frost`) | 🎮 En jeu | Ralentit les groupes | 50 | 80 | 4 | 1,2 | 140 | Ralentit à 50 % pendant 2 s |
| Mortier (`mortar`) | 🎮 En jeu | Dégâts de zone, lent | 70 | 100 | 20 | 0,5 | 160 | Explosion de rayon 70 |
| Poison | 💡 Idée | Dégâts dans la durée, bon contre les gros | — | — | — | — | — | — |
| Mur / bloqueur | 💡 Idée | Retient les ennemis sur le chemin | — | — | — | — | — | — |
| Support | 💡 Idée | Renforce les tours voisines (cadence, portée) | — | — | — | — | — | — |

Vitesse des projectiles : Archer 650, Givre 500, Mortier 380.

Le run commence avec l'Archer seul. Le Givre et le Mortier s'achètent à la boutique (« Prix boutique », `shop_price`), dans la limite des emplacements (3).

Le coût indiqué est le coût de base : dans une salle, chaque tour posée rend les suivantes 35 % plus chères (`tower_cost_increase` de la salle). À la fin de la salle, les tours rendent 25 % de ce qu'elles ont coûté (stat `tower_refund` du personnage, l'objet Recyclage la monte). Les objets de tours (Carquois, Pierre à aiguiser, Lentille) multiplient dégâts, cadence et portée de toutes les tours posées.

## Questions ouvertes

- Améliorations d'atelier : par niveau (+X % dégâts) ou par branche (choisir un effet) ?
