# C'est la Vie qui Danse

## Déroulement général du jeu

**C'est la Vie qui Danse** est un jeu d’arène tactique où plusieurs personnages, contrôlés par un joueur ou une intelligence artificielle (IA), s’affrontent lors de rounds successifs. Chaque personnage dispose d’une palette d’actions (mouvements, attaques, etc.), et doit anticiper les déplacements et les choix de ses adversaires pour l’emporter.

Le jeu se déroule ainsi :

1. **Sélection d’action**  
   À chaque round, tous les personnages sélectionnent simultanément une action à réaliser (mouvement, attaque, etc.). Cette sélection peut être faite par le joueur (via une interface dédiée) ou par l’IA, qui analyse la situation pour choisir la meilleure option.

2. **Résolution simultanée**  
   Toutes les actions choisies sont ensuite résolues en même temps. Les personnages exécutent leur action selon les règles du jeu, ce qui peut entraîner des déplacements, des attaques, des collisions, etc.

3. **Gestion des dégâts et états**  
   Les dégâts et autres effets des actions sont calculés et appliqués à la fin de chaque round, ce qui peut entraîner la sortie d’un personnage si ses points de vie tombent à zéro.

4. **Fin de partie**  
   Après un nombre défini de rounds, le score de chaque équipe est évalué en fonction des points de vie restants. L’équipe ayant obtenu le meilleur score remporte la partie.

---

## Spécificités techniques et mécaniques de gameplay

Le jeu se distingue par les éléments suivants :

### 1. **Résolution physique des déplacements**

Les personnages ne se déplacent pas instantanément ou directement vers une position cible :  
Leur mouvement est géré par un système physique : ils possèdent une masse, de l’inertie, une accélération et une vitesse maximale. Les déplacements sont donc progressifs et influencés par la physique du moteur de jeu.

- **Collisions** :  
  Les personnages peuvent se percuter. Ces collisions influencent leur trajectoire et leur vitesse, ce qui ajoute une dimension stratégique : bloquer un adversaire, profiter d’une poussée, etc.

### 2. **Actions et portées**

Chaque personnage dispose de plusieurs actions :

- **Actions de mouvement** : se déplacer dans l’arène selon les lois de la physique.
- **Actions offensives** : attaques avec portée et orientation spécifiques, pouvant infliger des dégâts aux adversaires dans leur zone d’effet.
- **Actions à activation rapide/lente** : certaines actions s’exécutent plus rapidement que d’autres, ce qui influence leur efficacité dans une résolution simultanée.

### 3. **IA et stratégie**

L’IA analyse l’état de l’arène pour :

- Trouver la cible la plus proche ou la plus opportune.
- Choisir l’action offrant le meilleur rapport dégâts/portée.
- Anticiper les déplacements et rotations nécessaires pour maximiser l’efficacité de chaque action.

### 4. **Calibration du gameplay**

Le jeu propose des outils de calibration destinés à ajuster précisément les paramètres physiques (vitesse, accélération, rotation, etc.) pour garantir une expérience de jeu cohérente, équilibrée et agréable.  
La calibration ne modifie pas le gameplay en tant que tel, mais permet d’ajuster les sensations de déplacement et d’interaction physique entre les personnages.

---

## Contribution

Pour toute suggestion, bug ou contribution, n’hésitez pas à ouvrir une issue ou une pull request sur ce dépôt.

---