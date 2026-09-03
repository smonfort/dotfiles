import { execFileSync } from "node:child_process";
import { useEffect, useState } from "react";
import {
	Action,
	ActionPanel,
	Icon,
	type Image,
	List,
	Toast,
	closeMainWindow,
	showToast,
} from "@vicinae/api";

// Same tokyonight-night hex values as variables.sh (sketchybar) and the
// installed vicinae theme, for visual consistency with the nvim colorscheme
// (dotfiles/nvim/.config/nvim/plugin/00-colorscheme.lua) — raw ColorLike
// strings rather than vicinae's generic Color enum.
const TOKYONIGHT = {
	blue: "#7aa2f7",
	yellow: "#e0af68",
	green: "#9ece6a",
	orange: "#ff9e64",
	comment: "#565f89",
};

// Reuses the shared bash helpers (also used by ack-claude-notification.sh)
// rather than re-implementing pid->pane resolution here.

type Session = {
	sortKey: number;
	paneId: string;
	sessionId: string;
	tmuxSession: string;
	kind: string;
	name: string;
	cwd: string;
	status: string;
};

const KIND_COLOR: Record<string, string> = {
	permission: TOKYONIGHT.orange,
	idle: TOKYONIGHT.yellow,
	done: TOKYONIGHT.green,
};

const BADGE_TO_KIND: Record<string, string> = {
	"🔐": "permission",
	"⏳": "idle",
	"✅": "done",
	"🔔": "notified",
};

// The icon reflects Claude's own live status (is it working right now?),
// distinct from the "kind" tag above (has the user acknowledged it?). Same
// idea as the sketchybar claude_session icons (plugins/claude.sh): busy
// gets a "thinking" glyph instead of a lightning bolt, which read as an
// error/interrupt rather than active work.
const STATUS_ICON: Record<string, Image.ImageLike> = {
	busy: { source: Icon.CircleProgress, tintColor: TOKYONIGHT.green },
	idle: { source: Icon.Checkmark, tintColor: TOKYONIGHT.comment },
	waiting: { source: Icon.Hourglass, tintColor: TOKYONIGHT.orange },
};
const DEFAULT_STATUS_ICON: Image.ImageLike = { source: Icon.CircleFilled, tintColor: TOKYONIGHT.comment };

const ROW_PATTERN = /^\[([^\]]*)\] (?:(🔐|⏳|✅|🔔) )?(.*) \((.*)\)$/;

function loadSessions(): Session[] {
	let raw = "";
	try {
		raw = execFileSync(
			"bash",
			[
				"-c",
				"source ~/.config/tmux/claude-notifications-common.sh && claude_session_rows",
			],
			{ encoding: "utf8" },
		);
	} catch {
		return [];
	}

	return raw
		.split("\n")
		.filter(Boolean)
		.flatMap((line) => {
			const [sortKey, paneId, sessionId, label, status] = line.split("\t");
			const match = label?.match(ROW_PATTERN);
			if (!match) return [];
			const [, tmuxSession, badge, name, cwd] = match;
			return [
				{
					sortKey: Number(sortKey),
					paneId,
					sessionId,
					tmuxSession,
					kind: badge ? (BADGE_TO_KIND[badge] ?? "") : "",
					name,
					cwd,
					status: status ?? "",
				},
			];
		});
}

async function switchTo(paneId: string) {
	try {
		execFileSync("bash", [
			"-c",
			'source ~/.config/tmux/focus-claude-pane.sh && focus_claude_pane "$1"',
			"_",
			paneId,
		]);
		await closeMainWindow();
	} catch (error) {
		await showToast({
			title: "Failed to switch session",
			message: String(error),
			style: Toast.Style.Failure,
		});
	}
}

export default function Command() {
	const [sessions, setSessions] = useState<Session[]>([]);
	const [isLoading, setIsLoading] = useState(true);

	useEffect(() => {
		setSessions(loadSessions());
		setIsLoading(false);
	}, []);

	return (
		<List isLoading={isLoading}>
			{sessions.map((s) => (
				<List.Item
					key={s.paneId}
					title={s.name}
					subtitle={s.cwd}
					icon={STATUS_ICON[s.status] ?? DEFAULT_STATUS_ICON}
					accessories={[
						...(s.kind
							? [{ tag: { value: s.kind, color: KIND_COLOR[s.kind] ?? TOKYONIGHT.orange } }]
							: []),
						{ tag: { value: s.tmuxSession, color: TOKYONIGHT.blue } },
					]}
					actions={
						<ActionPanel>
							<Action title="Switch to Session" onAction={() => switchTo(s.paneId)} />
						</ActionPanel>
					}
				/>
			))}
		</List>
	);
}
