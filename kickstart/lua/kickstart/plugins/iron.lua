return {
  {
    'Vigemus/iron.nvim',
    config = function()
      local view = require 'iron.view'
      require('iron.core').setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            -- python = {
            --   command = 'ipython',
            --   format = require('iron.fts.common').bracketed_paste,
            --   block_dividers = { '# %%', '#%%' },
            -- },
            python = {
              command = function()
                local venv = vim.env.VIRTUAL_ENV
                if venv and venv ~= '' then
                  return { venv .. '/bin/ipython' }
                end
                return { 'ipython' }
              end,
              format = require('iron.fts.common').bracketed_paste,
              block_dividers = { '# %%', '#%%' },
            },
            rust = {
              command = { 'evcxr' },
            },
            r = {
              command = { 'R' },
              block_divides = { '# %%', '#%%' },
            },
            octave = {
              command = { 'octave ' },
            },
          },
          repl_open_cmd = {
            view.split.vertical.rightbelow(),
            view.split.rightbelow(),
          },
        },
        keymaps = {
          send_motion = '<space>sc',
          visual_send = '<space>sc',
          send_line = '<space>sl',
          send_file = '<space>sf',
          toggle_repl = '<space>rr',
          toggle_repl_with_cmd_1 = '<space>rh',
          toggle_repl_with_cmd_2 = '<space>rv',
          interrupt = '<space>s<space>',
          exit = '<space>sq',
          clear = '<space>cl',
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }

      -- VisiData popup keybinding with picker (uses %vd magic)
      vim.keymap.set('n', '<space>tv', function()
        local tmpfile = vim.fn.stdpath('data') .. '/visidata_dfs.txt'

        local function open_visidata(df_name)
          pcall(require('iron').core.send, nil, '%vd ' .. df_name)
        end

        local python_code = string.format([[
import pandas as pd
_dfs = [k for k, v in get_ipython().user_ns.items() if isinstance(v, pd.DataFrame) and not k.startswith('_')]
with open('%s', 'w') as f:
    f.write(','.join(sorted(_dfs)))
print("DataFrames: " + ', '.join(sorted(_dfs)))
]], tmpfile)

        pcall(require('iron').core.send, nil, python_code)

        vim.defer_fn(function()
          local handle = io.open(tmpfile, 'r')
          if handle then
            local content = handle:read('*a')
            handle:close()
            os.remove(tmpfile)

            if content and content ~= "" then
              local dfs = {}
              for df in content:gmatch("[^,]+") do
                table.insert(dfs, df)
              end

              if #dfs == 1 then
                open_visidata(dfs[1])
              else
                vim.ui.select(dfs, { prompt = 'Select DataFrame:' }, function(choice)
                  if choice then
                    open_visidata(choice)
                  end
                end)
              end
            else
              print('No DataFrames found in namespace')
            end
          else
            print('Could not read DataFrame list')
          end
        end, 500)
      end, { desc = 'Open DataFrame in visidata' })

      -- Custom keymap to focus REPL window
      vim.keymap.set('n', '<space>rf', function()
        -- Find the terminal window (REPL)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
          if buftype == 'terminal' then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
        print 'No REPL window found'
      end, { desc = 'Focus REPL window' })

      -- Set up commands in config block if you want to keep it all together
      vim.api.nvim_create_user_command('IronRunCurrent', function()
        vim.cmd 'write' -- Save the file first
        local filepath = vim.fn.expand '%:p'
        local cmd = string.format('%%run %s', filepath)
        require('iron.core').send(nil, { cmd })
      end, {})

      vim.api.nvim_create_user_command('IronRunCell', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local cur_line = cursor[1]

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        local start_idx = 1
        for i = cur_line, 1, -1 do
          if lines[i]:match '^%s*# %%' then
            start_idx = i + 1
            break
          end
        end

        local end_idx = #lines
        for i = cur_line + 1, #lines do
          if lines[i]:match '^%s*# %%' then
            end_idx = i - 1
            break
          end
        end

        local cell_lines = {}
        for i = start_idx, end_idx do
          table.insert(cell_lines, lines[i])
        end

        require('iron.core').send(nil, cell_lines)
        -- VisiData popup command
        vim.api.nvim_create_user_command('VisiData', function(opts)
          local var_name = opts.args
          if var_name == '' then
            print 'Usage: :VisiData <variable_name>'
            return
          end

          local python_code = string.format(
            [[
      import pandas as pd
      import tempfile
      import subprocess
      import os
      _vd_df = get_ipython().user_ns.get('%s')
      if _vd_df is None:
        print("Error: '%s' not found in namespace")
      elif not isinstance(_vd_df, pd.DataFrame):
        print("Error: '%s' is not a pandas DataFrame")
      else:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
          _vd_df.to_csv(f.name, index=False)
          temp_file = f.name

        subprocess.run(
          'tmux popup -d "' .. os.getcwd() .. '" -w 80%% -h 70%% -E "env -i HOME=$HOME PATH=$PATH TERM=$TERM visidata \\"' .. temp_file .. '\\""',
          shell=True
        )
        print(f"Opened in visidata popup")
      ]],
            var_name,
            var_name
          )
          require('iron.core').send(nil, { python_code })
        end, { nargs = 1 })
      end, {})
    end,
  },
}
