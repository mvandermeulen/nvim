-- Using a Lua function in a key mapping in 0.7
vim.api.nvim_set_keymap("n", "<leader>H", "", {
    noremap = true,
    callback = function()
        print("Hello world!")
    end,
})

-- Creating an autocommand in 0.7
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function(args)
        print("Entered buffer " .. args.buf .. "!")
    end,
    desc = "Tell me when I enter a buffer",
})

-- Creating a custom user command in 0.7
vim.api.nvim_create_user_command("SayHello", function(args)
    print("Hello " .. args.args)
end, {
    nargs = "*",
    desc = "Say hi to someone",
})


