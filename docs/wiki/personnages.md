# Personnages

Les PV du personnage sont les PV du run. Il tire à distance vers la souris et a un sort à recharge.

Chaque personnage est un fichier `data/characters/*.tres` (`CharacterData`) : ses **stats de base**, son énergie et ses types de tours de départ. Les objets ne touchent jamais ce fichier : les stats finales sont calculées pendant le run (`RunState.stat()`), stat finale = (base + somme des bonus) × produit des multiplicateurs. Elles sont affichées en jeu à gauche de l'écran, avec ▲ quand un objet les a améliorées (▼ si empirées) ; à droite, les types de tours et les objets possédés.

## Personnage de base (`base`)

Statut : 🎮 En jeu (prototype). Volontairement un peu faible : il se renforce pendant le run.

| Stat | Nom dans les données | Valeur |
|---|---|---|
| Énergie de départ | `starting_energy` | 100 |
| Types de tours de départ | `starting_towers` | Archer |
| PV max | `max_health` | 20 |
| Vitesse | `speed` | 240 |
| Invulnérabilité après un contact | `contact_invulnerability` | 1 s |
| Ramassage de l'énergie (rayon) | `pickup_radius` | 90 |
| Tir : dégâts | `shot_damage` | 8 |
| Tir : recharge (cadence) | `shot_cooldown` | 0,3 s (3,3 tirs/s) |
| Tir : vitesse / portée | `shot_speed` / `shot_range` | 750 / 360 |
| Sort : dégâts / rayon | `spell_damage` / `spell_radius` | 20 / 130 |
| Sort : ralentissement | `spell_slow_factor` / `spell_slow_duration` | à 40 % pendant 2,5 s |
| Sort : recharge | `spell_cooldown` | 8 s |
| Tours : dégâts, cadence, portée | `tower_damage`, `tower_fire_rate`, `tower_range` | ×1 |
| Tours : part rendue en fin de salle | `tower_refund` | 25 % |
| Emplacements de types de tours | `tower_slots` | 3 |

**Sort : onde de givre** : dégâts dans un rayon autour du personnage, et ralentissement.

## Autres personnages

| Personnage | Statut | Idée |
|---|---|---|
| Mage | 💡 Idée | Renforce les tours proches |
| Guerrier | 💡 Idée | Tient une ligne, encaisse au contact |
| Ingénieur | 💡 Idée | Construit vite, tours moins chères |
