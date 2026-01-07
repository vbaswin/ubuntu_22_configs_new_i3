return {
    "nvim-mini/mini.surround",
    opts = {
        -- make surrounds insert exactly the characters (no padding)
        custom_surroundings = {
            ["("] = { output = { left = "(", right = ")" } },
            [")"] = { output = { left = "(", right = ")" } },

            ["["] = { output = { left = "[", right = "]" } },
            ["]"] = { output = { left = "[", right = "]" } },

            ["{"] = { output = { left = "{", right = "}" } },
            ["}"] = { output = { left = "{", right = "}" } },

            ['"'] = { output = { left = '"', right = '"' } },
            ["'"] = { output = { left = "'", right = "'" } },
            ["`"] = { output = { left = "`", right = "`" } },
            ["<"] = { output = { left = "<", right = ">" } },
        },
    },
}
