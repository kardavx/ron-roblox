# git bashem wywołujcie ten skrypt
echo "Updating packages..."
rm wally.lock
wally install
echo "Updating package types..."
rojo sourcemap default.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/

# naprawienie reacta
# mv Packages/_Index/jsdotlua_luau-polyfill@1.2.5/luau-polyfill/src/* Packages/_Index/jsdotlua_luau-polyfill@1.2.5/luau-polyfill/