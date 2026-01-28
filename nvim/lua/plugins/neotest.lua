return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "alfaix/neotest-gtest",
        },
        opts = function(_, opts)
            opts.adapters = opts.adapters or {}

            local gtest = require("neotest-gtest")

            table.insert(
                opts.adapters,
                gtest.setup({
                    is_test_file = function(file_path)
                        return string.match(file_path, "tests/.*%.cpp") or string.match(file_path, ".*_test%.cpp")
                    end,
                    filter_dir = function(name, rel_path, root)
                        return name ~= "build" and name ~= ".git"
                    end,
                })
            )
        end,
    },
}
