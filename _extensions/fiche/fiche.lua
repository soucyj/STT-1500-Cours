-- ═══════════════════════════════════════════════════════════════════════
--  fiche.lua — prépare une série d'exercices ou un laboratoire pour le
--  PDF tablette
--
--  - retire les solutions (.corrige) et les avis « Solution : disponible
--    le … » ;
--  - le texte placé avant le premier titre va sur la page couverture (à
--    défaut, la description de l'en-tête) ;
--  - exercices : chaque « ### Exercice n » commence une nouvelle page,
--    coiffée du nom de la section (## …) dont il fait partie ;
--  - laboratoires (pas de ### ) : chaque « ## … » (Déroulement,
--    Problème 1…) commence une nouvelle page ;
--  - les liens deviennent du texte simple (ils pointent vers le site).
-- ═══════════════════════════════════════════════════════════════════════

local function typst(inlines)
  return pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "typst")
end

function Pandoc(doc)
  if not quarto.doc.is_format("typst") then return nil end

  -- Page pas encore publiée : un seul avis, qu'on garde tel quel
  local sole = #doc.blocks == 1 and doc.blocks[1].t == "Div"
      and doc.blocks[1].classes:includes("corrige-a-venir")

  doc.blocks = doc.blocks:walk({
    Div = function(el)
      if el.classes:includes("corrige")
          or (el.classes:includes("corrige-a-venir") and not sole) then
        return {}
      end
    end,
    Link = function(el) return el.content end,
    -- Contourne un défaut de Pandoc : « ^k\binom nk » devient « ^kbinom »
    -- en Typst. Un groupe vide « ^k{}\binom » rétablit l'espace.
    -- Virgule décimale « 0{,}4 » : Typst l'espacerait comme une
    -- ponctuation (« 0, 4 ») ; on la déclare ordinaire.
    Math = function(el)
      el.text = el.text:gsub("([%^_]%w)(\\%a)", "%1{}%2")
      if not el.text:find("%d{,}%d") then return el end
      local t = pandoc.write(pandoc.Pandoc({ pandoc.Plain({ el }) }), "typst")
      t = t:gsub("%s+$", ""):gsub("(%d)\\,(%d)", '%1class("normal", \\,)%2')
      return pandoc.RawInline("typst", t)
    end,
  })

  -- Niveau des titres qui ouvrent une page : 3 s'il y en a, sinon 2
  local niveau = 2
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 3 then niveau = 3 break end
  end

  local intro, corps = pandoc.List(), pandoc.List()
  local rubrique, avant_titre = nil, true
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level < niveau then
      avant_titre = false
      rubrique = b.content
    elseif b.t == "Header" and b.level == niveau then
      avant_titre = false
      corps:insert(pandoc.RawBlock("typst", "#pagebreak(weak: true)"))
      if rubrique then
        corps:insert(pandoc.RawBlock("typst",
          "#rubrique[" .. typst(rubrique) .. "]"))
      end
      b.level = 3   -- même style partout (voir typst-template.typ)
      corps:insert(b)
    elseif avant_titre then
      intro:insert(b)
    else
      corps:insert(b)
    end
  end

  if #intro == 0 and doc.meta.description then
    intro:insert(pandoc.Para(doc.meta.description))
  end
  if #intro > 0 then
    doc.meta.intro = pandoc.MetaBlocks(intro)
  end

  -- Étiquette : « Module 01 · Exercices » ou « Laboratoire 1 »
  local fichier = (quarto.doc.input_file or ""):gsub("\\", "/")
  local n = doc.meta.numero and tonumber(pandoc.utils.stringify(doc.meta.numero))
  if fichier:match("/laboratoires/[^/]+$") then
    doc.meta.etiquette = "Laboratoire" .. (n and (" " .. n) or "")
  elseif n then
    doc.meta.etiquette = string.format("Module %02d · Exercices", n)
  else
    doc.meta.etiquette = "Exercices"
  end
  doc.blocks = corps
  return doc
end
