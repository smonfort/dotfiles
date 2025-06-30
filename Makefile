all:
	stow --verbose --target=$$HOME --restow */

delete:
	stow --verbose --target=$$HOME --delete */

init:
	pre-commit install --hook-type commit-msg
