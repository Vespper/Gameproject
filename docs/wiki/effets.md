# Effets de statut

Les effets que tours, sorts et objets peuvent poser sur les ennemis (et peut-être, plus tard, sur le personnage). Page ouverte pour **faire la liste avant de coder** : rien n'est décidé sauf ce qui est 🎮.

Chaque effet doit se voir d'un coup d'œil sur l'ennemi (teinte, contour, petites particules), voir `docs/design/art-direction.md`.

## Effets

| Effet | Statut | Ce qu'il fait | Source possible | Lecture à l'écran |
|---|---|---|---|---|
| Ralentissement | 🎮 En jeu | Vitesse réduite (×0,5 pendant 2 s pour le Givre, ×0,4 pendant 2,5 s pour l'onde de givre). Le plus fort et le plus long l'emporte. | Tour Givre, sort onde de givre | Teinte bleu clair |
| Gel | 💡 Idée | Arrêt complet, court (~1 s). Se déclenche quand le ralentissement s'accumule (ex. 3 coups de givre). | Givre amélioré, objet | Bloc bleu-blanc |
| Immobilisation (racines) | 💡 Idée | Ne bouge plus mais reste ciblable et peut encore toucher le personnage au contact. | Tour piège, sort | Lianes / anneau au sol |
| Étourdissement | 💡 Idée | Ne bouge plus et n'utilise plus ses capacités (soin, bouclier…). | Mortier amélioré, objet | Étoiles au-dessus |
| Poison | 💡 Idée | Dégâts dans la durée qui se cumulent (piles). Bon contre les gros. | Tour Poison | Teinte verte, bulles |
| Brûlure (feu) | 💡 Idée | Dégâts dans la durée, forts mais courts, ne se cumulent pas (on rafraîchit). | Tour feu, objet | Flammes orange |
| Graisse | 💡 Idée | Léger ralentissement ; un ennemi graissé qui prend du feu s'embrase (brûlure ×2, se propage aux voisins graissés). | Tour ou flaque au sol | Teinte noire luisante, traînée |
| Mouillé | 💡 Idée | Éteint le feu ; le prochain gel est instantané ; l'électricité saute plus loin. | Flaque, sort | Gouttes bleues |
| Électrocution | 💡 Idée | Dégâts qui sautent sur 2 ou 3 ennemis proches. | Tour électrique | Éclair entre les cibles |
| Fragilité (marque) | 💡 Idée | +25 % de dégâts subis pendant quelques secondes. | Tir du personnage, objet | Cible rouge sur l'ennemi |
| Affaiblissement | 💡 Idée | Retire moins de PV au personnage (contact et sortie). | Objet, sort | Teinte grise |
| Recul | 💡 Idée | Renvoie l'ennemi en arrière sur le chemin. | Mortier, sort | Petit saut |
| Confusion | 💡 Idée | Marche à l'envers sur le chemin pendant 1 à 2 s. | Objet rare | Spirale |
| Saignement | 💡 Idée | Dégâts seulement quand l'ennemi avance (annulé par gel et immobilisation : choix intéressant). | Objet | Gouttes rouges au sol |

## Combos envisagés

| Combo | Résultat |
|---|---|
| Graisse + feu | Embrasement : brûlure doublée, se propage aux ennemis graissés voisins |
| Mouillé + gel | Gel instantané |
| Mouillé + électricité | L'éclair saute sur plus d'ennemis |
| Poison + feu | Nuage toxique à la mort de l'ennemi |
| Feu sur un ennemi gelé | Dégel immédiat, gros dégâts une fois |

## Résistances et immunités

Trois niveaux possibles, à choisir par ennemi et par effet :

- **Normal** : l'effet s'applique en entier.
- **Résistant** : durée ou force divisée par deux.
- **Immunisé** : l'effet ne prend pas (montrer un petit « immunisé » au premier coup, pour que le joueur comprenne).

Boss et élites : plutôt résistants qu'immunisés à tout, pour que les builds à effets restent utiles (ex. durée divisée par deux, et un gel qui ne peut pas se répéter avant 5 s).

## Questions ouvertes

- Combien d'effets au mini-run (jalon 4) ? Proposition : ralentissement, gel, poison, feu, graisse (3 tours + 1 combo à découvrir).
- Le personnage peut-il subir des effets (ennemis qui empoisonnent, flaque de graisse) ?
- Cumul : piles (poison) ou rafraîchissement (feu) selon l'effet, ou une seule règle pour tous ?
