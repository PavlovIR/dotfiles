return {
    {  
        'https://github.com/pittcat/codex.nvim',
        config = function()
            require('codex').setup()

            -- Example mappings
            vim.keymap.set('n', '<leader>co', function() require('codex').open() end, { desc = 'Codex: Open TUI' })
            vim.keymap.set('n', '<leader>ct', function() require('codex').toggle() end, { desc = 'Codex: Toggle terminal' })
            -- Terminal bridge shortcuts
vim.keymap.set('n', '<leader>cp', ':CodexSendPath<CR>', { desc = 'Codex: Send file path' })
vim.keymap.set('v', '<leader>cs', ":'<,'>CodexSendSelection<CR>", { desc = 'Codex: Send selection' })
vim.keymap.set('v', '<leader>cr', ":'<,'>CodexSendReference<CR>", { desc = 'Codex: Send reference' })
        end
    }
}
