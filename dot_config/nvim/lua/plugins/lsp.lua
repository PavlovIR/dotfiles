return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
        config = function()
            local servers = {
                lua_ls = {},
                tinymist = {
                    cmd = { "tinymist" },
                    filetypes = { "typst" },
                    settings = {},
                },
                pyrigth = {},
            }

            for name, opts in pairs(servers) do
                vim.lsp.config[name] = opts
                vim.lsp.enable(name)
            end
        end,
    }
}
