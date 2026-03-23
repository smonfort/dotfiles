-- Quickstart configs for Nvim LSP
return {
	"neovim/nvim-lspconfig",
	config = function()
		local dict_path = vim.fn.stdpath("config") .. "/ltex/"

		local function read_dict(path)
			local words = {}
			local file = io.open(path, "r")
			if file then
				for line in file:lines() do
					line = line:match("^%s*(.-)%s*$")
					if #line > 0 then
						table.insert(words, line)
					end
				end
				file:close()
			end
			return words
		end

		vim.lsp.config("ltex_plus", {
			settings = {
				ltex = {
					dictionary = {
						["en-US"] = read_dict(dict_path .. "en.txt"),
						["fr"] = read_dict(dict_path .. "fr.txt"),
					},
				},
			},
		})
	end,
}
