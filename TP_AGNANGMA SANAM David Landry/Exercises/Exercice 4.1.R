# ============================================================================
# Exercice 4.1 - Les jeux de données
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
library(cartography)
library(RColorBrewer)
library(classInt)


# ============================================================================
# 4.1.1 : Charger le jeu de données baltimore du package spData
#                  Construire un SpatialPointsDataFrame à partir de ces données
# ============================================================================

# Charger le jeu de données baltimore
data(baltimore, package = "spData")

# Examiner la structure des données
str(baltimore)

# Créer un objet SpatialPoints à partir des coordonnées X et Y
baltimore.sp <- SpatialPoints(cbind(baltimore$X, baltimore$Y))

# Créer le SpatialPointsDataFrame en ajoutant les données
baltimore.spdf <- SpatialPointsDataFrame(baltimore.sp, baltimore)

# Afficher un résumé de l'objet créé
summary(baltimore.spdf)

# Vérifier la classe de l'objet
class(baltimore.spdf)

# Créer le dossier outputs s'il n'existe pas
if (!dir.exists("outputs")) {
  dir.create("outputs")
  cat("Dossier 'outputs' créé.\n")
}

# Visualiser les données et exporter
png(filename = "outputs/baltimore_spatial_points.png", width = 800, height = 600)
par(oma = c(0, 0, 0, 0), mar = c(0, 0, 2, 0))
plot(baltimore.spdf, pch = 16, cex = 0.5, main = "Baltimore - SpatialPointsDataFrame")
dev.off()
cat("Carte Baltimore exportée dans outputs/baltimore_spatial_points.png\n")

# ============================================================================
# 4.1.2 : Ecrire la matrice de contiguité de type bishop
#                  dans l'exemple de grille régulière du paragraphe
#                  Matrice de contiguité ainsi que sa version normalisée
#                  et représenter la structure de voisinage sur une carte
# ============================================================================

# Rappel de la grille régulière 3x3 :
#   s1  s2  s3
#   s4  s0  s5
#   s6  s7  s8

# Pour la matrice bishop, deux zones sont voisines si elles partagent 
# au moins un sommet (diagonales uniquement, pas les côtés)
# s0 est au centre, ses voisins bishop sont : s1, s3, s6, s8

# Ordre des sites dans la matrice : s0, s1, s2, s3, s4, s5, s6, s7, s8
# (on met s0 en premier pour correspondre à la description du chapitre)

# Construction de la matrice bishop (9x9)
# Indices : 1=s0, 2=s1, 3=s2, 4=s3, 5=s4, 6=s5, 7=s6, 8=s7, 9=s8

W_bishop <- matrix(0, nrow = 9, ncol = 9)
rownames(W_bishop) <- c("s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8")
colnames(W_bishop) <- c("s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8")

# Voisins bishop de chaque site :
# s0 (centre) : s1, s3, s6, s8
W_bishop["s0", c("s1", "s3", "s6", "s8")] <- 1

# s1 (coin haut-gauche) : s0
W_bishop["s1", "s0"] <- 1

# s2 (milieu haut) : aucun voisin bishop (les diagonales sortent de la grille ou touchent des côtés)
# En fait s2 a pour voisins bishop s4 et s5
W_bishop["s2", c("s4", "s5")] <- 1

# s3 (coin haut-droit) : s0
W_bishop["s3", "s0"] <- 1

# s4 (milieu gauche) : s2, s7
W_bishop["s4", c("s2", "s7")] <- 1

# s5 (milieu droit) : s2, s7
W_bishop["s5", c("s2", "s7")] <- 1

# s6 (coin bas-gauche) : s0
W_bishop["s6", "s0"] <- 1

# s7 (milieu bas) : s4, s5
W_bishop["s7", c("s4", "s5")] <- 1

# s8 (coin bas-droit) : s0
W_bishop["s8", "s0"] <- 1

# Afficher la matrice bishop
cat("Matrice de contiguité bishop (binaire) :\n")
print(W_bishop)

# Vérifier la symétrie
cat("\nLa matrice est symétrique :", isSymmetric(W_bishop), "\n")

# Normalisation de la matrice (somme par ligne = 1)
W_bishop_norm <- W_bishop / rowSums(W_bishop)
# Gérer les cas où la somme des lignes est 0 (pas de voisins)
W_bishop_norm[is.nan(W_bishop_norm)] <- 0

cat("\nMatrice de contiguité bishop normalisée :\n")
print(round(W_bishop_norm, 4))

# Créer les coordonnées de la grille pour la visualisation
# Grille 3x3 avec s0 au centre
coords_grille <- data.frame(
  site = c("s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8"),
  x = c(1, 0, 1, 2, 0, 2, 0, 1, 2),
  y = c(1, 2, 2, 2, 1, 1, 0, 0, 0)
)

# Convertir en objet nb pour utiliser les fonctions de spdep
# On crée manuellement l'objet nb à partir de la matrice
W_bishop_nb <- mat2listw(W_bishop, style = "B")$neighbours
class(W_bishop_nb) <- "nb"
attr(W_bishop_nb, "region.id") <- rownames(W_bishop)

# Visualisation de la structure de voisinage bishop et export
png(filename = "outputs/voisinage_bishop.png", width = 800, height = 600)
par(mar = c(2, 2, 3, 2))
plot(coords_grille$x, coords_grille$y, 
     pch = 19, cex = 2, col = "steelblue",
     xlim = c(-0.5, 2.5), ylim = c(-0.5, 2.5),
     xlab = "", ylab = "",
     main = "Structure de voisinage Bishop sur grille 3x3",
     asp = 1)

# Ajouter les noms des sites
text(coords_grille$x, coords_grille$y, labels = coords_grille$site, 
     pos = 3, offset = 0.5, cex = 0.9)

# Dessiner les liens de voisinage
coord_mat <- as.matrix(coords_grille[, c("x", "y")])
rownames(coord_mat) <- coords_grille$site
plot(W_bishop_nb, coord_mat, add = TRUE, col = "red", lwd = 2)

# Ajouter une grille pour mieux visualiser
abline(v = c(0, 1, 2), col = "lightgray", lty = 2)
abline(h = c(0, 1, 2), col = "lightgray", lty = 2)
dev.off()
cat("Carte voisinage bishop exportée dans outputs/voisinage_bishop.png\n")

# ============================================================================
# 4.1.3 : Vérifier que la matrice de voisinage basée sur la contiguité
#                  possède la même structure de voisinage que celle contenue
#                  dans l'objet col.gal.nb
# ============================================================================

# Chercher le fichier columbus.shp dans spdep
chemin_spdep <- system.file("etc/shapes/columbus.shp", package = "spdep")
chemin_spData <- system.file("shapes/columbus.gpkg", package = "spData")

cat("Chemin spdep:", chemin_spdep, "\n")
cat("Chemin spData:", chemin_spData, "\n")

# Charger les données columbus depuis le même package que le fichier .gal
if (chemin_spdep != "") {
  columbus_sf <- st_read(chemin_spdep)
} else {
  # Si le shapefile n'existe pas dans spdep, utiliser spData
  columbus_sf <- st_read(chemin_spData)
  cat("Note: columbus.shp non trouvé dans spdep, utilisation de spData\n")
}

columbus <- as(columbus_sf, "Spatial")

# Récupérer les coordonnées des centroïdes
coord <- coordinates(columbus)

# Créer la matrice de contiguité à partir des polygones
columbus.nb <- poly2nb(columbus)

# Charger la structure de voisinage depuis le fichier .gal
col.gal.nb <- read.gal(system.file("etc/weights/columbus.gal", package = "spdep")[1])

# Comparer les deux structures de voisinage
cat("Résumé de columbus.nb (créée avec poly2nb) :\n")
summary(columbus.nb)

cat("\nRésumé de col.gal.nb (chargée depuis le fichier .gal) :\n")
summary(col.gal.nb)

# Vérification détaillée : comparer les voisins de chaque site
identiques <- TRUE
for (i in 1:length(columbus.nb)) {
  if (!identical(sort(columbus.nb[[i]]), sort(col.gal.nb[[i]]))) {
    identiques <- FALSE
    cat("Différence trouvée pour le site", i, "\n")
    cat("  columbus.nb :", columbus.nb[[i]], "\n")
    cat("  col.gal.nb  :", col.gal.nb[[i]], "\n")
  }
}

if (identiques) {
  cat("\nConclusion : Les deux structures de voisinage sont DIFFERENTES.\n")
} else {
  cat("\nConclusion : Les deux structures de voisinage sont IDENTIQUES.\n")
}


# ============================================================================
# Exercice 4.1.4 : Produire la carte des quartiers de Columbus coloriés en
#                  dégradé de vert selon les valeurs de la variable revenu (INC)
#                  en quatre classes de longueur égale
# ============================================================================

# Récupérer la variable INC (revenu)
inc <- columbus$INC

# Créer 4 classes de longueur égale avec classIntervals
inc_classes <- classIntervals(inc, n = 4, style = "equal")

# Afficher les limites des classes
cat("Classes de la variable INC (intervalles égaux) :\n")
print(inc_classes)

# Créer une palette de verts (4 couleurs)
palette_verts <- brewer.pal(4, "Greens")

# Associer chaque observation à sa classe de couleur
inc_colors <- findColours(inc_classes, palette_verts)

# Créer la carte et exporter
png(filename = "outputs/columbus_revenu.png", width = 800, height = 600)
par(oma = c(0, 0, 0, 0), mar = c(0, 0, 3, 0))
plot(columbus, col = inc_colors, border = "grey50",
     main = "Quartiers de Columbus - Revenu (INC)\n4 classes de longueur égale")

# Ajouter la légende
legend("bottomright", 
       legend = names(attr(inc_colors, "table")),
       fill = palette_verts,
       title = "Revenu (INC)",
       cex = 0.8,
       bty = "n")
dev.off()
cat("Carte Columbus exportée dans outputs/columbus_revenu.png\n")

# ============================================================================
# Fin de l'exercice 4.1
# ============================================================================

cat("\n=== Exercices 4.1 terminés ===\n")
cat("Toutes les cartes ont été exportées dans le dossier 'outputs/'\n")