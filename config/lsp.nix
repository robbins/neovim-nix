{
  plugins.lspconfig.enable = true;
  lsp = {
    codelens.enable = true;
    inlayHints.enable = true;
  };
  # LLM slop to only show inlay hints on current line
  extraConfigLua = ''
  local line_inlay_ns = vim.api.nvim_create_namespace("current_line_inlay_hints")
  local inlay_group = vim.api.nvim_create_augroup("CurrentLineInlayHints", { clear = true })
  
  local last_buf = -1
  local last_req_start, last_req_end = -1, -1
  
  local timer = (vim.uv or vim.loop).new_timer()
  local DEBOUNCE_MS = 250
  
  local function clear_custom_hints(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, line_inlay_ns, 0, -1)
    end
  end
  
  --- Determines the full range (start & end lines) of the statement on the current line.
  local function get_target_statement_range(bufnr, cursor_line)
    local start_line, end_line = cursor_line, cursor_line
  
    -- Crucial Fix: Get the first non-whitespace column on the current line.
    -- This prevents Treesitter from returning the parent block if the cursor is on leading indentation.
    local line_text = vim.api.nvim_buf_get_lines(bufnr, cursor_line, cursor_line + 1, false)[1]
    if not line_text then return start_line, end_line end
    
    local first_non_ws_col = line_text:find("[^%s]")
    if not first_non_ws_col then return start_line, end_line end
    first_non_ws_col = first_non_ws_col - 1 -- API is 0-indexed
  
    -- Grab the node exactly at the start of the code, ignoring cursor column
    local ok, node = pcall(vim.treesitter.get_node, { 
      bufnr = bufnr, 
      pos = { cursor_line, first_non_ws_col } 
    })
    
    if not ok or not node then
      return start_line, end_line
    end
  
    local current = node
    while current do
      local ntype = current:type()
  
      -- Stop expanding when we hit a structural scope boundary
      if ntype == "translation_unit" or ntype == "compound_statement" or ntype == "statement_block" or ntype:match("block$") or ntype:match("body$") then
        break
      end
  
      local sr, _, er, ec = current:range()
      
      -- Treesitter end_row is exclusive if end_col is 0 (meaning it wraps perfectly to the next line). Adjust it.
      if ec == 0 and er > sr then
        er = er - 1
      end
  
      -- Expand our bounding box to encompass the node
      if sr < start_line then start_line = sr end
      if er > end_line then end_line = er end
  
      current = current:parent()
    end
  
    -- Failsafe constraint: cap the expansion to avoid fetching massive files if the AST is weird
    if start_line < cursor_line - 15 then start_line = cursor_line - 15 end
    if end_line > cursor_line + 15 then end_line = cursor_line + 15 end
  
    return start_line, end_line
  end
  
  local function fetch_line_hints(win, bufnr, start_line, end_line)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/inlayHint" })
    if #clients == 0 then return end
  
    local params = {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
      range = {
        start = { line = start_line, character = 0 },
        ["end"] = { line = end_line + 1, character = 0 },
      },
    }
  
    for _, client in ipairs(clients) do
      client:request("textDocument/inlayHint", params, function(err, result, ctx)
        if err or not result or #result == 0 or ctx.bufnr ~= vim.api.nvim_get_current_buf() then
          return
        end
  
        -- Abort if user entered insert mode during network latency
        if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
          return
        end
  
        -- Verify cursor is still within the expanded statement block
        local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
        if current_line < start_line or current_line > end_line then
          return
        end
  
        clear_custom_hints(bufnr)
  
        for _, hint in ipairs(result) do
          local line = hint.position.line
          local col = hint.position.character
  
          -- Strict Guard: Only render hints strictly inside the statement
          if line >= start_line and line <= end_line then
            local text = ""
            if type(hint.label) == "string" then
              text = hint.label
            elseif type(hint.label) == "table" then
              for _, part in ipairs(hint.label) do
                text = text .. part.value
              end
            end
  
            if hint.paddingLeft then text = " " .. text end
            if hint.paddingRight then text = text .. " " end
  
            vim.api.nvim_buf_set_extmark(bufnr, line_inlay_ns, line, col, {
              virt_text = { { text, "LspInlayHint" } },
              virt_text_pos = "inline",
            })
          end
        end
      end, bufnr)
    end
  end
  
  local function update_line_hints()
    local mode = vim.api.nvim_get_mode().mode
    if mode:sub(1, 1) == "i" or mode:sub(1, 1) == "R" then
      return
    end
  
    local win = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(win)
  
    -- Force disable native global hints in normal mode
    if vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end
  
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1] - 1
    local start_line, end_line = get_target_statement_range(bufnr, cursor_line)
  
    -- Optimization: Moving vertically within the exact same multi-line statement skips network requests completely
    if bufnr == last_buf and start_line == last_req_start and end_line == last_req_end then
      return
    end
    
    last_buf = bufnr
    last_req_start = start_line
    last_req_end = end_line
  
    -- Clear previous hints instantly on statement-to-statement vertical move
    clear_custom_hints(bufnr)
  
    timer:stop()
    timer:start(
      DEBOUNCE_MS,
      0,
      vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(bufnr) then
          fetch_line_hints(win, bufnr, start_line, end_line)
        end
      end)
    )
  end
  
  vim.api.nvim_create_autocmd("LspAttach", {
    group = inlay_group,
    callback = function(args)
      vim.schedule(function()
        if vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }) then
          vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
        end
      end)
    end,
  })
  
  vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, {
    group = inlay_group,
    callback = update_line_hints,
  })
  
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = inlay_group,
    callback = function(args)
      timer:stop()
      clear_custom_hints(args.buf)
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end,
  })
  
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = inlay_group,
    callback = function(args)
      vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
      last_req_start, last_req_end, last_buf = -1, -1, -1
      update_line_hints()
    end,
  })
  
  vim.api.nvim_create_autocmd("BufLeave", {
    group = inlay_group,
    callback = function()
      timer:stop()
      last_req_start, last_req_end, last_buf = -1, -1, -1
    end,
  })
  '';
}
