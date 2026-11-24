# Objets

Les objets peuvent tout modifier : personnage, tours, environnement, ennemis. Trois familles (voir `docs/design/gdd.md`) : statistique, comportement, synergie.

Un objet est un fichier `data/items/*.tres` (`ItemData`) : nom, effet en quelques mots, prix en boutique, et une liste de modificateurs de stats (`StatModifier` : nom de la stat du personnage, `add`, `multiply`). Les noms de stats sont ceux de [Personnages](personnages.md). Pour l'instant, seulement des objets de statistique.

On les trouve dans la salle du **trésor** (un gratuit) et à la **boutique** (payés en énergie). Un objet sort au plus une fois par étage (`item_pool` de `data/floors/floor_01.tres`).

| Objet | Statut | Famille | Effet | Données | Prix boutique |
|---|---|---|---|---|---|
| Cœur robuste (`sturdy_heart`) | 🎮 En jeu | Statistique | +4 PV max (et +4 PV) | `max_health` +4 | 70 |
| Bottes légères (`light_boots`) | 🎮 En jeu | Statistique | +15 % de vitesse | `speed` ×1,15 | 60 |
| Pointe affûtée (`sharp_tip`) | 🎮 En jeu | Statistique | +3 dégâts du tir | `shot_damage` +3 | 75 |
| Gâchette rapide (`quick_trigger`) | 🎮 En jeu | Statistique | Tir 20 % plus rapide | `shot_cooldown` ×0,8 | 75 |
| Longue-vue (`spyglass`) | 🎮 En jeu | Statistique | +30 % de portée du tir, projectiles plus rapides | `shot_range` ×1,3, `shot_speed` ×1,2 | 55 |
| Aimant (`magnet`) | 🎮 En jeu | Statistique | Rayon de ramassage de l'énergie doublé | `pickup_radius` ×2 | 55 |
| Cristal de givre (`frost_crystal`) | 🎮 En jeu | Statistique | Sort : +10 dégâts, recharge −30 % | `spell_damage` +10, `spell_cooldown` ×0,7 | 70 |
| Recyclage (`recycling`) | 🎮 En jeu | Statistique | Les tours démontées rendent 50 % au lieu de 25 % | `tower_refund` +0,25 | 70 |
| Carquois (`quiver`) | 🎮 En jeu | Statistique | +20 % de cadence à toutes les tours | `tower_fire_rate` ×1,2 | 85 |
| Pierre à aiguiser (`whetstone`) | 🎮 En jeu | Statistique | +20 % de dégâts à toutes les tours | `tower_damage` ×1,2 | 85 |
| Lentille (`lens`) | 🎮 En jeu | Statistique | +15 % de portée à toutes les tours | `tower_range` ×1,15 | 65 |
| Emplacement de tour | 📐 Conçu | Comportement | +1 emplacement de type de tour (`tower_slots` +1). Pas encore dans le pool : il n'y a que 3 types de tours. | — | — |
| Ricochet | 💡 Idée | Comportement | Les projectiles rebondissent sur 2 ennemis | — | — |
| Contagion | 💡 Idée | Synergie | Les ennemis empoisonnés explosent en mourant | — | — |
| Carte du cartographe | 💡 Idée | Comportement | Révèle tout l'étage sur la mini-carte, salle secrète comprise | — | — |

## Questions ouvertes

- Portée d'un objet de tour : toutes les tours, une tour choisie, ou un type ?
- Rareté : commun, rare, boss ?
