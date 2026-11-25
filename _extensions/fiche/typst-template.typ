// ═══════════════════════════════════════════════════════════════════════
//  Fiche d'exercices — PDF paysage pour tablette
//  Couleurs et polices du site (styles/cours.scss).
// ═══════════════════════════════════════════════════════════════════════

#let bleu = rgb(28, 63, 110)
#let olive = rgb(166, 186, 72)
#let encre = rgb("#1d1d1f")
#let fond = rgb(246, 244, 238)
#let sans = ("Fira Sans",)
#let serif = ("STIX Two Text",)

// Dégradé du menu du site : lime vif au centre → turquoise pâle
#let degrade = gradient.radial(
  (rgb(240, 251, 112), 0%),
  (rgb(228, 246, 150), 35%),
  (rgb(206, 235, 190), 70%),
  (rgb(190, 226, 230), 100%),
  center: (50%, 45%),
  radius: 80%,
)

// Nom de la section, au-dessus du numéro de l'exercice
#let rubrique(corps) = block(below: 0.5em,
  text(font: sans, size: 10.5pt, weight: 500, fill: olive.darken(25%),
    upper(corps)))

#let fiche(title: none, etiquette: none, intro: none, doc) = {
  set document(title: title)
  set text(lang: "fr", font: serif, size: 13pt, fill: encre)
  set par(justify: true, leading: 0.72em, spacing: 1.1em)
  show math.equation: set text(font: "STIX Two Math")
  set enum(indent: 0.4em, body-indent: 0.6em, spacing: 0.9em)
  set list(indent: 0.4em, body-indent: 0.6em, spacing: 0.9em)
  set table(stroke: 0.5pt + bleu.lighten(60%), inset: 6pt)
  show emph: set text(fill: encre.lighten(20%))

  // ── Page couverture ──────────────────────────────────────────────────
  page(
    width: 280mm, height: 210mm,
    margin: (x: 28mm, top: 26mm, bottom: 22mm),
    fill: degrade,
    footer: text(font: sans, size: 9.5pt, fill: bleu.lighten(20%))[
      Jérôme Soucy · Département de mathématiques et de statistique, Université Laval
    ],
  )[
    #text(font: sans, size: 13pt, weight: 600, fill: bleu, tracking: 0.06em,
      upper[STT-1500 · #etiquette])
    #v(1fr)
    #block(width: 85%,
      {
        set par(justify: false)
        text(font: sans, size: 36pt, weight: 700, fill: bleu,
          hyphenate: false, title)
      })
    #v(4mm)
    #line(length: 32mm, stroke: 2.5pt + olive)
    #v(1fr)
    #if intro != none {
      block(width: 100%, inset: (x: 7mm, y: 6mm), radius: 3mm,
        fill: white.transparentize(45%))[
        #set text(size: 12.5pt)
        #intro
      ]
    }
  ]

  // ── Pages des questions ──────────────────────────────────────────────
  set page(
    width: 280mm, height: 210mm,
    margin: (x: 22mm, top: 24mm, bottom: 18mm),
    fill: fond,
    header: context {
      if counter(page).get().first() > 1 {
        set text(font: sans, size: 9.5pt, fill: bleu.lighten(25%))
        [STT-1500 · #etiquette #h(1fr) #title]
        v(-0.6em)
        line(length: 100%, stroke: 0.5pt + olive.lighten(30%))
      }
    },
    footer: context {
      set text(font: sans, size: 9.5pt, fill: bleu.lighten(25%))
      h(1fr)
      counter(page).display()
    },
  )

  show heading: it => {
    set text(font: sans, weight: 700, fill: bleu, hyphenate: false)
    if it.level == 3 {
      block(above: 0pt, below: 1em, text(size: 20pt, it.body))
    } else {
      block(above: 1.2em, below: 0.8em, text(size: 15pt, it.body))
    }
  }

  doc
}
