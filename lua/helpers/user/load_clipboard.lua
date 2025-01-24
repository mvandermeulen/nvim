- Load the output of the last command into the register "o"
-- if it was executed with | tee /tmp/output.log
function load_output_to_register()
  local file_path = "/tmp/output.log"
  local file = io.open(file_path, "r")
  if file then
    local content = file:read("*all")
    file:close()
    vim.fn.setreg("o", content)
  else
    print("Failed to open file: " .. file_path)
  end
end

vim.api.nvim_command("command! Output lua load_output_to_register()")
