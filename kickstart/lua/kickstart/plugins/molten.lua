return {
  'benlubas/molten-nvim',
  config = function()
    vim.keymap.set('n', '<leader>mi', ':MoltenInit ', { desc = 'Init molten kernel' })
    vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', { desc = 'Evaluate operator' })
    vim.keymap.set('v', '<localleader>e', ':MoltenEvaluateVisual<CR>', { desc = 'Evaluate visual' })
    vim.keymap.set('n', '<localleader>o', ':noautocmd MoltenEnterOutput<CR>', { desc = 'Open output' })
  end,
}
