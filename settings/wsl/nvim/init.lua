vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("mysettings.core.options")
require("mysettings.core.keymaps")

local ok, _ = pcall(require, "mysettings.plugins")
if not ok then
  vim.schedule(function()
    vim.notify("Failed to load plugin bootstrap (mysettings.plugins)", vim.log.levels.ERROR)
  end)
end
