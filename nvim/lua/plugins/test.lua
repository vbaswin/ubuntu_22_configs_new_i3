return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "alfaix/neotest-gtest",
        },
        opts = {
            adapters = {
                ["neotest-gtest"] = {
                    is_test_file = function(file_path)
                        return file_path:match("tests/test_.*%.cpp$") ~= nil
                    end,

                    -- Map test source files to their compiled executables.
                    -- This function receives the test file path and returns
                    -- the path to the binary that gtest should execute.
                    mapped_executables = function(file_path)
                        -- Extract filename without extension:
                        --   "tests/test_cloud_mapper.cpp" → "test_cloud_mapper"
                        local stem = vim.fn.fnamemodify(file_path, ":t:r")
                        -- Return absolute path to the binary in build/
                        return vim.fn.getcwd() .. "/build/" .. stem
                    end,
                },
            },
        },
    },
}
