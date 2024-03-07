local M = {}

local function terminal_close_autocmd()
	local current_buf = vim.api.nvim_get_current_buf()
	local augroup_name = tostring(current_buf) ..
			"_" .. vim.fn.jobpid(vim.b.terminal_job_id) .. "_" .. string.format('%x', os.time() + math.random(1000))

	local function delete_term_buf_autocmd(ev_outer)
		local function close_term_buffer(ev_inner)
			local buf = ev_inner.buf
			vim.cmd([[bdelete ]] .. buf)

			return true
		end
		vim.api.nvim_create_autocmd("TermClose",
			{
				group = augroup_name,
				buffer = ev_outer.buf,
				callback = close_term_buffer,
				once = true
			})
		return true
	end

	vim.api.nvim_create_augroup(augroup_name, { clear = false })

	vim.api.nvim_create_autocmd("TermOpen",
		{
			group = augroup_name,
			callback = delete_term_buf_autocmd,
			once = true,
		})
end

function M.term_vsplit()
	if vim.bo.buftype == 'terminal' then
		local pid = vim.fn.jobpid(vim.b.terminal_job_id)
		local pwd
		if vim.fn.has('win32') == 1 then  -- For Windows
			vim.cmd('vsplit | term')
		elseif vim.fn.has('unix') == 1 then -- For Unix/Linux
			pwd = vim.fn.systemlist('readlink /proc/' .. pid .. '/cwd')[1]
			if pwd == "" or pwd == nil then
				pwd = vim.fn.systemlist('lsof -p ' .. pid .. ' | grep cwd | awk \'{print $NF}\'')[1]
			end
			vim.cmd('vsplit')
			terminal_close_autocmd()
			vim.cmd('term sh -c \'cd "' .. pwd .. '" && exec $SHELL\'')
		end
	else
		vim.cmd('vsplit')
	end
end

function M.term_hsplit()
	if vim.bo.buftype == 'terminal' then
		local pid = vim.fn.jobpid(vim.b.terminal_job_id)
		local pwd
		if vim.fn.has('win32') == 1 then  -- For Windows
			vim.cmd('split | term')
		elseif vim.fn.has('unix') == 1 then -- For Unix/Linux
			pwd = vim.fn.systemlist('readlink /proc/' .. pid .. '/cwd')[1]
			if pwd == "" or pwd == nil then
				pwd = vim.fn.systemlist('lsof -p ' .. pid .. ' | grep cwd | awk \'{print $NF}\'')[1]
			end
			vim.cmd('split')
			terminal_close_autocmd()
			vim.cmd('term sh -c \'cd "' .. pwd .. '" && exec $SHELL\'')
		end
	else
		vim.cmd('split')
	end
end

 M.setup = function ()
	vim.api.nvim_create_user_command('Tsplit', M.term_hsplit, { bar = true })
	vim.api.nvim_create_user_command('Tvsplit', M.term_vsplit, { bar = true })
end

return M
