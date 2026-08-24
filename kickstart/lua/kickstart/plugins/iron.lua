return {
  {
    'Vigemus/iron.nvim',
    config = function()
      local view = require 'iron.view'
      local repl_open_cmds = {
        view.split.vertical.rightbelow(),
        view.split.rightbelow(),
      }

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
              command = function(meta)
                local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(meta.current_bufnr), ':p:h')
                if dir == '' then
                  dir = vim.fn.getcwd()
                end
                local venv = vim.env.VIRTUAL_ENV
                local candidates = {}

                if venv and venv ~= '' then
                  table.insert(candidates, venv .. '/bin/ipython')
                  table.insert(candidates, venv .. '/bin/python3')
                  table.insert(candidates, venv .. '/bin/python')
                end

                vim.list_extend(candidates, { 'ipython', 'python3', 'python' })

                local repl = nil
                for _, candidate in ipairs(candidates) do
                  if vim.fn.executable(candidate) == 1 then
                    repl = candidate
                    break
                  end
                end

                repl = repl or 'python3'

                local prefix = ''
                if repl:match 'python' and not repl:match 'ipython' then
                  -- Python 3.13+ may require this for terminal REPL behavior.
                  prefix = 'PYTHON_BASIC_REPL=1 '
                end

                return { 'sh', '-c', 'cd ' .. vim.fn.shellescape(dir) .. ' && ' .. prefix .. vim.fn.shellescape(repl) }
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
          repl_open_cmd = repl_open_cmds,
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
          -- exit = '<space>sq', -- overridden below to send exit() instead of Ctrl-D
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

      -- Send the current visual selection to `dbtvp` (dbt show --inline | visidata,
      -- opened in a tmux popup). Lets you preview a snippet of dbt model SQL --
      -- refs and all -- without leaving the buffer or hand-resolving ref() calls.
      local function find_dbt_project_root(start_dir)
        local match = vim.fs.find('dbt_project.yml', { path = start_dir, upward = true })[1]
        return match and vim.fs.dirname(match) or nil
      end

      -- NOTE: this must be a `:<C-u>` cmdline-style mapping, not a Lua function
      -- passed directly to vim.keymap.set. When a Visual-mode keymap's rhs is a
      -- Lua function (or a <Cmd> mapping), Neovim doesn't commit the '< / '>
      -- marks before invoking it, so vim.fn.line("'<"/"'>") reads either unset
      -- (0,0) or the *previous* selection. Routing through `:` forces Neovim to
      -- exit Visual mode and set the marks first, same as classic Vimscript
      -- plugins that grab a visual range.
      _G.__dbtvp_preview = function()
        local start_line = vim.fn.line "'<"
        local end_line = vim.fn.line "'>"
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

        if #lines == 0 then
          print 'No selection'
          return
        end

        local sql = table.concat(lines, '\n')
        local bufdir = vim.fn.expand '%:p:h'
        local root = find_dbt_project_root(bufdir) or vim.fn.getcwd()

        vim.fn.jobstart({ 'zsh', '-c', 'source ~/.aliases && dbtvp "$1"', '_', sql }, {
          cwd = root,
          detach = true,
          on_exit = function(_, code)
            if code ~= 0 then
              vim.schedule(function()
                print('dbtvp exited with code ' .. code)
              end)
            end
          end,
        })
      end

      vim.keymap.set('v', '<space>dv', ':<C-u>lua __dbtvp_preview()<CR>', { desc = 'Preview visual selection with dbtvp (visidata popup)' })

      -- `gd` on a `ref('model_name')` or `source('src', 'table')` call jumps
      -- to that model's .sql file or the source's entry in its yml schema
      -- file, the same way `gd`/LSP goto-definition jumps to a Python
      -- function. Falls back to the built-in `gd` everywhere else (e.g. no
      -- ref()/source() under the cursor, or a non-dbt sql file).
      local function dbt_ref_under_cursor(line, col)
        local search_start = 1
        while true do
          local s, e, name = line:find("ref%(%s*['\"]([%w_]+)['\"]%s*%)", search_start)
          if not s then
            return nil
          end
          if col >= s and col <= e then
            return name
          end
          search_start = e + 1
        end
      end

      local function dbt_source_under_cursor(line, col)
        local search_start = 1
        while true do
          local s, e, src_name, table_name = line:find("source%(%s*['\"]([%w_]+)['\"]%s*,%s*['\"]([%w_]+)['\"]%s*%)", search_start)
          if not s then
            return nil
          end
          if col >= s and col <= e then
            return src_name, table_name
          end
          search_start = e + 1
        end
      end

      -- Scans a sources.yml-style file for `sources: -> name: <src_name> ->
      -- tables: -> name: <table_name>` and returns the line number of the
      -- matching table entry (or of the source entry, if the table itself
      -- isn't found). Deliberately a lightweight indentation scan rather
      -- than a full YAML parse -- dbt source files are consistently shaped.
      local function scan_source_file(path, src_name, table_name)
        local lines = vim.fn.readfile(path)
        local in_sources = false
        local source_item_indent = nil
        local current_source_matches = false
        local source_line = nil

        for i, line in ipairs(lines) do
          local top_indent, top_key = line:match '^(%s*)(%a[%w_]*):%s*$'
          if top_indent and #top_indent == 0 then
            in_sources = top_key == 'sources'
          end

          if in_sources then
            local indent, name = line:match "^(%s*)%-%s*name:%s*['\"]?([%w_%.%-]+)"
            if indent and name then
              if source_item_indent == nil then
                source_item_indent = #indent
              end
              if #indent == source_item_indent then
                current_source_matches = name == src_name
                if current_source_matches then
                  source_line = i
                end
              elseif current_source_matches and name == table_name then
                return i
              end
            end
          end
        end

        return current_source_matches and source_line or nil
      end

      local function find_dbt_source_locations(root, src_name, table_name)
        local files = {}
        vim.list_extend(files, vim.fn.globpath(root .. '/models', '**/*.yml', true, true))
        vim.list_extend(files, vim.fn.globpath(root .. '/models', '**/*.yaml', true, true))

        local locations = {}
        for _, file in ipairs(files) do
          local line = scan_source_file(file, src_name, table_name)
          if line then
            table.insert(locations, { file = file, line = line })
          end
        end
        return locations
      end

      local function open_location(loc)
        vim.cmd('edit ' .. vim.fn.fnameescape(loc.file))
        vim.api.nvim_win_set_cursor(0, { loc.line, 0 })
      end

      _G.__dbt_goto_ref = function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.fn.col '.'

        local bufdir = vim.fn.expand '%:p:h'
        local root = find_dbt_project_root(bufdir) or vim.fn.getcwd()

        local src_name, table_name = dbt_source_under_cursor(line, col)
        if src_name then
          local locations = find_dbt_source_locations(root, src_name, table_name)

          if #locations == 0 then
            print(("No dbt source found for '%s.%s'"):format(src_name, table_name))
          elseif #locations == 1 then
            open_location(locations[1])
          else
            local items = {}
            for _, loc in ipairs(locations) do
              table.insert(items, ('%s:%d'):format(loc.file, loc.line))
            end
            vim.ui.select(items, { prompt = ('Multiple sources named %s.%s:'):format(src_name, table_name) }, function(_, idx)
              if idx then
                open_location(locations[idx])
              end
            end)
          end
          return
        end

        local model_name = dbt_ref_under_cursor(line, col)

        if not model_name then
          vim.cmd 'normal! gd'
          return
        end

        local models_dir = root .. '/models'

        local matches = vim.fs.find(model_name .. '.sql', { path = models_dir, type = 'file', limit = 100 })

        if #matches == 0 then
          print("No dbt model found for '" .. model_name .. "'")
        elseif #matches == 1 then
          vim.cmd('edit ' .. vim.fn.fnameescape(matches[1]))
        else
          vim.ui.select(matches, { prompt = 'Multiple models named ' .. model_name .. ':' }, function(choice)
            if choice then
              vim.cmd('edit ' .. vim.fn.fnameescape(choice))
            end
          end)
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'sql',
        callback = function(event)
          vim.keymap.set('n', 'gd', __dbt_goto_ref, { buffer = event.buf, desc = 'Goto dbt ref() model (fallback: gd)' })
        end,
      })

      -- Custom keymap to focus REPL window
      vim.keymap.set('n', '<space>sq', function()
        require('iron.core').send(nil, { 'exit()' })
      end, { desc = 'Exit REPL' })

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
