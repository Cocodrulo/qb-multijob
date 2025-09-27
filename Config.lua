Config = Config or {}

Config.MaxJobs = 3 -- Maximum number of jobs a player can have or false for unlimited
Config.Unemployed = { job = "unemployed", grade = 0 } -- Job to set when a player cannot have the new job

Config.CommandName = "multijob" -- Command to open the multijob menu

Config.ProhibitedGroups = { -- Groups of jobs that cannot be held together
    { 'police', 'ambulance' },
    { 'garbage', 'police' }
}