local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set({ 'n', 'v' }, '<leader>ac', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format { async = true }
  end, opts)
  local open_diagnostic = function()
    for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winid).zindex then
        return
      end
    end
    vim.diagnostic.open_float(0, {
      scope = "cursor",
      focusable = false,
    })
  end
  vim.keymap.set('n', '<leader>qf', open_diagnostic)
  vim.keymap.set('n', '[g', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']g', vim.diagnostic.goto_next)
  -- Diagnostics on hover
  local diag_timer = nil
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      if diag_timer then
        diag_timer:stop()
        diag_timer = nil
      end

      diag_timer = vim.defer_fn(function()
        local cur = vim.api.nvim_win_get_cursor(0)
        local line_diags = vim.diagnostic.get(0, { lnum = cur[1] - 1 })
        if #line_diags > 0 then
          vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor", border = "rounded" })
        end
      end, 250) -- show after 250ms idle on same line
    end,
  })
end

local on_attach_java = function(_, bufnr)
  on_attach(_, bufnr)
  -- Debugger integration
  local jdtls = require("jdtls")
  jdtls.setup_dap({ hotcodereplace = 'auto' })
  jdtls.setup.add_commands()
  require("jdtls.dap").setup_dap_main_class_configs()
  vim.keymap.set('n', '<leader>dt', jdtls.test_class, { buffer = bufnr })
  vim.keymap.set('n', '<leader>dm', jdtls.test_nearest_method, { buffer = bufnr })
end

return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "clangd",
          "pyright",
          "jdtls",
          "vtsls",
          "rome",
        },
        automatic_enable = {
          exclude = {
            "jdtls",
          }
        },
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      -- Setup default capabilities for nvim-cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
      })
      vim.lsp.config("clangd", {
        on_attach = on_attach,
        capabilities = capabilities,
      })
      vim.lsp.config("pyright", {
        on_attach = on_attach,
        capabilities = capabilities,
      })
      vim.lsp.config("vtsls", {
        on_attach = on_attach,
        capabilities = capabilities,
      })
      vim.lsp.config("rome", {
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local jdtls = require("jdtls")
      local root_dir = jdtls.setup.find_root({ "gradlew", "mvnw", ".git" })
      local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
      local workspace_dir = vim.fn.stdpath("data") .. "/eclipse/" .. project_name

      -- Get Mason install path for jdtls
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local config_linux = mason_path .. "/config_linux"
      local launcher_path = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      local lombok_path = mason_path .. "/lombok.jar"

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local bundles = {
        vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server/*.jar", 1),
      }
      vim.list_extend(
        bundles,
        vim.split(vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar", 1), "\n")
      )

      local config = {
        cmd = {
          "java",
          "-javaagent:" .. lombok_path,
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", launcher_path,
          "-configuration", config_linux,
          "-data", workspace_dir,
        },
        init_options = {
          bundles = bundles,
        },
        root_dir = root_dir,
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = { favoriteStaticMembers = { "org.junit.jupiter.api.Assertions.*" } },
            eclipse = { downloadSources = true, },
            configuration = { updateBuildConfiguration = "automatic", },
            maven = { downloadSources = true, },
            implementationsCodeLens = { enabled = true, },
            referencesCodeLens = { enabled = true, },
            references = { includeDecompiledSources = true, },
            format = { enabled = true, },
          },
        },
        on_attach = on_attach_java,
        capabilities = capabilities,
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'java' },
        callback = function()
          jdtls.start_or_attach(config)
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("nvim-dap-virtual-text").setup()
      dapui.setup()

      -- Auto open/close the UI
      local orig_terminate = dap.terminate
      dap.terminate = function(...)
        dapui.close()
        orig_terminate(...)
      end
      dap.listeners.after.event_initialized["dapui_config"] = function()
        local tree = require("nvim-tree.api")
        if tree ~= nil then
          tree.tree.close()
        end
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Example keymaps
      vim.keymap.set("n", "<leader>dc", dap.continue)
      vim.keymap.set("n", "<leader>dn", dap.step_over)
      vim.keymap.set("n", "<leader>di", dap.step_into)
      vim.keymap.set("n", "<leader>do", dap.step_out)
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end)
      vim.keymap.set("n", "<leader>de", dapui.eval)
      vim.keymap.set("n", "<leader>dx", dap.terminate)
    end,
  },
}
