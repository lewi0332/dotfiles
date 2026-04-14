return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        -- markdown = { 'markdownlint' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

      local lint_enabled = true
      local lint_autocmd_id = nil

      local function create_lint_autocmd()
        return vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
          group = lint_augroup,
          callback = function()
            if vim.bo.modifiable then
              lint.try_lint()
            end
          end,
        })
      end

      lint_autocmd_id = create_lint_autocmd()

      vim.g.toggle_lint = function()
        if lint_enabled then
          vim.api.nvim_del_autocmd(lint_autocmd_id)
          lint_enabled = false
          vim.diagnostic.enable(false)
          vim.notify 'Linting disabled'
        else
          lint_autocmd_id = create_lint_autocmd()
          lint_enabled = true
          vim.diagnostic.enable(true)
          lint.try_lint()
          vim.notify 'Linting enabled'
        end
      end

      vim.keymap.set('n', '<leader>td', function()
        vim.g.toggle_lint()
      end, { desc = '[T]oggle [D]iagnostics' })
    end,
  },
}
