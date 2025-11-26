-- ====================|| VARIABLES || ==================== --

local QBCore = exports['qb-core']:GetCoreObject()

-- ====================|| HELPERS || ==================== --

--- Gets the size of a table.
--- @param tbl table
--- @return number
local getTableSize = function(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

--- Checks if a value exists in a table.
--- @param tbl table
--- @param value any
--- @return boolean
local isValueInTable = function(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

--- Retrieves a player object, either online or offline.
--- @param source number|string Source ID or Citizen ID
--- @return table|nil Player object or nil if not found
local GetPlayerOrOffline = function(source)
    if type(source) == 'number' then
        return QBCore.Functions.GetPlayer(source)
    else
        return QBCore.Functions.GetPlayerByCitizenId(source) or QBCore.Functions.GetOfflinePlayerByCitizenId(source)
    end
end

-- ====================|| CORE FUNCTIONS || ==================== --

--- Checks if the player already has the specified job in their multijob list.
--- @param multijob table
--- @param job string
--- @return boolean
local AlreadyHasJob = function(multijob, job)
    return multijob[job] ~= nil
end

--- Checks if a job can be added to the player's multijob list.
--- @param multijob table
--- @param job string
--- @return boolean
local canAddJob = function(multijob, job)
    if Config.MaxJobs and getTableSize(multijob) >= Config.MaxJobs then return false end

    for _, jobGroup in pairs(Config.ProhibitedGroups) do
        if isValueInTable(jobGroup, job) then
            for _, singleJob in pairs(jobGroup) do
                if AlreadyHasJob(multijob, singleJob) then return false end
            end
        end
    end
    return true
end

-- ====================|| DATABASE FUNCTIONS || ==================== --

--- Adds a new job to the player's multijob list in the database.
--- @param citizenid string
--- @param job string
--- @param grade number
local addMultijobToDatabase = function(citizenid, job, grade)
    MySQL.insert.await('INSERT INTO player_multijob (citizenid, job, grade) VALUES (?, ?, ?)', {
        citizenid, job, grade
    })
end

--- Removes a job from the player's multijob list in the database.
--- @param citizenid string
--- @param job string
local removeMultijobFromDatabase = function(citizenid, job)
    MySQL.query.await('DELETE FROM player_multijob WHERE citizenid = ? AND job = ?', {
        citizenid, job
    })
end

--- Updates the grade of a job in the player's multijob list in the database.
--- @param citizenid string
--- @param job string
--- @param grade number
local updateMultijobGradeInDatabase = function(citizenid, job, grade)
    MySQL.update.await('UPDATE player_multijob SET grade = ? WHERE citizenid = ? AND job = ?', {
        grade, citizenid, job
    })
end

-- ====================|| EXPORTS || ==================== --

--- Adds a job to the player's multijob list.
--- @param id number|string Player id or citizenid
--- @param job string
--- @param grade number
local addJob = function(id, job, grade)
    local Player = GetPlayerOrOffline(id)
    if not Player then return end
    
    local jobInfo = QBCore.Shared.Jobs[job]
    if not jobInfo then 
        Player.Functions.Notify(Lang:t('error.invalid_job'), 'error')
        return
    end

    local citizenid = Player.PlayerData.citizenid
    local multijob = Player.PlayerData.multijob

    if AlreadyHasJob(multijob, jobInfo.name) then
        if multijob[jobInfo.name] ~= grade then
            updateMultijobGradeInDatabase(citizenid, jobInfo.name, grade)
            Player.PlayerData.multijob[jobInfo.name] = grade
            if Player.Offline then
                Player.Functions.SavePlayerData()
                return
            end

            local gradeInfo = jobInfo.grades[tostring(grade)]
            if not gradeInfo then
                Player.Functions.Notify(Lang:t('error.invalid_grade'), 'error')
                return
            end

            Player.Functions.Notify(Lang:t('success.updated_grade', { job = jobInfo.label, grade = gradeInfo.name }), 'success')
            return
        end
    end

    if not canAddJob(multijob, jobInfo.name) then
        if not Player.Offline then
            Player.Functions.Notify(Lang:t('error.cannot_add_job', { job = jobInfo.label }), 'error')
        end
        return
    end

    addMultijobToDatabase(citizenid, jobInfo.name, grade)
    Player.PlayerData.multijob[jobInfo.name] = grade
    if Player.Offline then
        Player.Functions.SavePlayerData()
        return
    end

    Player.Functions.Notify(Lang:t('success.new_job', { job = jobInfo.label }), 'success')
end

exports('addJob', addJob)

--- Removes a job from the player's multijob list.
--- @param id number|string Player id or citizenid
--- @param job string
local removeJob = function(id, job)

    local Player = GetPlayerOrOffline(id)
    if not Player then return end

    local jobInfo = QBCore.Shared.Jobs[job]
    if not jobInfo then
        Player.Functions.Notify(Lang:t('error.invalid_job'), 'error')
        return
    end

    if job == Config.Unemployed.job then
        if not Player.Offline then
            Player.Functions.Notify(Lang:t('error.cannot_remove_unemployed'), 'error')
        end
        return
    end

    if not AlreadyHasJob(Player.PlayerData.multijob, job) then return end

    local citizenid = Player.PlayerData.citizenid

    if Player.PlayerData.job.name == job then
        Player.Functions.SetJob(Config.Unemployed.job, Config.Unemployed.grade)
        removeMultijobFromDatabase(citizenid, job)
        Player.PlayerData.multijob[job] = nil
        if Player.Offline then
            Player.Functions.SavePlayerData()
            return
        end

        Player.Functions.Notify(Lang:t('info.removed_current_job', { job = jobInfo.label }), 'info')
        return
    end

    removeMultijobFromDatabase(citizenid, job)
    Player.PlayerData.multijob[job] = nil
    if Player.Offline then
        Player.Functions.SavePlayerData()
        return
    end

    Player.Functions.Notify(Lang:t('success.removed_job', { job = jobInfo.label }), 'success')
end

exports('removeJob', removeJob)

--- Checks if a player has a specific job in their multijob list.
--- @param id number|string Player id or citizenid
--- @param job string
--- @return boolean
local hasJob = function(id, job)
    local Player = GetPlayerOrOffline(id)
    if not Player then return false end

    return AlreadyHasJob(Player.PlayerData.multijob, job)
end

exports('hasJob', hasJob)

--- Fetches a list of all players who have the specified job in their multijob list.
--- @param job string
--- @return table
local getEmployees = function(job)
    local result = MySQL.query.await('SELECT citizenid, grade FROM player_multijob WHERE job = ?', { job })
    local employees = {}
    if result then
        for _, v in pairs(result) do
            employees[#employees + 1] = {
                citizenid = v.citizenid,
                job = job,
                grade = v.grade
            }
        end
    end
    return employees
end

exports('getEmployees', getEmployees)

--- Updates the grade of a job in the player's multijob list.
--- @param id number|string Player id or citizenid
--- @param job string
--- @param grade number
local updateRank = function(id, job, grade)
    local Player = GetPlayerOrOffline(id)
    if not Player then return end

    local jobInfo = QBCore.Shared.Jobs[job]
    if not jobInfo then
        Player.Functions.Notify(Lang:t('error.invalid_job'), 'error')
        return
    end

    if not AlreadyHasJob(Player.PlayerData.multijob, jobInfo.name) then
        Player.Functions.Notify(Lang:t('error.not_have_job', { job = jobInfo.label }), 'error')
        return
    end

    local gradeInfo = jobInfo.grades[tostring(grade)]
    if not gradeInfo then
        Player.Functions.Notify(Lang:t('error.invalid_grade'), 'error')
        return
    end

    if Player.PlayerData.multijob[jobInfo.name] == grade then
        Player.Functions.Notify(Lang:t('error.already_have_grade', { grade = gradeInfo.name, job = jobInfo.label }), 'error')
        return
    end

    updateMultijobGradeInDatabase(Player.PlayerData.citizenid, jobInfo.name, grade)
    Player.PlayerData.multijob[jobInfo.name] = grade
    if Player.Offline then
        Player.Functions.SavePlayerData()
        return
    end

    Player.Functions.Notify(Lang:t('success.updated_grade', { job = jobInfo.label, grade = gradeInfo.name }), 'success')
end

exports('updateRank', updateRank)

--- Switches the player's current job to the specified job if available.
--- @param source number
--- @param job string
local switchJob = function(source, job)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if Player.PlayerData.job.name == job then return end
    if not Player.PlayerData.multijob[job] then return end

    local grade = Player.PlayerData.multijob[job]
    Player.Functions.SetJob(job, grade)
    Player.Functions.Notify(Lang:t('success.set_job', { job = job }), 'success')
end

exports('switchJob', switchJob)

--- Toggles the duty status for the player.
--- @param source number
--- @param onDuty boolean
local toggleDuty = function(source, onDuty)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if Player.PlayerData.job.onduty == onDuty then return end
    Player.Functions.SetJobDuty(onDuty)
end

exports('toggleDuty', toggleDuty)
