local function keychain_get(service)
	local cmd = {
		"security",
		"find-generic-password",
		"-s",
		service,
		"-w",
	}

	local out = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		return nil
	end

	-- strip trailing newline
	return (out:gsub("%s+$", ""))
end

local gemini_key = keychain_get("gemini-api-key")
if gemini_key then
	vim.env.GEMINI_API_KEY = gemini_key
end
