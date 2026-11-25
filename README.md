# STT-1500 — Probabilités : site du cours

Site Quarto (type `website`) du cours STT-1500 :
calendrier, présentations, exercices avec solutions et laboratoires.

## Travailler sur le site

```
quarto preview     # aperçu en direct
quarto render      # site complet dans _site/
```

À chaque poussée sur `main`, et chaque heure, GitHub Actions génère le
site et le publie sur GitHub Pages (`.github/workflows/publish.yml`).
Dans les réglages du dépôt GitHub : Settings → Pages → Source : GitHub
Actions.

## Structure

```
_quarto.yml               barre latérale, thème, pied de page
_variables.yml            renseignements réutilisés dans les pages
index.qmd                 accueil et accès rapides
calendrier.qmd            calendrier de la session (coquille)
livre.qmd                 notes de cours
presentations/             « Présentation de la matière » : une page par module
presentations/pdf/         PDF des diapositives (copiés par copier-pdf.sh)
exercices/                une série d'exercices par module, avec solutions
exercices/_metadata.yml   réglages communs des séries d'exercices
_extensions/fiche/        format « fiche » : PDF paysage pour tablette, sans solutions
laboratoires/index.qmd    liste automatique des laboratoires
ressources.qmd            outils et liens
filtres/solutions.lua     publication à date et heure fixes
_publication.yml          calendrier de publication (non publié sur le site)
_outils/                  script du calendrier (ignoré par Quarto)
styles/                   couleurs et polices
```

Les encadrés « À compléter » marquent les parties de la coquille à remplir.

## Présentations

Les PDF des diapositives sont copiés depuis les dossiers Beamer par

```
sh presentations/copier-pdf.sh [dossier source]   # défaut : Beamer/
```

Après une recompilation des Beamer, relancer ce script puis pousser.

## Exercices

Une page par module dans `exercices/` (en-tête : `title`, `description`,
`numero`). Chaque solution est dans un bloc `::: {.corrige}` ; sans date,
elle est publiée d'emblée, dans un encadré repliable.

## Laboratoires

Une page `NN-sujet.qmd` par laboratoire dans `laboratoires/` (en-tête :
`title`, `description`, `numero`) : elle apparaît dans la liste. Chaque
solution va dans un bloc `::: {.corrige}`. Pour la fiche PDF, ajouter
le `format:` décrit à la section « Fiches PDF pour tablette ».


## Calendrier de publication

`_publication.yml` (racine, non publié sur le site) fixe le moment où
chaque document devient visible : diapositives, exercices et solutions
de chaque module ; énoncé et solutions de chaque laboratoire (par défaut,
la veille à 8 h et le jour même à 10 h 30). Le filtre
`filtres/solutions.lua` le lit, et GitHub Actions régénère le site deux
fois par heure (hh:01 et hh:31).

Attention : le dépôt étant public, ce fichier et les sources des
solutions restent lisibles sur GitHub.

Pour tester :

```
SOLUTIONS=toutes quarto preview                  # tout afficher
MAINTENANT="2027-01-25 10:45" quarto preview     # simuler un moment
```

## Calendrier

`calendrier.qmd` est généré par `_outils/generer_calendrier.py` :
modifier les dates en tête du script, puis lancer
`python3 _outils/generer_calendrier.py`.

## Fiches PDF pour tablette

Chaque série d'exercices et chaque laboratoire peut produire un PDF
paysage (format 4:3, une question par page, sans solutions) pour
l'annotation sur tablette : une page par « ### Exercice » dans les
séries, une page par section « ## » (Déroulement, Problème 1…) dans les
laboratoires. Dans l'en-tête de la page :

```
format:
  html: default
  fiche-typst: default
```

Le bouton « Version PDF pour tablette (sans solutions) » est ajouté
automatiquement sous l'introduction de la page (`filtres/lien-fiche.lua`).

Le PDF est régénéré à chaque `quarto render` (localement et sur GitHub
Actions) : il suit toujours les exercices. Mise en page :
`_extensions/fiche/typst-template.typ` ; découpage et retrait des
solutions : `_extensions/fiche/fiche.lua`. Les polices (Fira Sans,
STIX Two, licence OFL) sont incluses dans `_extensions/fiche/polices/`.
