-- ====================|| VARIABLES || ==================== --

QBCore = exports['qb-core']:GetCoreObject({'Functions'})

-- ====================|| FUNCTIONS || ==================== --

--- Fetches the multijob list for the specified player from the database.
--- @param Player table
--- @return table
local getMultijobDatabase = function (Player)
    local p = promise.new()
    MySQL.Async.fetchAll('SELECT * FROM multijob WHERE player_cid = @player_cid', {
        ['@player_cid'] = Player.PlayerData.citizenid
    }, function (result)
        local multijob = {[Config.Unemployed.job] = Config.Unemployed.grade}
        if result[1] then
            for _, v in pairs(result) do
                multijob[v.job] = v.grade
            end
        end
        p:resolve(multijob)
    end)
    return Citizen.Await(p)
end

--- Handles when a player gets a new job.
--- @param source number
--- @param job table
local onNewJob = function (source, job)
    exports['qb-multijob']:addJob(source, job.name, job.grade.level)
end

--- Removes a job from the player's multijob list.
--- @param source number
--- @param job string
local removeJob = function (source, job)
    exports['qb-multijob']:removeJob(source, job)
end

--- Toggles the duty status of the current job for the specified player.
--- @param source number
--- @param onDuty boolean
local setDuty = function (source, onDuty)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player.PlayerData.job.onduty == onDuty then return end
    Player.Functions.SetJobDuty(onDuty)
end

--- Sets the current player job to the specified job if they have it in their multijob list.
--- @param source number
--- @param job string
local setJob = function (source, job)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player.PlayerData.job.name == job then return end
    if not AlreadyHasJob(Player.PlayerData.multijob, job) then return end

    local grade = Player.PlayerData.multijob[job]
    Player.Functions.SetJob(job, grade)
    Player.Functions.Notify(Lang:t('success.set_job', { job = job }), 'success')
end

--- Creates the multijob field in the player data and adds the necessary player methods.
--- @param Player table
local playerCreated = function(Player)
    Player.Functions.AddField('multijob', getMultijobDatabase(Player), true)

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
