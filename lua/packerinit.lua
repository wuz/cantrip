vim.cmd "packadd packer.nvim"

local present, packer = pcall(require, "packer")

if not present then
	print("HERE")
   local packer_path = vim.fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"

   print "Cloning packer.."
   -- remove the dir before cloning
   vim.fn.delete(packer_path, "rf")
   vim.fn.system {
      "git",
      "clone",
      "https://github.com/wbthomason/packer.nvim",
      "--depth",
      "20",
      packer_path,
   }

   vim.cmd "packadd packer.nvim"
   present, packer = pcall(require, "packer")

   if present then
      print "Packer cloned successfully."
   else
      error("Couldn't clone packer !\nPacker path: " .. packer_path .. "\n" .. packer)
   end
end

packer.init {
   profile = {
     enable = true,
     threshold = 1 -- the amount in ms that a plugins load time must be over for it to be included in the profile
   },
   display = {
      open_fn = require('packer.util').float,
      prompt_border = "single",
   },
   git = {
      clone_timeout = 6000, -- seconds
   },
   auto_clean = true,
   compile_on_sync = true,
}

return packer
