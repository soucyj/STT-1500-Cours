"""Génère calendrier.qmd : une vue mensuelle de la session.

Usage (à la racine du dépôt) :
    python3 _outils/generer_calendrier.py

Modifier les données ci-dessous pour une nouvelle session, relancer le
script, puis vérifier avec `quarto preview`. Le dossier _outils/ commence
par un tiret bas : Quarto l'ignore lors du rendu du site.
"""

import calendar
import datetime as dt
from pathlib import Path

# ── Données de la session ───────────────────────────────────────────────
SESSION = "Hiver 2027"
DEBUT = dt.date(2027, 1, 11)          # premier cours
FIN_COURS = dt.date(2027, 4, 21)      # dernier cours
JOURS_DE_COURS = {0, 2}               # lundi = 0, mercredi = 2
MOIS = [(2027, 1), (2027, 2), (2027, 3), (2027, 4)]

LABORATOIRES = [dt.date(2027, 1, 25), dt.date(2027, 2, 8),
                dt.date(2027, 2, 24), dt.date(2027, 3, 15),
                dt.date(2027, 3, 31), dt.date(2027, 4, 7),
                dt.date(2027, 4, 21)]
EXAMENS = {dt.date(2027, 2, 10): "Examen 1",
           dt.date(2027, 3, 17): "Examen 2",
           dt.date(2027, 4, 26): "Examen final"}
# Journées sans cours, grisées : semaine de lecture et congés de Pâques
CONGES = {dt.date(2027, 3, 1) + dt.timedelta(days=k): "Semaine de lecture"
          for k in range(5)}
CONGES |= {dt.date(2027, 3, 26): "Vendredi saint (congé de Pâques)",
           dt.date(2027, 3, 27): "Congé de Pâques",
           dt.date(2027, 3, 28): "Pâques (congé)",
           dt.date(2027, 3, 29): "Lundi de Pâques (congé de Pâques)"}

# ── Mise en forme ───────────────────────────────────────────────────────
NOMS_MOIS = ["janvier", "février", "mars", "avril", "mai", "juin",
             "juillet", "août", "septembre", "octobre", "novembre",
             "décembre"]
NOMS_JOURS = ["lundi", "mardi", "mercredi", "jeudi", "vendredi",
              "samedi", "dimanche"]
ENTETES = ["L", "M", "M", "J", "V", "S", "D"]


def date_fr(d):
    jour = "1er" if d.day == 1 else str(d.day)
    return f"{NOMS_JOURS[d.weekday()]} {jour} {NOMS_MOIS[d.month - 1]}"


def journee(d):
    """(classe CSS, étiquette affichée, description) pour la date d."""
    if d in EXAMENS:
        nom = EXAMENS[d]
        court = "Final" if nom == "Examen final" else nom.replace("Examen", "Exam.")
        return "examen", court, nom
    if d in CONGES:
        return "conge", "", CONGES[d]
    if d in LABORATOIRES:
        n = LABORATOIRES.index(d) + 1
        return "labo", f"Labo {n}", f"Laboratoire {n}"
    if DEBUT <= d <= FIN_COURS and d.weekday() in JOURS_DE_COURS:
        return "cours", "", "Cours"
    return "", "", ""


def mois_html(annee, mois):
    lignes = [f'<div class="cal-mois">',
              f'<h3>{NOMS_MOIS[mois - 1].capitalize()} {annee}</h3>',
              '<div class="cal-grille">']
    lignes += [f'<div class="cal-entete">{e}</div>' for e in ENTETES]
    for semaine in calendar.Calendar(firstweekday=0).monthdatescalendar(annee, mois):
        for d in semaine:
            if d.month != mois:
                lignes.append('<div class="cal-jour hors"></div>')
                continue
            classe, etiquette, description = journee(d)
            titre = date_fr(d) + (f" : {description}" if description else "")
            fin = " fin-semaine" if d.weekday() >= 5 else ""
            lab = (f'<span class="cal-etiquette">{etiquette.replace(" ", "&nbsp;")}</span>'
                   if etiquette else "")
            lignes.append(f'<div class="cal-jour {classe}{fin}" title="{titre}">'
                          f'<span class="cal-num">{d.day}</span>{lab}</div>')
    lignes += ['</div>', '</div>']
    return "\n".join(lignes)


def page():
    labos = ", ".join(date_fr(d) for d in LABORATOIRES)
    examens = "\n".join(f"| {nom} | {date_fr(d)} |" for d, nom in EXAMENS.items())
    grilles = "\n".join(mois_html(a, m) for a, m in MOIS)
    return f'''---
title: "Calendrier"
subtitle: "{SESSION}"
toc: false
---

<!-- Page générée par _outils/generer_calendrier.py : modifier le script,
     puis le relancer, plutôt que d'éditer cette page à la main. -->

::: {{.callout-important}}
En cas de disparité entre ce calendrier et le site du cours sur Brio, ce
sont les dates indiquées sur Brio qui prévalent.
:::

Les cours ont lieu les lundis et les mercredis, du {date_fr(DEBUT)} au
{date_fr(FIN_COURS)}. Passez le curseur sur une journée pour en voir la
description.

```{{=html}}
<div class="cal-legende">
<span><i class="cours"></i>Cours</span>
<span><i class="labo"></i>Laboratoire</span>
<span><i class="examen"></i>Examen</span>
<span><i class="conge"></i>Semaine de lecture et congés de Pâques</span>
</div>
<div class="calendrier">
{grilles}
</div>
```

## Dates importantes

| Évaluation | Date |
|:--|:--|
{examens}

Laboratoires : {labos}.
'''


if __name__ == "__main__":
    cible = Path(__file__).resolve().parent.parent / "calendrier.qmd"
    cible.write_text(page(), encoding="utf-8")
    print(f"Écrit : {cible}")
