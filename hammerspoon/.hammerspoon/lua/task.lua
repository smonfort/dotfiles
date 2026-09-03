local M = {}

-- hs.task is GC'd (and killed) once unreferenced, so keep every one here.
local runningTasks = {}

function M.run(launchPath, arguments)
    local task = hs.task.new(launchPath, nil, arguments or {})
    table.insert(runningTasks, task)
    task:start()
    return task
end

return M
