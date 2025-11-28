-- ====================|| VARIABLES || ==================== --

local QBCore = exports['qb-core']:GetCoreObject({'Functions'})
QBCore.Shared = { Jobs = exports['qb-core']:GetSharedJobs() }

-- ====================|| FUNCTIONS || ==================== --

--- Opens the job management menu for the specified job and grade.
--- @param job string
--- @param grade number
local openJobMenu = function(job, grade)
    local jobLabel = QBCore.Shared.Jobs[job].label
    local gradeLabel = QBCore.Shared.Jobs[job].grades[tostring(grade)].name

    local elements = {
        {
            header = ('%s | %s'):format(jobLabel, gradeLabel),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.set_job'),
            txt = Lang:t('menu.set_job_description'),
            params = {
                isAction = true,
                event = function()
                    TriggerServerEvent('qb-multijob:server:setJob', job)
                end
            }
        },
        {
            header = Lang:t('menu.toggle_duty'),
            txt = Lang:t('menu.toggle_duty_description'),
            disabled = QBCore.PlayerData.job.name ~= job,
            params = {
                isAction = true,
                event = function()
                    TriggerServerEvent('qb-multijob:server:setDuty', not QBCore.PlayerData.job.onduty)
                end
            }
        },
        {
            header = Lang:t('menu.remove_job'),
            txt = Lang:t('menu.remove_job_description'),
            params = {
                isAction = true,
                event = function()
                    TriggerServerEvent('qb-multijob:server:remove', job)
                end
            }
        },
        {
            header = '< Salir',
            txt = 'Cerrar el menú.',
            params = {}
        }
    }

    exports['qb-menu']:openMenu(elements)
end

--- Opens the multijob menu for the player to select and manage their jobs.
local multijobMenu = function()
    QBCore.Functions.TriggerCallback('qb-multijob:server:getJobs', function(multijob)
        local elements = {
            {
                header = Lang:t('menu.title'),
                txt = Lang:t('menu.subtitle'),
                isMenuHeader = true
            }
        }

        local UnemployedJob = QBCore.Shared.Jobs[Config.Unemployed.job]

        if UnemployedJob and not multijob[Config.Unemployed.job] then
            elements[#elements + 1] = {
                header = ('%s | %s'):format(UnemployedJob.label, UnemployedJob.grades['0'].name),
                txt = QBCore.PlayerData.job.name == Config.Unemployed.job and Lang:t('menu.current_job') or Lang:t('menu.select_job'),
                disabled = QBCore.PlayerData.job.name == Config.Unemployed.job,
                params = {
                    isAction = true,
                    event = function()
                        openJobMenu(Config.Unemployed.job, Config.Unemployed.grade)
                    end
                }
            }
        end

        for job, grade in pairs(multijob) do
            local QBjob = QBCore.Shared.Jobs[job]
            if QBjob then
                elements[#elements + 1] = {
                    header = ('%s | %s'):format(QBjob.label, QBjob.grades[tostring(grade)].name),
                    txt = QBCore.PlayerData.job.name == job and Lang:t('menu.current_job') or Lang:t('menu.select_job'),
                    disabled = QBCore.PlayerData.job.name == job,
                    params = {
                        isAction = true,
                        event = function()
                            openJobMenu(job, grade)
                        end
                    }
                }
            end
        end

        elements[#elements + 1] = {
            header = '< Salir',
            txt = 'Cerrar el menú.',
            params = {}
        }

        exports['qb-menu']:openMenu(elements)
    end)
end

-- ====================|| EVENTS || ==================== --

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    QBCore.PlayerData = val
end)

-- ====================|| COMMANDS || ==================== --

RegisterCommand(Config.CommandName, multijobMenu, false)
TriggerEvent('chat:addSuggestion', '/' .. Config.CommandName, Lang:t('command.description'), {})