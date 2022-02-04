local nvim_lsp = require("lspconfig")
local lsp_installer = require("nvim-lsp-installer")
local saga = require("lspsaga")
local lsp_status = require("lsp-status")
local lsp_signature = require("lsp_signature")
local notify = require("notify")

local lsp = require("core.lsp")
local oConfig = require("config.other")

local mapopts = { noremap = true, silent = true }

lsp.symbol("Error", " ")
lsp.symbol("Warn", " ")
lsp.symbol("Hint", " ")
lsp.symbol("Info", " ")

lsp.handlers()

local on_attach = function(client, bufnr)
  notify("Attached to " .. client.name)

  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings.
  buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", mapopts)
  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", mapopts)
  buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", mapopts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", mapopts)
  buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", mapopts)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", mapopts)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", mapopts)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", mapopts)
  buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", mapopts)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", mapopts)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", mapopts)
  buf_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostics.open_float()<CR>", mapopts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostics.goto_prev()<CR>", mapopts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", mapopts)
  buf_set_keymap("n", "<space>l", "<cmd>lua vim.diagnostic.setloclist()<CR>", mapopts)
  buf_set_keymap("n", "<space>G", "<cmd>lua vim.lsp.buf.formatting()<CR>", mapopts)
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<Leader>G", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", mapopts)
  end
  vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  buf_set_keymap("v", "<space>ca", "<cmd>lua vim.lsp.buf.range_code_action()<CR>", mapopts)

  lsp_status.on_attach(client)
end

local lua_runtime_path = vim.split(package.path, ";")
table.insert(lua_runtime_path, "lua/?.lua")
table.insert(lua_runtime_path, "lua/?/init.lua")

local server_settings = {
  clangd = {
    cmd = {
      "clangd", -- '--background-index',
      "--clang-tidy",
      "--completion-style=bundled",
      "--header-insertion=iwyu",
      "--suggest-missing-includes",
      "--cross-file-rename",
    },
    handlers = lsp_status.extensions.clangd.setup(),
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true,
    },
  },
  cssls = {
    filetypes = { "css", "scss", "less", "sass" },
    root_dir = nvim_lsp.util.root_pattern("package.json", ".git"),
  },
  dockerls = {
    cmd = { "docker-langserver", "--stdio" },
    root_dir = nvim_lsp.util.root_pattern("Dockerfile*", ".git"),
  },
  graphql = { filetypes = { "graphql", "js", "ts", "tsx", "jsx" } },
  jsonls = { cmd = { "json-languageserver", "--stdio" } },
  julials = { settings = { julia = { format = { indent = 2 } } } },
  pyright = { settings = { python = { formatting = { provider = "yapf" } } } },
  solargraph = {
    cmd = { "solargraph", "stdio" },
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = false
      on_attach(client)
    end,
  },
  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim", "use" } },
        runtime = { version = "LuaJIT", path = lua_runtime_path },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
  tsserver = {
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      if client.config.flags then
        client.config.flags.allow_incremental_sync = true
      end
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>I", "lua require('core.lsp').lsp_organize_imports()<CR>", opts)
      on_attach(client)
    end,
  },
}

lsp_status.config({
  kind_labels = oConfig.kind_symbols(),
  select_symbol = function(cursor_pos, symbol)
    if symbol.valueRange then
      local value_range = {
        ["start"] = {
          character = 0,
          line = vim.fn.byte2line(symbol.valueRange[1]),
        },
        ["end"] = {
          character = 0,
          line = vim.fn.byte2line(symbol.valueRange[2]),
        },
      }

      return require("lsp-status/util").in_range(cursor_pos, value_range)
    end
  end,
})

lsp_status.register_progress()

lsp_installer.settings({
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗",
    },
  },
})

lsp_installer.on_server_ready(function(server)
  local opts = { on_attach = on_attach }

  if server_settings[server.name] then
    opts = vim.tbl_deep_extend("force", opts, server_settings[server.name])
  end

  opts = lsp.capabilities(opts)

  server:setup(opts)
  vim.cmd([[ do User LspAttachBuffers ]])
end)

local luadev = require("lua-dev").setup()
nvim_lsp.sumneko_lua.setup(luadev)

lsp.lspkind()
saga.init_lsp_saga()
lsp_signature.setup()
