# MAT-2901 — Mathématiques et technologie : site du cours

Site Quarto (type `website`) du cours. Il renvoie au livre et aux
présentations, qui vivent dans le dépôt du livre
([LivreMathTechno](https://github.com/soucyj/LivreMathTechno)) : si le
livre change, les présentations changent avec lui.

## Travailler sur le site

```
quarto preview     # aperçu en direct
quarto render      # site complet dans _site/
```

À chaque poussée sur `main`, GitHub Actions génère le site et le publie
sur GitHub Pages (`.github/workflows/publish.yml`). Dans les réglages du
dépôt GitHub : Settings → Pages → Source : GitHub Actions.

## Structure

```
_quarto.yml               barre latérale (comme le livre), thème, pied de page
_variables.yml            TOUTES les adresses externes (livre, PDF, Overleaf)
index.qmd                 accueil et accès rapides
plan.qmd                  plan de cours (coquille)
calendrier.qmd            calendrier de la session (coquille)
livre.qmd                 liens vers le livre, ses chapitres et annexes
presentations/index.qmd   une carte par chapitre : PDF des diapositives
laboratoires/index.qmd    liste automatique des laboratoires
laboratoires/latex.qmd    laboratoire « Écrire des mathématiques avec LaTeX »
ressources.qmd            outils et documentation
styles/                   couleurs et polices du livre
```

Les encadrés « À compléter » marquent les parties de la coquille à remplir.

## Les PDF des présentations

Les liens supposent que le site du livre publie, sous
`https://soucyj.github.io/LivreMathTechno/presentations/` :

```
chapitre1.pdf … chapitre4.pdf     les diaporamas (Beamer/chapitreN/)
laboratoire-latex.pdf             le diaporama du labo (Beamer/Activité LaTeX/)
labo-latex/01-minimal.tex         les fichiers d'exemple du labo
labo-latex/02-activite.tex
labo-latex/03-examen.tex
```

Si cette adresse change, il suffit de modifier `pdf.base` dans
`_variables.yml`.

## Ajouter un laboratoire

Copier `laboratoires/latex.qmd`, changer `title`, `description` et
`numero` dans l'en-tête : la page apparaît dans la liste des laboratoires.
