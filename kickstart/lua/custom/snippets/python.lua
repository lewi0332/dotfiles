local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets('python', {
  s({
    trig = 'build plots',
    name = 'build plots',
    dscr = 'Import plotting libraries',
    wordTrig = false,
  }, {
    t {
      'import pandas as pd',
      'import plotly.graph_objects as go',
      'from plotly_theme import plotly_light',
    },
  }),
  s({
    trig = 'load',
    name = 'load data',
    dscr = 'Load dataframe from Redshift',
    wordTrig = false,
  }, {
    t {
      'from utils.db import load_data',
      '',
      '',
      'df = load_data(',
      '"""',
      'SELECT',
      '    *',
      'FROM analyticsdb.analytics.',
    },
    i(1, { '' }),
    t { '', 'limit 100', '""")', 'df' },
  }),
})
