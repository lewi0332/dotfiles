return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  -- Obsidian workflow keymaps
  keys = {
    -- Navigate to vault
    { "<leader>oo", "<cmd>cd ~/Documents/Obsidian\\ Vault<cr>", desc = "[O]bsidian: Navigate to vault" },
    
    -- Convert note to template and remove leading whitespace
    { "<leader>on", "<cmd>ObsidianTemplate note<cr> <cmd>lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>", desc = "[O]bsidian: Apply [N]ote template" },
    
    -- Strip date from note title and replace dashes with spaces (cursor must be on title)
    { "<leader>of", "<cmd>s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>", desc = "[O]bsidian: [F]ormat title" },
    
    -- Search for files in vault
    { "<leader>os", function()
        require('telescope.builtin').find_files({ search_dirs = {"~/Documents/Obsidian Vault/notes"} })
      end, desc = "[O]bsidian: [S]earch files" },
    
    -- Live grep in vault
    { "<leader>oz", function()
        require('telescope.builtin').live_grep({ search_dirs = {"~/Documents/Obsidian Vault/notes"} })
      end, desc = "[O]bsidian: Grep (fuzzy [Z])" },
    
    -- Move file to zettelkasten folder (for review workflow)
    { "<leader>ok", "<cmd>!mv '%:p' ~/Documents/Obsidian\\ Vault/zettelkasten<cr><cmd>bd<cr>", desc = "[O]bsidian: Move to zettlel[K]asten" },
    
    -- Delete current file
    { "<leader>odd", "<cmd>!rm '%:p'<cr><cmd>bd<cr>", desc = "[O]bsidian: [D]elete file" },
  },

  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    workspaces = {
      {
        name = "work",
        path = "~/Documents/Obsidian Vault/",
      }
    },

    -- New notes go in the inbox subdirectory (matches the 'on' script behavior)
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",

    disable_frontmatter = true,

    templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M:%S",
    },

    -- Name new notes with ISO date prefix matching the 'on' script format
    -- Creates notes like: YYYY-MM-DD_title.md
    note_id_func = function(title)
      local suffix = ""
      local current_date = os.date("%Y-%m-%d")
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- Generate random suffix if no title provided
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return current_date .. "_" .. suffix
    end,

    -- Key mappings
    mappings = {
      -- Overrides 'gf' to work on markdown/wiki links within your vault
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes with <leader>ti
      ["<leader>ti"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
    },

    -- Completion settings
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    -- UI settings - minimal styling, rely on treesitter for markdown
    ui = {
      checkboxes = {},
      bullets = {},
    },
  },
}