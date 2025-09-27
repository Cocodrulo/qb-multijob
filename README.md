# qb-multijob

A multi-job script for QBCore framework.

## Exports

The following server exports are available:

-   `addJob(id, job, grade)`
    -   Adds a job to the player's multijob list.
-   `removeJob(id, job)`
    -   Removes a job from the player's multijob list.
-   `hasJob(id, job)`
    -   Checks if a player has a specific job in their multijob list.
-   `getEmployees(job)`
    -   Fetches a list of all players who have the specified job in their multijob list.
-   `updateRank(id, job, grade)`
    -   Updates the grade of a job in the player's multijob list.

## Commands

-   `/multijob`
    -   Opens the multijob menu (command name can be change)

## Configuration

See `Config.lua` for options such as `MaxJobs`, `ProhibitedGroups`, `CommandName` and `Unemployed` job settings.

---

For more details, see the code comments and function documentation in `server/exports.lua` and `server/main.lua`.
