return {
    "sylvanfranklin/omni-preview.nvim",
    dependencies = {
        -- Typst live preview support
        { 'chomosuke/typst-preview.nvim', lazy = true },
        -- Markdown preview (runs a one-time deno build)
	{ "toppair/peek.nvim", lazy = true, build = "deno task --quiet build:fast" },
    },
    opts = {},
}
