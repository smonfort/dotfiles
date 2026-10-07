all:
	stow --verbose --target=$$HOME --no-folding --restow */

delete:
	stow --verbose --target=$$HOME --no-folding --delete */

init:
	pre-commit install --hook-type commit-msg

.PHONY: aerospace
aerospace:
	npx --yes toml-x merge --skip-comment $$HOME/.config/aerospace/fragments/*.toml > $$HOME/.config/aerospace/aerospace.toml

.PHONY: vicinae-extensions
vicinae-extensions:
	for ext in vicinae/extensions/*/; do \
		(cd "$$ext" && npm install && npx vici build) || exit 1; \
	done

WMPRUNE_PLIST := $$HOME/Library/LaunchAgents/com.smonfort.wmprune.plist

# (Re)load the launchd agent that removes worktrees of merged PRs.
.PHONY: wmprune
wmprune: all
	-launchctl bootout gui/$$(id -u) $(WMPRUNE_PLIST) 2>/dev/null
	launchctl bootstrap gui/$$(id -u) $(WMPRUNE_PLIST)

.PHONY: wmprune-unload
wmprune-unload:
	launchctl bootout gui/$$(id -u) $(WMPRUNE_PLIST)
