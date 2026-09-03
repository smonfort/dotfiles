import { execFileSync } from "node:child_process";
import { useEffect, useState } from "react";
import { Action, ActionPanel, Grid, Icon, type Image, Toast, closeMainWindow, showToast } from "@vicinae/api";

type AerospaceWindow = {
	workspace: string;
	"app-name": string;
	"app-bundle-id": string;
	"window-id": number;
};

type WindowCard = {
	id: number;
	workspace: string;
	appName: string;
	icon: Image.ImageLike;
};

// Absolute path: the extension host's PATH doesn't include Homebrew's bin dir.
const AEROSPACE_BIN = "/opt/homebrew/bin/aerospace";

// Resolves a bundle id to its .app path via Spotlight metadata, so its system icon can be rendered.
function appIcon(bundleId: string): Image.ImageLike {
	try {
		const path = execFileSync("/usr/bin/mdfind", [`kMDItemCFBundleIdentifier == '${bundleId}'`], { encoding: "utf8" })
			.split("\n")
			.filter(Boolean)[0];
		return path ? { fileIcon: path } : Icon.AppWindow;
	} catch {
		return Icon.AppWindow;
	}
}

function loadWindows(): WindowCard[] {
	let windows: AerospaceWindow[] = [];
	try {
		const raw = execFileSync(
			AEROSPACE_BIN,
			[
				"list-windows",
				"--all",
				"--json",
				"--format",
				"%{workspace} %{app-name} %{app-bundle-id} %{window-id}",
			],
			{ encoding: "utf8" },
		);
		windows = JSON.parse(raw);
	} catch {
		windows = [];
	}

	const iconCache = new Map<string, Image.ImageLike>();
	return windows
		.map((w) => {
			if (!iconCache.has(w["app-bundle-id"])) iconCache.set(w["app-bundle-id"], appIcon(w["app-bundle-id"]));
			return {
				id: w["window-id"],
				workspace: w.workspace,
				appName: w["app-name"],
				icon: iconCache.get(w["app-bundle-id"])!,
			};
		})
		.sort((a, b) => a.workspace.localeCompare(b.workspace) || a.appName.localeCompare(b.appName));
}

async function moveTo(windowId: number) {
	try {
		execFileSync(AEROSPACE_BIN, ["focus", "--window-id", String(windowId)]);
		await closeMainWindow();
	} catch (error) {
		await showToast({ style: Toast.Style.Failure, title: "Failed to focus window", message: String(error) });
	}
}

export default function Command() {
	const [windows, setWindows] = useState<WindowCard[]>([]);
	const [isLoading, setIsLoading] = useState(true);

	useEffect(() => {
		setWindows(loadWindows());
		setIsLoading(false);
	}, []);

	return (
		<Grid isLoading={isLoading} columns={6}>
			{windows.map((w) => (
				<Grid.Item
					key={w.id}
					content={w.icon}
					title={w.appName}
					subtitle={`Workspace ${w.workspace}`}
					actions={
						<ActionPanel>
							<Action title="Move to Application" icon={Icon.ArrowRight} onAction={() => moveTo(w.id)} />
						</ActionPanel>
					}
				/>
			))}
		</Grid>
	);
}
