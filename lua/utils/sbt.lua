local M = {}

-- Track the persistent sbt terminal
M.bufnr = nil
M.chan = nil

--- Find the project root by searching for build.sbt in ancestor directories.
--- @return string|nil
local function find_root()
  local dir = vim.fn.expand("%:p:h") -- directory of current file
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  while dir and dir ~= "/" do
    if vim.fn.filereadable(dir .. "/build.sbt") == 1 then
      return dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return vim.fn.getcwd()
end

--- Find or create a persistent sbt terminal in a bottom split.
--- Sets up terminal-local keymaps for easy navigation.
--- @return number bufnr, number channel
function M.ensure()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    return M.bufnr, M.chan
  end

  local root = find_root()

  -- Create a bottom split with a terminal running sbt in the project root
  vim.cmd("botright 12 split | terminal")
  local bufnr = vim.api.nvim_get_current_buf()
  local chan = vim.bo[bufnr].channel

  -- Send cd + sbt so sbt runs in the correct directory
  vim.fn.chansend(chan, 'cd "' .. root .. '" && sbt\n')

  -- Setup terminal-local keymaps
  local function setup()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    local opts = { buffer = bufnr, silent = true, nowait = true }

    -- <Esc> exits terminal mode
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
    -- Ctrl+hjkl for window navigation (even from terminal mode)
    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)
  end

  vim.schedule(setup)

  -- Cleanup tracking when the buffer is wiped
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = bufnr,
    once = true,
    callback = function()
      M.bufnr = nil
      M.chan = nil
    end,
  })

  M.bufnr = bufnr
  M.chan = chan

  return bufnr, chan
end

--- Send a command to the persistent sbt session.
--- Creates the terminal if it doesn't exist yet. Input is buffered by the
--- pty, so it works even if sbt is still starting up.
--- @param cmd string The sbt command to run (e.g. 'testOnly mlse.MySpec')
function M.send(cmd)
  local _, chan = M.ensure()

  -- Briefly focus the terminal so the user sees the output
  local win = vim.fn.bufwinid(M.bufnr)
  local prev_win = vim.api.nvim_get_current_win()

  if win ~= -1 and win ~= prev_win then
    vim.api.nvim_set_current_win(win)
    vim.cmd("startinsert")
  end

  vim.fn.chansend(chan, cmd .. "\n")
end

return M
