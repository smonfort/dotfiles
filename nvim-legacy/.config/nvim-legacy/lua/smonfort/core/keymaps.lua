-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<M-h>", "<cmd>bp<CR>", { desc = "Open previous buffer" })
keymap.set("n", "<M-l>", "<cmd>bn<CR>", { desc = "Open next buffer" })
keymap.set("n", "<M-x>", "<cmd>bd<CR>", { desc = "Close buffer" })

-- TIP: Disable arrow keys in normal mode
keymap.set({ "n", "i", "v" }, "<left>", '<cmd>echo "Use h to move!!"<CR>')
keymap.set({ "n", "i", "v" }, "<right>", '<cmd>echo "Use l to move!!"<CR>')
keymap.set({ "n", "i", "v" }, "<up>", '<cmd>echo "Use k to move!!"<CR>')
keymap.set({ "n", "i", "v" }, "<down>", '<cmd>echo "Use j to move!!"<CR>')
