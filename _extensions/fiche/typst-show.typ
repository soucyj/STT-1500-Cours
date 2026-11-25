#show: doc => fiche(
$if(title)$
  title: [$title$],
$endif$
$if(etiquette)$
  etiquette: [$etiquette$],
$endif$
$if(intro)$
  intro: [$intro$],
$endif$
  doc,
)
