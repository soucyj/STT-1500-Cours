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
--     Attributs facultatifs : titre="…" (défaut « Solution »),
--     ouvert="true" (encadré déplié d'emblée).
--
--  Dates : "AAAA-MM-JJ" (minuit) ou "AAAA-MM-JJ HH:MM", heure de Québec.
--  Le site est régénéré chaque heure par GitHub Actions
--  (.github/workflows/publish.yml) : prévoir jusqu'à une heure de délai.
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

local function corrige(el, date_page)
  local texte = el.attributes["date"] or date_page
  if not texte then
    error("Bloc .corrige sans date : ajouter date=\"AAAA-MM-JJ HH:MM\" " ..
      "au bloc ou corrige: dans l'en-tête de la page")
  end
  local cle, fr = lire_date(texte, "bloc .corrige")
  local titre = el.attributes["titre"] or "Solution"
  local publiee = cle <= maintenant

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
