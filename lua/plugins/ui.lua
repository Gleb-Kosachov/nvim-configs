return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "everforest", -- matches your color scheme
          icons_enabled = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = false,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = {
            "location",
            function()
              local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
              if #buf_clients == 0 then
                return "No LSP"
              end
              local names = {}
              for _, client in ipairs(buf_clients) do
                table.insert(names, client.name)
              end
              return " " .. table.concat(names, ", ")
            end
          },
        },
      })
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end
  },
  {
    "folke/snacks.nvim",
    branch = "main",
    lazy = false,
    priority = 1000,
    cond = vim.fn.has("nvim-0.9.4") == 1, -- snacks requires relatively recent Neovim
    opts = {
      input = { enabled = true },
      picker = { enabled = true},
    },
    keys = {
      { "gr", function() Snacks.picker.lsp_references({focus = "list"}) end, desc = "References"},
       -- git
      { "<leader>gb", function() Snacks.picker.git_branches({focus = "list"}) end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log({focus = "list"}) end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line({focus = "list"}) end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status({focus = "list"}) end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash({focus = "list"}) end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff({focus = "list"}) end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file({focus = "list"}) end, desc = "Git Log File" },
       -- search
      { '<leader>s"', function() Snacks.picker.registers({focus = "list"}) end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history({focus = "list"}) end, desc = "Search History" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sc", function() Snacks.picker.command_history({focus = "list"}) end, desc = "Command History" },
      { "<leader>qa", function() Snacks.picker.diagnostics({focus = "list"}) end, desc = "Diagnostics"},
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps({focus = "list"}) end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps({focus = "list"}) end, desc = "Keymaps" },
      { "<leader>su", function() Snacks.picker.undo({focus = "list"}) end, desc = "Undo History" },
      { "<leader>c", function() Snacks.picker.colorschemes({focus = "list"}) end, desc = "Colorschemes" },
    },
  },
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure({
          providers = {
            -- 'lsp',
            'treesitter',
          },
          delay = 200,
          under_cursor = true,
        })
    end
  },
}
