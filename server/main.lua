-- ====================|| VARIABLES || ==================== --

local QBCore = exports['qb-core']:GetCoreObject()

-- ====================|| FUNCTIONS || ==================== --

--- Loads the multijob list for a player from the database.
--- @param citizenid string
--- @return table
local loadMultijob = function(citizenid)
    local result = MySQL.query.await('SELECT * FROM player_multijob WHERE player_cid = ?', { citizenid })
    local multijob = {[Config.Unemployed.job] = Config.Unemployed.grade}
    if result then
        for _, v in pairs(result) do
            multijob[v.job] = v.grade
        end
    end
    return multijob
end

--- Handles when a player gets a new job.
--- @param source number
--- @param job table
local onNewJob = function(source, job)
    exports['qb-multijob']:addJob(source, job.name, job.grade.level)
end

--- Removes a job from the player's multijob list.
--- @param source number
--- @param job string
local removeJob = function(source, job)
    exports['qb-multijob']:removeJob(source, job)
end

--- Toggles the duty status of the current job for the specified player.
--- @param source number
--- @param onDuty boolean
local setDuty = function(source, onDuty)
    exports['qb-multijob']:toggleDuty(source, onDuty)
end

--- Sets the current player job to the specified job if they have it in their multijob list.
--- @param source number
--- @param job string
local setJob = function(source, job)
    exports['qb-multijob']:switchJob(source, job)
end

--- Creates the multijob field in the player data and adds the necessary player methods.
--- @param Player table
local playerCreated = function(Player)
    Player.Functions.SetPlayerData('multijob', loadMultijob(Player.PlayerData.citizenid))

    Player.Functions.AddPlayerMethod('AddMultiJob', function(job, grade)
        exports['qb-multijob']:addJob(Player.PlayerData.source, job, grade)
    end)

    Player.Functions.AddPlayerMethod('RemoveMultiJob', function(job)
        exports['qb-multijob']:removeJob(Player.PlayerData.source, job)
    end)

    Player.Functions.AddPlayerMethod('UpdateRank', function(job, grade)
        exports['qb-multijob']:updateRank(Player.PlayerData.source, job, grade)
    end)
end

-- ====================|| EVENTS HANDLERS || ==================== --

RegisterNetEvent('QBCore:Server:PlayerLoaded', playerCreated)
RegisterNetEvent('QBCore:Server:OnJobUpdate', onNewJob)
RegisterNetEvent('qb-multijob:server:remove', removeJob)
RegisterNetEvent('qb-multijob:server:setJob', setJob)
RegisterNetEvent('qb-multijob:server:setDuty', setDuty)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    local players = QBCore.Functions.GetPlayers()
    for _, source in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            playerCreated(Player)
        end
    end
end)
