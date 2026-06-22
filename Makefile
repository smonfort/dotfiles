all:
	stow --verbose --target=$$HOME --no-folding --restow */

delete:
	stow --verbose --target=$$HOME --no-folding --delete */

init:
	pre-commit install --hook-type commit-msg
