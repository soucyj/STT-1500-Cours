-- ═══════════════════════════════════════════════════════════════════════
--  solutions.lua — contenu publié à partir d'une date et d'une heure
--
--  1. Une page entière (les questions d'un laboratoire), dans l'en-tête :
--       disponible: "2026-12-05 08:00"
--     Avant ce moment, la page n'affiche que « Disponible le 5 décembre
--     2026 à 8 h ». Le titre et la description restent visibles (liste
--     des laboratoires).
--
--  2. Une solution, dans le texte :
--       ::: {.corrige date="2026-12-05 18:00"}
--       Le contenu de la solution…
--       :::
--     Avant ce moment, le bloc est retiré du HTML et remplacé par
--     « Solution : disponible le 5 décembre 2026 à 18 h ». Ensuite, il
--     s'affiche dans un encadré repliable.
--     L'en-tête de la page peut donner une date commune à toutes ses
--     solutions (corrige: "2026-12-05 18:00") ; date= sur un bloc l'emporte.
--     Sans date (ni date= ni corrige: dans l'en-tête), la solution est
--     publiée d'emblée (c'est le cas des séries d'exercices).
--     Attributs facultatifs : titre="…" (défaut « Solution »),
--     ouvert="true" (encadré déplié d'emblée).
--
--  3. Le calendrier de publication _publication.yml (racine du dépôt, non
--     publié sur le site) fixe ces moments sans toucher aux pages :
--     diapositives, exercices et solutions de chaque module ; énoncé et
--     solution de chaque laboratoire. Une date donnée dans l'en-tête d'une
--     page l'emporte sur _publication.yml.
--
--  Dates : "AAAA-MM-JJ" (minuit) ou "AAAA-MM-JJ HH:MM", heure de Québec.
--  Le site est régénéré deux fois par heure par GitHub Actions
--  (.github/workflows/publish.yml) : prévoir jusqu'à une demi-heure de
--  délai, parfois un peu plus.
--
--  Pour tester localement :
--    SOLUTIONS=toutes quarto preview            tout afficher (aperçu)
--    MAINTENANT="2026-12-05 19:00" quarto preview   simuler un moment
-- ═══════════════════════════════════════════════════════════════════════

local mois = { "janvier", "février", "mars", "avril", "mai", "juin",
  "juillet", "août", "septembre", "octobre", "novembre", "décembre" }

local maintenant = os.getenv("MAINTENANT")
if maintenant and maintenant ~= "" then
  if #maintenant == 10 then maintenant = maintenant .. " 00:00" end
else
  maintenant = os.date("%Y-%m-%d %H:%M")
end
local tout_montrer = os.getenv("SOLUTIONS") == "toutes"

-- "2026-12-05" ou "2026-12-05 18:00" → clé comparable et texte français
local function lire_date(texte, ou)
  local a, m, j, h, mi =
    texte:match("^%s*(%d%d%d%d)-(%d%d)-(%d%d)[ T]+(%d%d?):(%d%d)%s*$")
  if not a then
    a, m, j = texte:match("^%s*(%d%d%d%d)-(%d%d)-(%d%d)%s*$")
    h, mi = "0", "00"
  end
  if not a or tonumber(m) < 1 or tonumber(m) > 12 then
    error("Date invalide (" .. ou .. ") : « " .. texte ..
      " » ; formats attendus : AAAA-MM-JJ ou AAAA-MM-JJ HH:MM")
  end
  local cle = string.format("%s-%s-%s %02d:%s", a, m, j, tonumber(h), mi)
  local jour = tonumber(j) == 1 and "1er" or tostring(tonumber(j))
  local fr = jour .. " " .. mois[tonumber(m)] .. " " .. a
  if not (tonumber(h) == 0 and mi == "00") then
    fr = fr .. " à " .. tonumber(h) .. " h" .. (mi ~= "00" and " " .. mi or "")
  end
  return cle, fr
end

local function echapper(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- ── Calendrier de publication (_publication.yml) ─────────────────────────
local function charger_publication()
  local dossier = quarto.project.directory
  if not dossier then return nil end
  local f = io.open(dossier .. "/_publication.yml", "r")
  if not f then return nil end
  local texte = f:read("a")
  f:close()
  return pandoc.read("---\n" .. texte .. "\n---\n", "markdown").meta
end

-- Les numéros s'écrivent "01" ou "1" : on essaie les deux formes
local function champ(t, ...)
  for _, cle in ipairs({ ... }) do
    if type(t) ~= "table" then return nil end
    local nombre = tonumber(cle)
    t = t[cle] or (nombre and (t[tostring(nombre)] or t[string.format("%02d", nombre)]))
  end
  if t == nil then return nil end
  return pandoc.utils.stringify(t)
end

-- "veille 08:00" / "jour 10:30" (relatifs à la date du labo) ou date fixe
local function resoudre(regle, date_labo)
  if not regle then return nil end
  local quand, heure = regle:match("^%s*(%a+)%s+(%d%d?:%d%d)%s*$")
  if quand == "veille" or quand == "jour" then
    local a, m, j = date_labo:match("^%s*(%d%d%d%d)-(%d%d)-(%d%d)")
    if not a then error("Date de laboratoire invalide : " .. date_labo) end
    local decalage = (quand == "veille") and -1 or 0
    local t = os.time({ year = tonumber(a), month = tonumber(m),
      day = tonumber(j) + decalage, hour = 12 })
    return os.date("%Y-%m-%d", t) .. " " .. heure
  end
  return regle
end

local function numero_page(meta)
  if not meta.numero then return nil end
  local n = tonumber(pandoc.utils.stringify(meta.numero))
  return n and string.format("%02d", n) or nil
end

local function section_page()
  local fichier = (quarto.doc.input_file or ""):gsub("\\", "/")
  return fichier:match("/(exercices)/[^/]+$")
      or fichier:match("/(presentations)/[^/]+$")
      or fichier:match("/(laboratoires)/[^/]+$")
end

local function lien_pdf_retenu(date_texte)
  local _, fr = lire_date(date_texte, "_publication.yml")
  return pandoc.Span({ pandoc.Strong("Diapositives (PDF)"),
    pandoc.Str(" : disponibles le " .. fr .. ".") }, { class = "corrige-a-venir" })
end

local function corrige(el, date_page)
  local texte = el.attributes["date"] or date_page
  local titre = el.attributes["titre"] or "Solution"
  -- Sans date (ni sur le bloc ni dans l'en-tête) : publiée d'emblée
  local cle, fr, publiee = nil, nil, true
  if texte then
    cle, fr = lire_date(texte, "bloc .corrige")
    publiee = cle <= maintenant
  end

  if not publiee and not tout_montrer then
    return pandoc.Div(
      pandoc.Para({ pandoc.Strong(titre), pandoc.Str(" : disponible le "),
        pandoc.Str(fr), pandoc.Str(".") }),
      { class = "corrige-a-venir" })
  end

  if not quarto.doc.is_format("html") then
    return pandoc.Div(el.content, { class = "corrige" })
  end

  local etiquette = echapper(titre)
  if not publiee then
    etiquette = etiquette ..
      ' <span class="corrige-apercu">aperçu — publiée le ' .. fr .. "</span>"
  end
  local ouvert = el.attributes["ouvert"] == "true" and " open" or ""

  local blocs = pandoc.List({
    pandoc.RawBlock("html", '<details class="corrige"' .. ouvert ..
      "><summary>" .. etiquette .. "</summary>"),
  })
  blocs:extend(el.content)
  blocs:insert(pandoc.RawBlock("html", "</details>"))
  return blocs
end

function Pandoc(doc)
  -- Dates tirées de _publication.yml, sauf si l'en-tête les donne déjà
  local pub = charger_publication()
  local section, n = section_page(), numero_page(doc.meta)
  if pub and section and n then
    local enonce, solution
    if section == "exercices" then
      enonce = champ(pub, "modules", n, "exercices")
      solution = champ(pub, "modules", n, "solutions")
    elseif section == "laboratoires" then
      local date_labo = champ(pub, "laboratoires", n, "date")
      if date_labo then
        enonce = resoudre(champ(pub, "laboratoires", n, "enonce")
          or champ(pub, "defauts", "laboratoires", "enonce"), date_labo)
        solution = resoudre(champ(pub, "laboratoires", n, "solution")
          or champ(pub, "defauts", "laboratoires", "solution"), date_labo)
      end
    elseif section == "presentations" then
      local diapos = champ(pub, "modules", n, "diapositives")
      if diapos and lire_date(diapos, "_publication.yml") > maintenant
          and not tout_montrer then
        doc.blocks = doc.blocks:walk({
          Link = function(el)
            if el.target:match("%.pdf$") then return lien_pdf_retenu(diapos) end
          end,
        })
      end
    end
    if enonce and not doc.meta.disponible then
      doc.meta.disponible = pandoc.MetaString(enonce)
    end
    if solution and not doc.meta.corrige then
      doc.meta.corrige = pandoc.MetaString(solution)
    end
  end

  -- Page entière pas encore disponible : on ne garde qu'un avis
  if doc.meta.disponible then
    local cle, fr = lire_date(pandoc.utils.stringify(doc.meta.disponible),
      "en-tête disponible:")
    if cle > maintenant then
      if not tout_montrer then
        doc.blocks = pandoc.Blocks({ pandoc.Div(
          pandoc.Para({ pandoc.Str("Disponible le " .. fr .. ".") }),
          { class = "corrige-a-venir" }) })
        doc.meta.toc = false
        return doc
      end
      doc.blocks:insert(1, pandoc.Div(
        pandoc.Para({ pandoc.Strong("Aperçu"),
          pandoc.Str(" — cette page sera publiée le " .. fr .. ".") }),
        { class = "corrige-a-venir" }))
    end
  end

  local date_page = doc.meta.corrige and
    pandoc.utils.stringify(doc.meta.corrige) or nil
  doc.blocks = doc.blocks:walk({
    Div = function(el)
      if el.classes:includes("corrige") then return corrige(el, date_page) end
    end,
  })
  return doc
end
