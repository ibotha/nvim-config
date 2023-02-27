local wk = require("which-key")

-- Location bindings
wk.register({
    name = "File",
    f = {function () require('telescope.builtin').find_files() end, "find"},
    g = {function () require('telescope.builtin').live_grep() end, "grep"},
    e = {function () require('nvim-tree').focus() end, "tree"}
}, {
    mode = "n",
    prefix = "<leader>f"
})

