local cmd = vim.cmd
local fn = vim.fn

cmd(
  [[
call wilder#setup({'modes': [':', '/', '?']})
call wilder#set_option('use_python_remote_plugin', 0)
call wilder#set_option('pipeline', [ wilder#branch( wilder#cmdline_pipeline({ 'use_python': 0, 'fuzzy': 1, 'fuzzy_filter': wilder#lua_fzy_filter(), }), wilder#vim_search_pipeline(),), ])
call wilder#set_option('renderer', wilder#popupmenu_renderer({ 'highlighter': wilder#lua_fzy_highlighter(), 'left': [ wilder#popupmenu_devicons() ], 'right': [ ' ', wilder#popupmenu_scrollbar(), ] }))
]]
)
