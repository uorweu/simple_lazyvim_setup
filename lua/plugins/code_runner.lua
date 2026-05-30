local M = {}

-- Hàm tìm các file nguồn trong thư mục hiện tại
local function find_source_files(extension)
  local files = vim.fn.glob("*." .. extension, false, true)
  return table.concat(files, " ")
end

-- Hàm chạy code
function M.run_code()
  -- Tự động lưu file trước khi chạy
  vim.cmd("write")

  local filetype = vim.bo.filetype
  local filepath = vim.fn.expand("%:p") -- Đường dẫn đầy đủ tới file
  local filename = vim.fn.expand("%:t:r") -- Tên file (không bao gồm phần mở rộng)
  local cmd = ""

  if filetype == "c" then
    -- Biên dịch file C
    cmd = string.format("gcc %s -o %s -lm && ./%s", filepath, filename, filename)
  elseif filetype == "cpp" then
    -- Biên dịch file C++
    cmd = string.format("g++ %s -o %s -std=c++17 -lm && ./%s", filepath, filename, filename)
  elseif filetype == "python" then
    -- Chạy file Python
    cmd = string.format("python3 %s", filepath)
  elseif filetype == "java" then
    -- Biên dịch và chạy file Java
    cmd = string.format("javac %s && java %s", filepath, filename)
  elseif filetype == "lua" then
    cmd = string.format("lua %s", filepath)
    ----
  elseif filetype == "matlab" or string.match(filepath, "%.m$") then
    -- Chạy file MATLAB
    cmd = string.format("matlab -nosplash -nodesktop -r \"run('%s')\"", filepath)
    ----
  else
    print("Unsupported file type!")
    return
  end

  -- Thực thi lệnh trong terminal
  local term = require("toggleterm.terminal").Terminal:new({
    cmd = cmd,
    dir = vim.fn.getcwd(), -- Đường dẫn thư mục hiện tại
    close_on_exit = false, -- Không tự đóng terminal sau khi chạy
  })

  term:toggle()
end

-- Thêm key mappings để di chuyển trong terminal
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
end

-- Danh sách plugin
return {
  -- Plugin: ToggleTerm để chạy code
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = 15,
        hide_numbers = false,
        open_mapping = [[<c-\>]],
        -- direction = "float",
        --float_opts = {
        -- border = "curved",
        --},
      })
      -- Tạo lệnh :makefile để chạy code
      vim.api.nvim_create_user_command(
        "M", -- Tên lệnh
        function()
          -- Gọi hàm `run_code` khi gọi lệnh `:M`
          M.run_code()
        end,
        {} -- Các tham số bổ sung (có thể để trống)
      )

      -- Định nghĩa hàm `run_code` toàn cục
      _G.run_code = M.run_code

      -- Gọi hàm để thiết lập keymaps cho terminal
      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

      -- Keymap để chạy code
      --vim.api.nvim_set_keymap("n", "<leader>r", ":lua _G.run_code()<CR>", { noremap = true, silent = true })
    end,
  },
}
