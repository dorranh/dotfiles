return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticInfo" })

			local ok, mason_registry = pcall(require, "mason-registry")

			local function with_cwd(dir, fn)
				local cwd = vim.fn.getcwd()
				if dir and dir ~= "" then
					vim.fn.chdir(dir)
				end
				local ok_fn, result = pcall(fn)
				vim.fn.chdir(cwd)
				if ok_fn then
					return result
				end
				return nil
			end

			local function get_cargo_root()
				local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
				if cargo_toml == "" then
					return nil
				end
				return vim.fn.fnamemodify(cargo_toml, ":h")
			end

			local function get_crate_name(cargo_toml)
				local lines = vim.fn.readfile(cargo_toml)
				local in_package = false
				for _, line in ipairs(lines) do
					if line:match("^%s*%[package%]%s*$") then
						in_package = true
					elseif line:match("^%s*%[") then
						in_package = false
					elseif in_package then
						local name = line:match('^%s*name%s*=%s*"(.-)"')
						if name then
							return name
						end
					end
				end
				return nil
			end

			local function get_rust_bin_path()
				local root = get_cargo_root()
				if not root then
					return nil
				end
				local crate = get_crate_name(root .. "/Cargo.toml")
				if not crate then
					return nil
				end
				return root .. "/target/debug/" .. crate
			end

			local function get_rust_test_path()
				local root = get_cargo_root()
				if not root then
					return nil
				end
				if vim.fn.executable("cargo") ~= 1 then
					return nil
				end

				local desired_name
				local file = vim.fn.expand("%:p")
				if file:find(root .. "/tests/") then
					desired_name = vim.fn.fnamemodify(file, ":t:r")
				else
					desired_name = get_crate_name(root .. "/Cargo.toml")
				end

				local lines = with_cwd(root, function()
					return vim.fn.systemlist("cargo test --no-run --message-format=json")
				end)
				if type(lines) ~= "table" then
					return nil
				end

				local executables = {}
				local by_name = {}
				for _, line in ipairs(lines) do
					local ok_decode, data = pcall(vim.fn.json_decode, line)
					if ok_decode
						and type(data) == "table"
						and data.reason == "compiler-artifact"
						and data.executable
						and data.profile
						and data.profile.test == true
						and data.target
						and data.target.name
					then
						table.insert(executables, data.executable)
						by_name[data.target.name] = data.executable
					end
				end

				if desired_name and by_name[desired_name] then
					return by_name[desired_name]
				end
				return executables[1]
			end

			local function get_rust_test_name()
				local bufnr = 0
				local row = vim.api.nvim_win_get_cursor(0)[1]
				for i = row, 1, -1 do
					local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1] or ""
					local name = line:match("^%s*fn%s+([%w_]+)%s*%(")
					if name then
						local attr_found = false
						for j = i - 1, math.max(1, i - 6), -1 do
							local attr = vim.api.nvim_buf_get_lines(bufnr, j - 1, j, false)[1] or ""
							if attr:match("^%s*%#%[") then
								if attr:match("test") then
									attr_found = true
									break
								end
							elseif attr:match("^%s*$") then
								break
							end
						end
						if attr_found then
							return name
						end
					end
				end
				return nil
			end

			local function get_python_path()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv then
					return venv .. "/bin/python"
				end
				local cwd = vim.fn.getcwd()
				if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
					return cwd .. "/.venv/bin/python"
				end
				if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
					return cwd .. "/venv/bin/python"
				end
				local py3 = vim.fn.exepath("python3")
				if py3 ~= "" then
					return py3
				end
				local py = vim.fn.exepath("python")
				if py ~= "" then
					return py
				end
				return "python"
			end

			local function get_mason_install_path(name)
				if not ok then
					return nil
				end
				local ok_pkg, pkg = pcall(mason_registry.get_package, name)
				if not ok_pkg or not pkg or type(pkg.get_install_path) ~= "function" then
					return nil
				end
				if type(pkg.is_installed) == "function" and not pkg:is_installed() then
					return nil
				end
				return pkg:get_install_path()
			end

			local function get_debugpy_adapter()
				local path = get_mason_install_path("debugpy")
				if path then
					return path .. "/venv/bin/python"
				end
				return get_python_path()
			end

			dap.adapters.python = function(cb, config)
				if config.request == "attach" then
					local connect = config.connect or config
					cb({
						type = "server",
						host = connect.host or "127.0.0.1",
						port = connect.port,
						options = { source_filetype = "python" },
					})
				else
					cb({
						type = "executable",
						command = get_debugpy_adapter(),
						args = { "-m", "debugpy.adapter" },
						options = { source_filetype = "python" },
					})
				end
			end

			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = get_python_path,
				},
				{
					type = "python",
					request = "attach",
					name = "Attach",
					connect = function()
						local host = vim.fn.input("Host [127.0.0.1]: ")
						host = host ~= "" and host or "127.0.0.1"
						local port = tonumber(vim.fn.input("Port: "))
						return { host = host, port = port }
					end,
				},
			}
			local codelldb_path = "codelldb"
			local codelldb_install = get_mason_install_path("codelldb")
			if codelldb_install then
				local extension_path = codelldb_install .. "/extension/"
				codelldb_path = extension_path .. "adapter/codelldb"
			end

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = codelldb_path,
					args = { "--port", "${port}" },
				},
			}

			dap.configurations.rust = {
				{
					name = "Debug executable",
					type = "codelldb",
					request = "launch",
					program = function()
						local bin = get_rust_bin_path()
						if bin and vim.fn.executable(bin) == 1 then
							return bin
						end
						local root = get_cargo_root()
						with_cwd(root, function()
							if vim.fn.executable("cargo") == 1 then
								vim.fn.system("cargo build")
							end
						end)
						if bin and vim.fn.executable(bin) == 1 then
							return bin
						end
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					name = "Debug executable (args)",
					type = "codelldb",
					request = "launch",
					program = function()
						local bin = get_rust_bin_path()
						if bin and vim.fn.executable(bin) == 1 then
							return bin
						end
						local root = get_cargo_root()
						with_cwd(root, function()
							if vim.fn.executable("cargo") == 1 then
								vim.fn.system("cargo build")
							end
						end)
						if bin and vim.fn.executable(bin) == 1 then
							return bin
						end
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					args = function()
						local input = vim.fn.input("Args: ")
						if input == "" then
							return {}
						end
						return vim.split(input, "%s+")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					name = "Debug tests",
					type = "codelldb",
					request = "launch",
					program = function()
						local test_bin = get_rust_test_path()
						if test_bin and vim.fn.executable(test_bin) == 1 then
							return test_bin
						end
						return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					name = "Debug test (cursor)",
					type = "codelldb",
					request = "launch",
					program = function()
						local test_bin = get_rust_test_path()
						if test_bin and vim.fn.executable(test_bin) == 1 then
							return test_bin
						end
						return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
					end,
					args = function()
						local name = get_rust_test_name()
						if not name or name == "" then
							return {}
						end
						local input = vim.fn.input("Test args: ", name)
						if input == "" then
							return {}
						end
						return vim.split(input, "%s+")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			local function load_project_dap()
				local path = vim.fn.findfile(".nvim/dap.lua", ".;")
				if path == "" then
					return
				end
				local ok_load, mod = pcall(dofile, path)
				if not ok_load then
					vim.notify("Failed to load " .. path .. ": " .. mod, vim.log.levels.ERROR)
					return
				end
				if type(mod) == "function" then
					local ok_fn, err = pcall(mod, dap)
					if not ok_fn then
						vim.notify("Error running " .. path .. ": " .. err, vim.log.levels.ERROR)
					end
					return
				end
				if type(mod) ~= "table" then
					return
				end
				if type(mod.adapters) == "table" then
					for name, adapter in pairs(mod.adapters) do
						dap.adapters[name] = adapter
					end
				end
				if type(mod.configurations) == "table" then
					for ft, configs in pairs(mod.configurations) do
						if type(configs) == "table" then
							dap.configurations[ft] = dap.configurations[ft] or {}
							for _, cfg in ipairs(configs) do
								table.insert(dap.configurations[ft], cfg)
							end
						end
					end
				end
				if type(mod.setup) == "function" then
					local ok_fn, err = pcall(mod.setup, dap)
					if not ok_fn then
						vim.notify("Error running setup in " .. path .. ": " .. err, vim.log.levels.ERROR)
					end
				end
			end

			load_project_dap()
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
}
