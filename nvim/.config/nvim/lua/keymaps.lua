-- set leader key to space
vim.g.mapleader = " "

-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x')
vim.keymap.set({ "n", "i", "v" }, "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set({ "n", "i", "v" }, "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set({ "n", "i", "v" }, "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set({ "n", "i", "v" }, "<down>", '<cmd>echo "Use j to move!!"<CR>')
