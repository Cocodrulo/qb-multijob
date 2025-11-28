-- ====================|| VARIABLES || ==================== --

local CreateCallback = exports['qb-core'].CreateCallback

-- ====================|| FUNCTIONS || ==================== --

--- Handles when a player gets a new job.
--- @param source number
--- @param job table
local onNewJob = function(source, job)
    exports['qb-multijob']:AddJob(source, job.name, job.grade.level)
end

--- Removes a job from the player's multijob list.
--- @param source number
--- @param job string
local removeJob = function(source, job)
    exports['qb-multijob']:RemoveJob(source, job)
end

--- Toggles the duty status of the current job for the specified player.
--- @param source number
--- @param onDuty boolean
local setDuty = function(source, onDuty)
    exports['qb-multijob']:ToggleDuty(source, onDuty)
end

--- Sets the current player job to the specified job if they have it in their multijob list.
--- @param source number
--- @param job string
local setJob = function(source, job)
    exports['qb-multijob']:SwitchJob(source, job)
end

-- ====================|| CALLBACKS || ==================== --

CreateCallback('qb-multijob:server:getJobs', function(source, cb)
    cb(exports['qb-multijob']:GetPlayerMultiJob(source))
end)

-- ====================|| EVENTS HANDLERS || ==================== --

AddEventHandler('QBCore:Server:OnJobUpdate', onNewJob)
RegisterNetEvent('qb-multijob:server:remove', removeJob)
RegisterNetEvent('qb-multijob:server:setJob', setJob)
RegisterNetEvent('qb-multijob:server:setDuty', setDuty)
