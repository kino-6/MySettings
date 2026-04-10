local uv = vim.uv or vim.loop
local fs_stat = uv and uv.fs_stat or nil

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_exists = fs_stat and fs_stat(lazypath)

if not lazy_exists then
  local ok = pcall(vim.fn.system, {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })

  if not ok then
    vim.notify("Failed to bootstrap lazy.nvim", vim.log.levels.ERROR)
    return
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "mysettings.plugins.spec" },
}, {
  checker = { enabled = false },
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
})
