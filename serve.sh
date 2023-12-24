# git bashem wywołujcie ten skrypt
if [ $# -eq 0 ]
  then
    echo -e "\e[31mNie podałeś nazwy pliku projektu!\e[0m"
    echo "Użycie: rojo-serve.sh projekt"
    echo ""
    echo "Możliwe projekty: "
    find -maxdepth 1 -iname "*.project.json" -exec basename {} .project.json \;

    exit 1
fi  

rojo sourcemap $1.project.json > sourcemap.json
rojo serve $1.project.json