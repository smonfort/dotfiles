import { execFileSync } from "node:child_process";
import { useState } from "react";
import {
	Action,
	ActionPanel,
	Alert,
	Icon,
	List,
	Toast,
	closeMainWindow,
	confirmAlert,
	showToast,
} from "@vicinae/api";

// Same tokyonight-night hex values as the claude-sessions extension, for
// visual consistency across the vicinae setup.
const TOKYONIGHT = {
	blue: "#7aa2f7",
	green: "#9ece6a",
	comment: "#565f89",
};

// Absolute paths: the extension host's PATH doesn't include Homebrew's bin dir.
const TMUX = "/opt/homebrew/bin/tmux";
const TMUXINATOR = "/opt/homebrew/bin/tmuxinator";

type Kind = "attached" | "open" | "closed";

type Session = {
	name: string;
	kind: Kind;
};

function loadSessions(): Session[] {
	let sessionsRaw = "";
	try {
		sessionsRaw = execFileSync(TMUX, ["list-sessions", "-F", "#{session_attached},#{session_name}"], {
			encoding: "utf8",
		});
	} catch {
		sessionsRaw = "";
	}

	const attached = new Set<string>();
	const openNames = new Set<string>();
	for (const line of sessionsRaw.split("\n").filter(Boolean)) {
		const [flag, name] = line.split(",");
		openNames.add(name);
		if (Number(flag) > 0) attached.add(name);
	}

	let projectNames: string[] = [];
	try {
		projectNames = execFileSync("bash", ["-c", "find -L ~/.tmuxinator/ -maxdepth 1 -type f -name '*.yml'"], {
			encoding: "utf8",
		})
			.split("\n")
			.filter(Boolean)
			.map((path) => path.split("/").pop()!.replace(/\.yml$/, ""));
	} catch {
		projectNames = [];
	}

	const sessions: Session[] = [...openNames]
		.sort()
		.map((name) => ({ name, kind: attached.has(name) ? "attached" : "open" }) as Session);

	for (const name of projectNames.sort()) {
		if (!openNames.has(name)) sessions.push({ name, kind: "closed" });
	}

	return sessions;
}

async function switchTo(session: Session) {
	try {
		if (session.kind === "closed") execFileSync(TMUXINATOR, ["start", session.name]);
		execFileSync(TMUX, ["switch-client", "-t", session.name]);
		await closeMainWindow();
	} catch (error) {
		await showToast({ style: Toast.Style.Failure, title: "Failed to switch session", message: String(error) });
	}
}

async function killSession(session: Session, refresh: () => void) {
	const confirmed = await confirmAlert({
		title: `Kill "${session.name}" session?`,
		message:
			session.kind === "attached"
				? "This is your currently attached session, killing it will detach your tmux client."
				: "This terminates the session and all its panes.",
		primaryAction: { title: "Kill Session", style: Alert.ActionStyle.Destructive },
	});
	if (!confirmed) return;

	try {
		execFileSync(TMUX, ["kill-session", "-t", session.name]);
		await showToast({ style: Toast.Style.Success, title: `Killed "${session.name}"` });
		refresh();
	} catch (error) {
		await showToast({ style: Toast.Style.Failure, title: "Failed to kill session", message: String(error) });
	}
}

const KIND_ICON: Record<Kind, { source: Icon; tintColor: string }> = {
	attached: { source: Icon.Pin, tintColor: TOKYONIGHT.blue },
	open: { source: Icon.CircleFilled, tintColor: TOKYONIGHT.green },
	closed: { source: Icon.Moon, tintColor: TOKYONIGHT.comment },
};

export default function Command() {
	const [sessions, setSessions] = useState<Session[]>(() => loadSessions());
	const refresh = () => setSessions(loadSessions());

	const bySection = {
		attached: sessions.filter((s) => s.kind === "attached"),
		open: sessions.filter((s) => s.kind === "open"),
		closed: sessions.filter((s) => s.kind === "closed"),
	};

	const renderItem = (session: Session) => (
		<List.Item
			key={session.name}
			title={session.name}
			icon={KIND_ICON[session.kind]}
			actions={
				<ActionPanel>
					<Action title="Switch to Session" onAction={() => switchTo(session)} />
					{session.kind !== "closed" && (
						<Action
							title="Kill Session"
							icon={Icon.Trash}
							style={Action.Style.Destructive}
							shortcut={{ key: "enter", modifiers: ["shift"] }}
							onAction={() => killSession(session, refresh)}
						/>
					)}
				</ActionPanel>
			}
		/>
	);

	return (
		<List searchBarPlaceholder="Search sessions…">
			{bySection.attached.length > 0 && (
				<List.Section title="Attached session">{bySection.attached.map(renderItem)}</List.Section>
			)}
			{bySection.open.length > 0 && (
				<List.Section title="Running sessions">{bySection.open.map(renderItem)}</List.Section>
			)}
			{bySection.closed.length > 0 && (
				<List.Section title="Other projects">{bySection.closed.map(renderItem)}</List.Section>
			)}
		</List>
	);
}
