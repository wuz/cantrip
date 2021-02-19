local map = require "utils".map

local function prettier()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote"},
    stdin = true
  }
end

local function clangformat()
  return {exe = "clang-format", args = {"-assume-filename=" .. vim.fn.expand("%:t")}, stdin = true}
end

local function rustfmt()
  return {exe = "rustfmt", args = {"--emit=stdout"}, stdin = true}
end
local function lua_format()
  return {
    exe = "luafmt",
    args = {"--indent-count", 2, "--stdin"},
    stdin = true
  }
end
local function mdx_format()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote", "--parser", "mdx"},
    stdin = true
  }
end
local function yapf()
  return {exe = "yapf", stdin = true}
end
local function isort()
  return {exe = "isort", args = {"-", "--quiet"}, stdin = true}
end
local function latexindent()
  return {exe = "latexindent", args = {"-sl", "-g /dev/stderr", "2>/dev/null"}, stdin = true}
end

require("formatter").setup(
  {
    logging = false,
    filetype = {
      javascript = {prettier},
      json = {prettier},
      html = {prettier},
      ['markdown.mdx'] = {mdx_format},
      rust = {rustfmt},
      python = {isort, yapf},
      tex = {latexindent},
      c = {clangformat},
      cpp = {clangformat},
      lua = {lua_format}
    }
  }
)

-- Keymap
map("n", "<leader>F", "<cmd>Format<cr>", silent)
