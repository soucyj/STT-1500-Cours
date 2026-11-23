# STT-1500 — Probabilités : site du cours

Site Quarto (type `website`) du cours STT-1500 : plan de cours,
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
plan.qmd                  plan de cours (coquille)
calendrier.qmd            calendrier de la session (coquille)
livre.qmd                 notes de cours
presentations/index.qmd   une carte par module
exercices/                une série d'exercices par module, avec solutions
laboratoires/index.qmd    liste automatique des laboratoires
ressources.qmd            outils et liens
filtres/solutions.lua     publication à date et heure fixes
styles/                   couleurs et polices
```

Les encadrés « À compléter » marquent les parties de la coquille à remplir.

## Exercices

Une page par module dans `exercices/` (en-tête : `title`, `description`,
`numero`). Chaque solution est dans un bloc `::: {.corrige}` ; sans date,
elle est publiée d'emblée, dans un encadré repliable.

## Laboratoires et publication à heure fixe

Une page `.qmd` par laboratoire dans `laboratoires/` (en-tête : `title`,
`description`, `numero`) : elle apparaît dans la liste. Pour publier à
heure fixe, dans l'en-tête :

```yaml
disponible: "2026-12-05 08:00"   # les questions
corrige: "2026-12-05 18:00"      # les solutions
```

Détails dans `filtres/solutions.lua`. Pour tester :
`SOLUTIONS=toutes quarto preview` affiche tout.
