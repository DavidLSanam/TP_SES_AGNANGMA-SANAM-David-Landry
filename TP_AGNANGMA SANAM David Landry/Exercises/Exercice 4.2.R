# ============================================================================
# Exercice 4.2 - Sur les matrices de poids
# ============================================================================

# Installation des packages nécessaires
install.packages("spData", dependencies = TRUE)
install.packages("cartography", dependencies = TRUE)
install.packages("ClassInt", dependencies = TRUE)
install.packages("sf", dependencies = TRUE)
install.packages("spdep", dependencies = TRUE)

# Chargement des packages nécessaires
library(sp)
library(sf)
library(spdep)
library(spData)

# ============================================================================
# Charger les données nc du package spData
# ============================================================================

# Chercher le bon chemin pour sids.shp
chemin <- system.file("shapes/sids.shp", package = "spData")
if (chemin == "") {
  # Essayer avec le format gpkg
  chemin <- system.file("shapes/sids.gpkg", package = "spData")
}
if (chemin == "") {
  # Essayer dans sf
  chemin <- system.file("shape/nc.shp", package = "sf")
}

cat("Chemin utilisé :", chemin, "\n")
nc <- st_read(chemin, quiet = TRUE)

# Afficher un aperçu des données
print(nc)

# Récupérer les coordonnées des centroïdes
coord <- st_coordinates(st_centroid(nc))

# Créer le dossier outputs s'il n'existe pas
if (!dir.exists("outputs")) {
  dir.create("outputs")
  cat("Dossier 'outputs' créé.\n")
}

# ============================================================================
# 4.2.1 : Construire une matrice de voisinage basée sur la contiguité
#                  et la représenter graphiquement. Commenter le résumé.
# ============================================================================

# Créer la matrice de contiguité
nc.nb <- poly2nb(nc)

# Résumé de la structure de voisinage
cat("=== Matrice de voisinage basée sur la contiguité ===\n\n")
summary(nc.nb)

# Représentation graphique et export
png(filename = "outputs/nc_contiguite.png", width = 800, height = 600)
par(oma = c(0, 0, 0, 0), mar = c(0, 0, 2, 0))
plot(st_geometry(nc), border = "grey")
plot(nc.nb, coord, add = TRUE, col = "blue")
title("Matrice de contiguité - nc")
dev.off()
cat("Carte contiguïté exportée dans outputs/nc_contiguite.png\n")

# Commentaire :

cat("La structure de voisinage basée sur la contiguité pour les données nc (100 comtés de Caroline du Nord) présente les caractéristiques suivantes :

Nombre de régions : 100 comtés
Nombre de liens non nuls : 490 (soit 4.9% des poids non nuls)
Nombre moyen de voisins : 4.9 par comté
Distribution du nombre de voisins : varie de 2 à 8 voisins selon les comtés
Les comtés en bordure de l'État (côte atlantique, frontières avec d'autres États) ont moins de voisins
Les comtés au centre ont davantage de voisins car ils sont entourés de tous côtés
La matrice est symétrique : si le comté A est voisin du comté B, alors B est voisin de A\n")

# ============================================================================
# Exercice 4.2.2 : Construire une matrice de voisinage basée sur les 5 plus
#                  proches voisins et la représenter graphiquement.
# ============================================================================

# Créer la matrice des 5 plus proches voisins
nc.knn <- knearneigh(coord, k = 5)
nc.knn.nb <- knn2nb(nc.knn)

# Résumé de la structure de voisinage
cat("\n=== Matrice de voisinage basée sur les 5 plus proches voisins ===\n\n")
summary(nc.knn.nb)

# Représentation graphique et export
png(filename = "outputs/nc_5_plus_proches_voisins.png", width = 800, height = 600)
par(oma = c(0, 0, 0, 0), mar = c(0, 0, 2, 0))
plot(st_geometry(nc), border = "grey")
plot(nc.knn.nb, coord, add = TRUE, col = "red")
title("5 plus proches voisins - nc")
dev.off()
cat("Carte 5 plus proches voisins exportée dans outputs/nc_5_plus_proches_voisins.png\n")

# Commentaire :

cat("La structure de voisinage basée sur les 5 plus proches voisins présente les caractéristiques suivantes :

Nombre de régions : 100 comtés
Nombre de liens non nuls : 500 (chaque comté a exactement 5 voisins)
Nombre moyen de voisins : 5 (par construction)
Distribution uniforme : tous les comtés ont le même nombre de voisins, contrairement à la contiguité
La matrice n'est pas symétrique : si A compte B parmi ses 5 plus proches voisins, B ne compte pas forcément A parmi les siens
Les liens peuvent traverser d'autres comtés sans les inclure comme voisins (pas de notion de frontière partagée)
Cette méthode garantit que chaque comté a un nombre suffisant de voisins, même ceux en bordure de l'État
On observe des liens plus longs dans les zones où les comtés sont plus grands (ouest de l'État)\n")

# ============================================================================
# 4.2.3 : Choisir un seuil de distance et construire une matrice
#                  de voisinage basée sur ce seuil de distance.
# ============================================================================

# Calculer la distance maximale pour choisir un seuil approprié
mat_dist <- dist(coord)
max_dist <- max(mat_dist)
cat("\n=== Matrice de voisinage basée sur un seuil de distance ===\n\n")
cat("Distance maximale entre centroïdes :", max_dist, "\n")

# Choisir un seuil (environ 20% de la distance maximale)
seuil <- max_dist * 0.2
cat("Seuil choisi :", seuil, "\n\n")

# Créer la matrice de voisinage basée sur le seuil de distance
nc.dist.nb <- dnearneigh(coord, 0, seuil)

# Résumé de la structure de voisinage
summary(nc.dist.nb)

# Représentation graphique et export
png(filename = "outputs/nc_seuil_distance.png", width = 800, height = 600)
par(oma = c(0, 0, 0, 0), mar = c(0, 0, 2, 0))
plot(st_geometry(nc), border = "grey")
plot(nc.dist.nb, coord, add = TRUE, col = "darkgreen")
title(paste("Seuil de distance =", round(seuil, 2), "- nc"))
dev.off()
cat("Carte seuil de distance exportée dans outputs/nc_seuil_distance.png\n")

# Commentaire :

cat("La structure de voisinage basée sur un seuil de distance de 1.65 présente les caractéristiques suivantes :

Seuil choisi : 1.65 (environ 20% de la distance maximale entre centroïdes)
Densité très élevée : le graphique montre un réseau très dense avec de nombreux liens
Nombre moyen de voisins élevé : chaque comté a beaucoup plus de voisins qu'avec la contiguité ou les k plus proches voisins
La matrice est symétrique : si la distance entre A et B est inférieure au seuil, alors A est voisin de B et réciproquement
Inconvénient du seuil choisi : avec un seuil trop grand, on perd la notion de proximité locale car des comtés éloignés sont considérés comme voisins
Les zones où les comtés sont plus petits (est de l'État) ont une densité de liens encore plus forte
Recommandation : un seuil plus petit (par exemple 10% de la distance maximale) donnerait une structure plus comparable à la contiguité et serait plus pertinent pour détecter l'autocorrélation spatiale locale\n")

# ============================================================================
# Fin de l'exercice 4.2
# ============================================================================

cat("\n=== Exercice 4.2 terminé ===\n")
cat("Toutes les cartes ont été exportées dans le dossier 'outputs/'\n")