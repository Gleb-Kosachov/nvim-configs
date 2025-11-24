return {
  {
    "numToStr/Comment.nvim",
    opts = {}, -- uses default mappings: `gcc`, `gbc`, etc.
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")

      npairs.setup({
        check_ts = true,        -- use treesitter awareness
        ts_config = {
          lua = { "string" },   -- don't add pairs inside strings in Lua
          java = { "string" },  -- and in Java
          python = { "string" },
        },
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {},
      })
    end,
  },
}
