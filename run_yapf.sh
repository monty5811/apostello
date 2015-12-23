# run yapf to keep code formatting consistent
echo "Running yapf..."
yapf -r -i apostello/ graphs/ api/ settings/ -e assets
# run isort after yapf to fix up imports
echo "Running isort..."
isort -rc apostello/ api/ graphs/