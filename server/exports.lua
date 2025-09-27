-- ====================|| FUNCTIONS || ==================== --

--- Gets the size of a table.
--- @param table table
--- @return number
local getTableSize = function (table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

--- Checks if a value exists in a table.
--- @param table table
--- @param value any
--- @return boolean
local isValueInTable = function (table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

--- Checks if the player already has the specified job in their multijob list.
--- @param multijob table
--- @param job string
--- @return boolean
AlreadyHasJob = function (multijob, job)
    return multijob[job] ~= nil
end

--- Checks if a job can be added to the player's multijob list.
--- @param multijob table
--- @param job string
--- @return boolean
local canAddJob = function (multijob, job)
    if Config.MaxJobs ~= false and getTableSize(multijob) >= Config.MaxJobs then return false end

    for _, jobGroup in pairs(Config.ProhibitedGroups) do
        if isValueInTable(jobGroup, job) then
            for _, singleJob in pairs(jobGroup) do
                if AlreadyHasJob(multijob, singleJob) then return false end
            end
        end
    end
    return true
end

--- Adds a new job to the player's multijob list in the database.
--- @param Player table
--- @param job string
--- @param grade number
local addMultijobToDatabase = function (Player, job, grade)
    MySQL.Async.execute('INSERT INTO multijob (player_cid, job, grade) VALUES (@player_cid, @job, @grade)', {
        ['@player_cid'] = Player.PlayerData.citizenid,
        ['@job'] = job,
        ['@grade'] = grade
    })
end

--- Removes a job from the player's multijob list in the database.
--- @param Player table
--- @param job string
local removeMultijobFromDatabase = function (Player, job)
    MySQL.Async.execute('DELETE FROM multijob WHERE player_cid = @player_cid AND job = @job', {
        ['@player_cid'] = Player.PlayerData.citizenid,
        ['@job'] = job
    })
end

--- Updates the grade of a job in the player's multijob list in the database.
--- @param Player table
--- @param job string
--- @param grade number
local updateMultijobGradeInDatabase = function (Player, job, grade)
    MySQL.Async.execute('UPDATE multijob SET grade = @grade WHERE player_cid = @player_cid AND job = @job', {
        ['@player_cid'] = Player.PlayerData.citizenid,
        ['@job'] = job,
        ['@grade'] = grade
    })
end

--- Adds a job to the player's multijob list.
--- @param id number | string Player id or citizenid
--- @param job string
--- @param grade number
local addJob = function(id, job, grade)
    local jobInfo = QBCore.Shared.Jobs[job]
    if not jobInfo then return end

    local Player = QBCore.Functions.GetPlayer(id) or QBCore.Functions.GetOfflinePlayerByCitizenId(id)
    if not Player then return end

    if AlreadyHasJob(Player.PlayerData.multijob, jobInfo.name) then
        if Player.PlayerData.multijob[jobInfo.name] ~= grade then
            updateMultijobGradeInDatabase(Player, jobInfo.name, grade)
            Player.PlayerData.multijob[jobInfo.name] = grade
            Player.Functions.SavePlayerData()
            Player.Functions.Notify(Lang:t('success.updated_grade', { job = jobInfo.label, grade = jobInfo.grades[tostring(grade)].name }), 'success')
            return
        end
    end

    if not canAddJob(Player.PlayerData.multijob, jobInfo.name) then
        Player.Functions.SetJob(Config.Unemployed.job, Config.Unemployed.grade)
        Player.Functions.Notify(Lang:t('error.cannot_add_job', { job = jobInfo.label }), 'error')
        return
    end

    addMultijobToDatabase(Player, jobInfo.name, grade)
    Player.PlayerData.multijob[jobInfo.name] = grade
    Player.Functions.SavePlayerData()
    Player.Functions.Notify(Lang:t('success.new_job', { job = jobInfo.label }), 'success')
end

exports('addJob', addJob)

--- Removes a job from the player's multijob list.
--- @param id number | string Player id or citizenid
--- @param job string
local removeJob = function(id, job)
    local jobInfo = QBCore.Shared.Jobs[job]
    if not jobInfo then return end

    local Player = QBCore.Functions.GetPlayer(id) or QBCore.Functions.GetOfflinePlayerByCitizenId(id)
    if not Player then return end

    if job == Config.Unemployed.job then
        Player.Functions.Notify(Lang:t('error.cannot_remove_unemployed'), 'error')
        return
    end

    if not AlreadyHasJob(Player.PlayerData.multijob, job) then return end
    if Player.PlayerData.job.name == job then
        Player.Functions.SetJob(Config.Unemployed.job, Config.Unemployed.grade)
        removeMultijobFromDatabase(Player, job)
        Player.PlayerData.multijob[job] = nil
        Player.Functions.SavePlayerData()
        Player.Functions.Notify(Lang:t('info.removed_current_job', { job = jobInfo.label }), 'info')
        return
    end

    removeMultijobFromDatabase(Player, job)
    Player.PlayerData.multijob[job] = nil
    Player.Functions.SavePlayerData()
    Player.Functions.Notify(Lang:t('success.removed_job', { job = jobInfo.label }), 'success')
end

exports('removeJob', removeJob)

--- Checks if a player has a specific job in their multijob list.
--- @param id number | string Player id or citizenid
--- @param job string
--- @return boolean
local hasJob = function(id, job)
    local Player = QBCore.Functions.GetPlayer(id) or QBCore.Functions.GetOfflinePlayerByCitizenId(id)
    if not Player then return false end

    return AlreadyHasJob(Player.PlayerData.multijob, job)
end

exports('hasJob', hasJob)

--- Fetches a list of all players who have the specified job in their multijob list.
--- @param job string
--- @return table
local getEmployees = function(job)
    local p = promise.new()
    MySQL.Async.fetchAll('SELECT player_cid, grade FROM multijob WHERE job = @job', {
        ['@job'] = job
    }, function (result)
        local employees = {}
        if result[1] then
            for _, v in pairs(result) do
                employees[#employees + 1] = {
                    citizenid = v.player_cid,
                    job = job,
                    grade = v.grade
                }
            end
        end
        p:resolve(employees)
    end)
    return Citizen.Await(p)
end

exports('getEmployees', getEmployees)

--- Updates the grade of a job in the player's multijob list.
--- @param id number | string Player id or citizenid
--- @param job string
--- @param grade number
local updateRank = function(id, job, grade)
    local jobInfo = QBCore.Shared.Jobs[job]
    if not jobInfo then return end

    local Player = QBCore.Functions.GetPlayer(id) or QBCore.Functions.GetOfflinePlayerByCitizenId(id)
    if not Player then return end

    if not AlreadyHasJob(Player.PlayerData.multijob, jobInfo.name) then return end
    if Player.PlayerData.multijob[jobInfo.name] == grade then return end

    updateMultijobGradeInDatabase(Player, jobInfo.name, grade)
    Player.PlayerData.multijob[jobInfo.name] = grade
    Player.Functions.SavePlayerData()
    Player.Functions.Notify(Lang:t('success.updated_grade', { job = jobInfo.label, grade = jobInfo.grades[tostring(grade)].name }), 'success')
end

exports('updateRank', updateRank)