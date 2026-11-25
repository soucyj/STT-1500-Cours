-- ═══════════════════════════════════════════════════════════════════════
--  lien-fiche.lua — bouton vers la fiche PDF d'une série d'exercices ou
--  d'un laboratoire
--
--  Sur chaque page exercices/….qmd ou laboratoires/….qmd (en-tête
--  numero:) qui produit le format fiche-typst, ajoute sous
--  l'introduction un bouton vers le PDF pour tablette produit par le
--  format fiche-typst (_extensions/fiche/), qui porte le même nom que la
--  page. Rien n'est ajouté si la page n'est pas encore publiée.
-- ═══════════════════════════════════════════════════════════════════════

function Pandoc(doc)
  if not quarto.doc.is_format("html") or not doc.meta.numero then return nil end
  local fichier = (quarto.doc.input_file or ""):gsub("\\", "/")
  local nom = fichier:match("/exercices/([^/]+)%.qmd$")
      or fichier:match("/laboratoires/([^/]+)%.qmd$")
  if not nom then return nil end
  -- Page retenue (filtres/solutions.lua n'a laissé qu'un avis)
  if #doc.blocks == 1 and doc.blocks[1].classes
      and doc.blocks[1].classes:includes("corrige-a-venir") then
    return nil
  end

  local bouton = pandoc.Para({ pandoc.Link(
    { pandoc.Str("Version PDF pour tablette (sans solutions)") },
    nom .. ".pdf", "", { class = "bouton" }) })

  -- Avant le premier titre, c'est-à-dire juste après l'introduction
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      doc.blocks:insert(i, bouton)
      return doc
    end
  end
  doc.blocks:insert(bouton)
  return doc
end
