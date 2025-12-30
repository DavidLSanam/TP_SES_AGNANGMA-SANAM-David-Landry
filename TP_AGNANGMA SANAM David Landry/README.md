# Statistique exploratoire spatiale - Autocorrélation Spatiale

**Auteur**  
AGNANGMA SANAM David Landry  
ISE1 - Cycle Long  
Année académique : 2025-2026

**Enseignant** :
M. HEMA Aboubacar

## Description du projet

Ce projet regroupe l'ensemble des exercices pratiques du chapitre 3 sur l'autocorrélation spatiale. Il met en œuvre différentes techniques d'analyse spatiale en utilisant R, avec un focus particulier sur les matrices de voisinage, les indices d'autocorrélation spatiale et leurs interprétations géographiques.

## Architecture du projet

```
TP_AGNANGMA SANAM David Landry/
├── Exercises/                   # Dossier contenant les scripts R, pdf et fichier TEX
│   ├── Exercice_4.1.R               # Script R pour l'exercice 4.1
│   ├── Exercice_4.2.R               # Script R pour l'exercice 4.2
│   ├── Exercice_4_3_SES_David_Landry_AGNANGMA_SANAM.pdf  # Rapport pour l'exercice 4.3
│   └── Exercice_4_3_SES_David_Landry_AGNANGMA_SANAM.tex  # Source LaTeX du rapport
├── outputs/                     # Dossier contenant toutes les visualisations exportées
│   ├── baltimore_spatial_points.png
│   ├── columbus_revenu.png
│   ├── nc_5_plus_proches_voisins.png
│   ├── nc_contiguite.png
│   ├── nc_seuil_distance.png
│   └── voisinage_bishop.png
├── README.md                    # Documentation du projet
└── TP_AGNANGMA_SANAM_David_Landry.Rproj  # Fichier projet RStudio
```

## Contenu des exercices

### Exercice 4.1 - Les jeux de données

**Objectif** : Manipulation des données spatiales et construction de matrices de voisinage.

**Contenu** :
- Chargement et transformation des données Baltimore en SpatialPointsDataFrame
- Construction d'une matrice de contiguïté de type Bishop sur une grille régulière
- Comparaison des structures de voisinage (poly2nb vs fichier .gal)
- Cartographie thématique des revenus à Columbus avec classification par intervalles égaux

**Fonctions R utilisées** :
- `SpatialPointsDataFrame()`, `poly2nb()`, `read.gal()`
- `classIntervals()`, `brewer.pal()`, `findColours()`

### Exercice 4.2 - Sur les matrices de poids

**Objectif** : Exploration des différentes méthodes de construction de matrices de voisinage.

**Contenu** :
- Construction d'une matrice de voisinage basée sur la contiguïté (poly2nb)
- Construction d'une matrice basée sur les 5 plus proches voisins (knn)
- Construction d'une matrice basée sur un seuil de distance (dnearneigh)
- Comparaison et analyse critique des différentes approches

**Jeu de données** : Comtés de Caroline du Nord (nc) avec 100 observations

**Fonctions R utilisées** :
- `poly2nb()`, `knn2nb()`, `dnearneigh()`
- `knearneigh()`, `st_coordinates()`, `st_centroid()`

### Exercice 4.3 - Sur l'indice de Moran

**Objectif** : Démonstration théorique du lien entre l'indice de Moran et la régression spatiale.

**Contenu théorique** (développé dans le PDF joint) :
- Preuve que WX est centré lorsque W est normalisée en ligne et X centré
- Démonstration que la pente de la régression de WX sur X égale l'indice de Moran
- Interprétation géographique des résultats

**Résultat principal** :  
Si la matrice de voisinage W est normalisée en ligne et symétrique, et si le vecteur X est centré, alors :
- Le vecteur spatialement décalé WX est également centré
- La pente β̂ de la droite de régression simple de WX sur X est égale à l'indice de Moran I

## Installation et exécution

### Prérequis

- R (version 4.0 ou supérieure)
- RStudio (recommandé)

### Packages R nécessaires

```r
install.packages(c("sp", "sf", "spdep", "spData", "cartography", 
                   "RColorBrewer", "classInt", "rgdal"))
```

### Exécution des scripts

1. Cloner ou télécharger le projet
2. Ouvrir le fichier `.Rproj` dans RStudio
3. Exécuter les scripts dans l'ordre :

```r
source("Exercises/Exercice_4.1.R")
source("Exercises/Exercice_4.2.R")
```

Les visualisations sont automatiquement sauvegardées dans le dossier `outputs/`

## Résultats et visualisations

Toutes les cartes et graphiques générés sont automatiquement exportés dans le dossier `outputs/` :

### Exercice 4.1
- `baltimore_spatial_points.png` : Représentation des points Baltimore
- `voisinage_bishop.png` : Structure de voisinage Bishop sur grille 3x3
- `columbus_revenu.png` : Carte des revenus à Columbus par quartiles

### Exercice 4.2
- `nc_contiguite.png` : Matrice de contiguïté des comtés de Caroline du Nord
- `nc_5_plus_proches_voisins.png` : 5 plus proches voisins
- `nc_seuil_distance.png` : Voisinage par seuil de distance (20% de la distance max)

## Points techniques importants

### Gestion des dépendances
Les scripts vérifient et installent automatiquement les packages manquants, garantissant la reproductibilité des analyses.

### Export automatique
Une fonctionnalité intéressante du code est la création automatique du dossier `outputs` et l'export systématique des visualisations, facilitant l'archivage et le partage des résultats.

### Robustesse des chemins
Les scripts gèrent intelligemment les différences de chemins entre les versions des packages (spdep vs spData), assurant une exécution fluide sur différentes configurations.

## Compétences développées

À travers ce projet, nous avons acquis et mis en pratique les compétences suivantes :

- **Manipulation de données spatiales** : Conversion entre différents formats (sf, Spatial*)
- **Construction de matrices de voisinage** : Maîtrise des différentes méthodes (contiguïté, k-plus proches, distance)
- **Cartographie thématique** : Classification et visualisation avec palettes appropriées
- **Analyse théorique** : Compréhension approfondie des fondements mathématiques de l'autocorrélation spatiale
- **Programmation R avancée** : Gestion des dépendances, export automatisé, gestion d'erreurs

## Perspectives et applications

Les méthodes implémentées dans ce projet trouvent des applications concrètes en :

- **Géographie urbaine** (analyse de la ségrégation spatiale)
- **Épidémiologie** (détection de clusters spatiaux)
- **Économétrie spatiale** (modélisation des interactions régionales)
- **Environnement** (analyse de la distribution spatiale des polluants)

---

*Ce projet a été réalisé dans le cadre du cours de Statistique exploratoire spatiale. L'ensemble du code et des analyses a été développé de manière autonome, avec une attention particulière portée à la reproductibilité et à la rigueur scientifique.*