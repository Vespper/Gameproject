# Ennemis

Rôles lisibles : chaque ennemi a une forme et une couleur propres. Stats 🎮 recopiées de `data/enemies/*.tres` (prototype).

« Dégâts sortie » : PV perdus par le personnage quand l'ennemi atteint la sortie. « Contact » : PV perdus au contact du personnage.

| Ennemi | Statut | Rôle | PV | Vitesse | Dégâts sortie | Contact | Énergie lâchée | Forme |
|---|---|---|---|---|---|---|---|---|
| Rôdeur (`grunt`) | 🎮 En jeu | Ennemi de base | 40 | 85 | 1 | 1 | 8 | Cercle rouge |
| Coureur (`runner`) | 🎮 En jeu | Rapide et fragile | 18 | 160 | 1 | 1 | 5 | Triangle orange |
| Brute (`brute`) | 🎮 En jeu | Lent et résistant | 150 | 60 | 3 | 2 | 25 | Carré violet |
| Volant | 💡 Idée | Ne suit pas le chemin : vole en ligne droite (ou en légère vague) de l'entrée à la sortie, donc plus court. Insensible aux effets au sol (graisse, flaques). Certaines tours ne peuvent pas le toucher (mortier ?) | — | — | — | — | — | — |
| Diviseur | 💡 Idée | Se sépare en petits ennemis à sa mort | — | — | — | — | — | — |
| Soigneur | 💡 Idée | Soigne les ennemis proches | — | — | — | — | — | — |
| Chasseur | 💡 Idée | Quitte le chemin pour attaquer le personnage | — | — | — | — | — | — |
| Saboteur | 💡 Idée | Attaque les tours | — | — | — | — | — | — |
| Blindé | 💡 Idée | Armure : chaque coup perd quelques dégâts (fort contre les tours rapides, faible contre le mortier) | — | — | — | — | — | — |
| Salamandre | 💡 Idée | Immunisée au feu et à la brûlure, résistante au gel | — | — | — | — | — | — |
| Golem de pierre | 💡 Idée | Immunisé au poison et au saignement, lent | — | — | — | — | — | — |
| Spectre | 💡 Idée | Immunisé au ralentissement, au gel et à l'immobilisation ; fragile | — | — | — | — | — | — |
| Fouisseur | 💡 Idée | Passe sous terre sur une partie du chemin : impossible à cibler pendant ce temps | — | — | — | — | — | — |
| Porte-bouclier | 💡 Idée | Protège les ennemis proches d'un effet (ex. immunité au gel tant qu'il vit) | — | — | — | — | — | — |

Les immunités et résistances sont décrites dans [Effets](effets.md). Proposition : un ennemi a au plus une ou deux immunités, toujours visibles sur sa forme ou sa couleur.

## Élites et boss

Chaque élite ou boss ajoute une mécanique. Aucun n'est encore conçu.

| Nom | Statut | Mécanique |
|---|---|---|
| — | 💡 Idée | Boss qui ouvre un second chemin en cours de combat |
| — | 💡 Idée | Élite blindée : immunisée aux ralentissements |
