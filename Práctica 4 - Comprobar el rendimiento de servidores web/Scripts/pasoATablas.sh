#!/bin/bash

if [ $# -ne 4 ]
then
  echo "Tienes que meter 4 parámetros"
  echo "./pasoATablas.sh <programa> <parámetro> <nombreTabla> <etiquetaX>"
  exit 1
fi

declare -A MAPHOSTS=( ["servidor"]="Servidor web" ["granja_nginx"]="Granja Nginx" ["granja_haproxy"]="Granja Haproxy" )
HOSTS=(${!MAPHOSTS[@]})
HOSTS=(${HOSTS[@]/"servidor"})

PROGRAMA="$1"
PARAMETRO="$2"
NOMBRETABLA="$3"
XLABEL="$4"

tmp=$( mktemp )
tmp2=$( mktemp )
tmp3=$( mktemp )

if ! [ -e "../Datos/$PROGRAMA-${HOSTS[0]}-$PARAMETRO.dat" ]; then echo "../Datos/$PROGRAMA-${HOSTS[0]}-$PARAMETRO.dat no existe"; exit 1; fi
if ! [ -e "../Datos/$PROGRAMA-${HOSTS[1]}-$PARAMETRO.dat" ]; then echo "../Datos/$PROGRAMA-${HOSTS[0]}-$PARAMETRO.dat no existe"; exit 1; fi


cat "../Datos/$PROGRAMA-${HOSTS[0]}-$PARAMETRO.dat" | cut -d" " -f2- > $tmp
cat "../Datos/$PROGRAMA-${HOSTS[1]}-$PARAMETRO.dat" | cut -d" " -f2- > $tmp2

paste -d" " "../Datos/$PROGRAMA-servidor-$PARAMETRO.dat" $tmp $tmp2 > $tmp3

echo "<table>"
echo "  <tr>"
echo "    <th colspan="7" style="text-align:center">$NOMBRETABLA</th>"
echo "  </tr>"
echo "  <tr>"
echo "    <th></th>"
echo "    <th colspan="2" style="text-align:center">${MAPHOSTS["servidor"]}</th>"
echo "    <th colspan="2" style="text-align:center">${MAPHOSTS[${HOSTS[0]}]}</th>"
echo "    <th colspan="2" style="text-align:center">${MAPHOSTS[${HOSTS[1]}]}</th>"
echo "  </tr>"
echo "  <tr>"
echo "    <th>$XLABEL</th>"
echo "    <th>Media</th>"
echo "    <th>Error</th>"
echo "    <th>Media</th>"
echo "    <th>Error</th>"
echo "    <th>Media</th>"
echo "    <th>Error</th>"
echo "   </tr>"

while read -r peticiones media1 error1 media2 error2 media3 error3
do
  echo "  <tr>"
  echo "    <td>$peticiones"
  echo "    <td>$media1"
  echo "    <td>$error1"
  echo "    <td>$media2"
  echo "    <td>$error2"
  echo "    <td>$media3"
  echo "    <td>$error3"
  echo "  </tr>"
done < $tmp3
echo "</table>"

echo "![Gráfica $PROGRAMA-$PARAMETRO](Imágenes/$PROGRAMA-$PARAMETRO.png)"
