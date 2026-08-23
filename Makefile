all:
	stow --verbose --target=$$HOME --no-folding --restow */

delete:
	stow --verbose --target=$$HOME --no-folding --delete */

init:
	pre-commit install --hook-type commit-msg

.PHONY: aerospace
aerospace:
	npx --yes toml-x merge --skip-comment $$HOME/.config/aerospace/fragments/*.toml > $$HOME/.config/aerospace/aerospace.toml
