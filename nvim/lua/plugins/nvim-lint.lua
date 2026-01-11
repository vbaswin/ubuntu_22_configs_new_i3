return {
    "mfussenegger/nvim-lint",
    opts = {
        linters = {
            cmakelint = {
                -- Pass the argument to suppress rule C0301 (Tabs)
                args = { "--suppress=C0301,C0306" },
            },
        },
    },
}
