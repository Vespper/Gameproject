# Objets

Les objets peuvent tout modifier : personnage, tours, environnement, ennemis. Trois familles (voir `docs/design/gdd.md`) : statistique, comportement, synergie. Aucun objet n'existe encore dans le jeu.

| Objet | Statut | Famille | Effet |
|---|---|---|---|
| Emplacement de tour | 📐 Conçu | Comportement | +1 emplacement de type de tour |
| Cadence | 💡 Idée | Statistique | +20 % de cadence à toutes les tours |
| Ricochet | 💡 Idée | Comportement | Les projectiles rebondissent sur 2 ennemis |
| Contagion | 💡 Idée | Synergie | Les ennemis empoisonnés explosent en mourant |
| Aimant | 💡 Idée | Statistique | Rayon de ramassage de l'énergie doublé |
| Carte du cartographe | 💡 Idée | Comportement | Révèle tout l'étage sur la mini-carte, salle secrète comprise |
| Recyclage | 💡 Idée | Statistique | Les tours démontées rendent 75 % au lieu de 50 % |

## Questions ouvertes

- Portée d'un objet de tour : toutes les tours, une tour choisie, ou un type ?
- Rareté : commun, rare, boss ?
