return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 30 },
        -- filters = { dotfiles = true },
        renderer = { group_empty = true },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

      -- Automatically open nvim-tree when starting Neovim on a directory
      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        callback = function(data)
          if vim.api.nvim_win_get_config(0).zindex ~= nil then
            require("nvim-tree.api").tree.open()
            vim.cmd("wincmd p")
          else
            require("nvim-tree.api").tree.open()
          end
        end,
      })

      -- -- Close Neovim if nvim-tree is the last buffer open
      -- vim.api.nvim_create_autocmd("BufEnter", {
      --   nested = true,
      --   callback = function()
      --     if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
      --       vim.cmd("quit")
      --     end
      --   end,
      -- })
    end,
  },
  {
    "stevearc/aerial.nvim",
    opts = {
      layout = { min_width = 30 },
      close_on_select = false,
      show_guides = true,
    },
    keys = {
      { "<leader>aa", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial outline" },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>sf", "<cmd>Telescope find_files<CR>",  desc = "Find files" },
      { "<leader>ss", "<cmd>Telescope live_grep<CR>",   desc = "Live grep" },
      -- { "<leader>sb", "<cmd>Telescope buffers<CR>",     desc = "Buffers" },
      { "<leader>sh", "<cmd>Telescope help_tags<CR>",   desc = "Help tags" },
      { "<leader>sa", "<cmd>Telescope aerial<CR>",      desc = "Search symbols (Aerial)" },
      { "<leader>se", function()
        require("telescope.builtin").grep_string{ shorten_path = true, word_match = "-w", only_sort_text = true, search = '' }
        end, desc = "Fuzzy search of file contents" },
    },
  },
}
