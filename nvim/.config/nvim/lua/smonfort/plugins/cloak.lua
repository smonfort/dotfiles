-- Cloak allows you to overlay *'s over defined patterns in defined files.
return {
	"laytan/cloak.nvim",
	config = function()
		local cloak = require("cloak")
		cloak.setup({})
		vim.keymap.set("n", "<leader>cc", "<cmd>CloakToggle<cr>", { desc = "Toggle cloak" })
	end,
}
