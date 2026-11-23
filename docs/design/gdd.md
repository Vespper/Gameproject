# Game design (résumé)

Version texte condensée du document de concept ([GDD v0](https://claude.ai/artifact/QVn8uuKYssgFuPWyfCP6eg)). Les choix fermés sont dans `docs/decisions.md`.

## Pitch

Un roguelike où chaque salle est un petit tower defense. On avance de salle en salle, on pose ses tours, puis on se bat à leurs côtés pendant les vagues. Comme dans *The Binding of Isaac*, les objets transforment les tours et se combinent : deux runs ne se ressemblent jamais.

## Boucles

- **Salle (2 à 5 min)** : entrée (on découvre le plan : entrées ennemies, chemin, emplacements constructibles) → préparation (poser et déplacer les tours, aperçu de la vague) → vagues (lancer tôt donne un bonus ; les tours tirent seules, le personnage bouge, frappe, lance ses sorts) → récompense (choix parmi 2 ou 3).
- **Run (20 à 30 min)** : 3 étages de 8 à 12 salles sur une grille (voir `docs/design/map.md`). Chaque porte montre ce qu'il y a derrière. Pas obligé de tout vider ; retour possible dans les salles nettoyées. Les types de tours suivent le personnage (3 emplacements). Le boss ouvre l'étage suivant. Fin du run quand la base tombe ou au boss final.
- **Méta-progression (plus tard, hors MVP)** : débloquer du contenu, pas de la puissance. Paliers de difficulté façon Ascension, bestiaire, encyclopédie.

## Contre le côté passif

Salles courtes (1 à 2 min de combat), bonus pour lancer tôt, butin à aller ramasser au milieu des ennemis, ennemis qui visent le personnage ou les tours, construction en plein combat avec l'énergie gagnée, accélération x2 pendant les moments calmes.

## Personnage

Les tours font le gros des dégâts ; le personnage réagit : achever, ralentir un groupe, réparer une tour. Attaque de mêlée + 2 à 3 sorts à recharge (pas de mana). Il peut mourir dans la salle et réapparaît après quelques secondes ; c'est la base qui porte les PV du run. Plus tard : plusieurs personnages (mage qui renforce les tours, guerrier qui tient une ligne, ingénieur qui construit vite).

## Tours

4 à 6 types de base : tir simple, zone, ralentissement, poison, mur/bloqueur, support. Stats comparables aux larmes d'Isaac : dégâts, cadence, portée, vitesse du projectile, nombre de projectiles, effet. Portée des objets à trancher : toutes les tours, une tour choisie, ou un type de tour.

## Objets

| Famille | Exemple | Effet |
|---|---|---|
| Statistique | +20 % de cadence | Un chiffre |
| Comportement | Projectiles qui rebondissent sur 2 ennemis | La façon de jouer |
| Synergie | Poison + explosion : les empoisonnés explosent en mourant | Les combos mémorables |

Technique : modificateurs empilables, chaque objet ajoute une règle au pipeline de tir (voir `docs/architecture.md`).

## Ennemis

Des rôles lisibles : rapide, blindé, volant (ignore les murs), qui se divise, soigneur, qui attaque les tours ou le personnage. Élites et boss ajoutent chacun une mécanique.

## Salles

Détail de la carte et de la présence de chaque salle par étage : `docs/design/map.md`. Puzzle et Événement sont mis en réserve.

| Salle | Contenu | Récompense |
|---|---|---|
| Combat | Vagues standard | Annoncée sur la porte : objet commun, énergie, type de tour, soin |
| Élite | Vagues dures, ennemi spécial | Objet rare garanti |
| Boutique | Achat en énergie | Objets, types de tours, soin |
| Atelier | Pas de combat | Amélioration permanente d'un type de tour (énergie) |
| Repos | Pas de combat | Soin du personnage |
| Secrète | Cachée derrière un mur fissuré | Récompense généreuse |
| Trésor | Rien à défendre | Un objet |
| Boss | Fin d'étage | Objet de boss, étage suivant |

## Ressources

PV du personnage (vie du run) et une seule monnaie, l'énergie : gagnée en salle, elle suit le joueur et sert à poser des tours, acheter en boutique et améliorer à l'atelier. Pas d'or, pas de clés ni de bombes pour l'instant.

## Questions ouvertes

- Univers : qui est le personnage, que défend-il ? Nom de travail ?
- 2D ou 3D low-poly vue de dessus ?
