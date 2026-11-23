#!/bin/sh
# Copie les PDF des présentations Beamer dans presentations/pdf/.
# Usage : sh presentations/copier-pdf.sh [dossier source]
#   dossier source : contient 01-Introduction/, 02-Denombrement/, etc.
#   (par défaut : Beamer/ à la racine du dépôt)
set -e
racine=$(cd "$(dirname "$0")/.." && pwd)
src=${1:-"$racine/Beamer"}
dst="$racine/presentations/pdf"
mkdir -p "$dst"
copier() { cp "$src/$1" "$dst/$2" && echo "$2"; }
copier 01-Introduction/01-Introduction.pdf                       01-introduction.pdf
copier 02-Denombrement/02-Denombrement.pdf                       02-denombrement.pdf
copier 03-ProbConditionnelleIndep/03-ProbConditionelleIndep.pdf  03-conditionnelle-independance.pdf
copier 04-Fondements/04-Fondements.pdf                           04-fondements.pdf
copier 05-ProbGeometriques/05-ProbGeometriques.pdf               05-probabilites-geometriques.pdf
copier 06-VADiscrete/06-VADiscrete.pdf                           06-va-discretes.pdf
copier 07-VAContinue/07-VAContinue.pdf                           07-va-continues.pdf
copier 08-EsperanceP1/08-EsperanceP1.pdf                         08-esperance-1.pdf
copier 09-EsperanceP2/09-EsperanceP2.pdf                         09-esperance-2.pdf
copier 10-VecteursAleatoires/10-VecteursAleatoires.pdf           10-vecteurs-aleatoires-1.pdf
copier 11-VecteursAleatoiresP2/11-VecteursAleatoiresP2.pdf       11-vecteurs-aleatoires-2.pdf
copier 12-NormaleEtGamma/12-NormaleGamma.pdf                     12-normale-gamma.pdf
