local Source = {}

local function get_session()
	return require("dap").session()
end

local function get_prompt_offset(line)
	local prompt = "dap> "
	if vim.startswith(line, prompt) then
		return #prompt
	end
	return 0
end

local function get_word_prefix(text)
	return text:match("[A-Za-z0-9_%.%-]*$") or ""
end

local function command_items(line_to_cursor, range)
	local repl = require("dap.repl")
	local items = {}
	local prefix = get_word_prefix(line_to_cursor)
	if prefix == "" or prefix:sub(1, 1) ~= "." then
		return items
	end
	for _, values in pairs(repl.commands or {}) do
		if type(values) == "table" then
			for _, cmd in ipairs(values) do
				table.insert(items, {
					label = cmd,
					textEdit = {
						range = range,
						newText = cmd,
					},
				})
			end
		end
	end
	for cmd, _ in pairs((repl.commands or {}).custom_commands or {}) do
		table.insert(items, {
			label = cmd,
			textEdit = {
				range = range,
				newText = cmd,
			},
		})
	end
	return items
end

function Source.new()
	return setmetatable({}, { __index = Source })
end

function Source:enabled()
	return vim.bo.filetype == "dap-repl" and vim.api.nvim_get_mode().mode == "i"
end

function Source:get_trigger_characters()
	local session = get_session()
	local chars = ((session or {}).capabilities or {}).completionTriggerCharacters
	if type(chars) == "table" and #chars > 0 then
		return chars
	end
	return { "." }
end

function Source:get_completions(context, callback)
	local session = get_session()
	local line = context.line
	local col = context.cursor[2]
	local offset = get_prompt_offset(line)
	local line_to_cursor = line:sub(offset + 1, col)
	local prefix = get_word_prefix(line_to_cursor)
	local start_col = col - #prefix
	local range = {
		start = { line = context.cursor[1] - 1, character = start_col },
		["end"] = { line = context.cursor[1] - 1, character = col },
	}

	local cmd_items = command_items(line_to_cursor, range)
	callback({
		items = cmd_items,
		is_incomplete_forward = false,
		is_incomplete_backward = false,
	})

	if not session then
		return nil
	end
	if not ((session.capabilities or {}).supportsCompletionsRequest) then
		return nil
	end

	local args = {
		frameId = (session.current_frame or {}).id,
		text = line_to_cursor,
		column = col + 1 - offset,
	}

	local function on_response(err, response)
		if err or not response or not response.targets then
			return
		end
		local items = {}
		local columns_start_at_1 = (session.capabilities or {}).columnsStartAt1
		for _, candidate in ipairs(response.targets) do
			local insert_text = candidate.text or candidate.label
			local start = candidate.start
			local length = candidate.length or 0
			if columns_start_at_1 and type(start) == "number" then
				start = math.max(start - 1, 0)
			end
			if type(start) ~= "number" then
				start = #line_to_cursor - #prefix
			end
			local start_col_item = offset + start
			local end_col_item = start_col_item + length
			table.insert(items, {
				label = candidate.label or insert_text,
				textEdit = {
					range = {
						start = { line = context.cursor[1] - 1, character = start_col_item },
						["end"] = { line = context.cursor[1] - 1, character = end_col_item },
					},
					newText = insert_text,
				},
			})
		end
		callback({
			items = items,
			is_incomplete_forward = false,
			is_incomplete_backward = false,
		})
	end

	session:request("completions", args, on_response)
	return nil
end

return Source
