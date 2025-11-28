# 👷 qb-multijob

A comprehensive multi-job system for the QBCore framework, allowing players to hold multiple jobs simultaneously with configurable limits and restrictions.

## ✨ Features

-   💼 **Multiple Jobs**: Players can have multiple jobs at the same time.
-   🔢 **Configurable Limits**: Set a maximum number of jobs a player can hold.
-   🚫 **Job Restrictions**: Prevent players from holding conflicting jobs (e.g., Police and Ambulance) using `ProhibitedGroups`.
-   🖥️ **User-Friendly Menu**: Built with `qb-menu` for easy job management.
-   📉 **Unemployed Fallback**: Automatically handles the "unemployed" status.
-   🛠️ **Developer Friendly**: Includes server-side exports for easy integration with other resources.
-   🌍 **Localization**: Supports multiple languages via `locales`.

## 📦 Dependencies

-   [qb-core](https://github.com/qbcore-framework/qb-core)
-   [oxmysql](https://github.com/overextended/oxmysql)
-   [qb-menu](https://github.com/qbcore-framework/qb-menu)

## 💿 Installation

1. **Download**: Clone or download this repository to your `resources` directory.
2. **Database**: Import the `multijob.sql` file into your database.
3. **Configuration**: Adjust `Config.lua` to your liking.
4. **Server Config**: Add the following to your `server.cfg`:

    ```cfg
    ensure qb-multijob
    ```

## ⚙️ Configuration

You can customize the resource in `Config.lua`:

| Option                    | Description                                                       | Default                             |
| :------------------------ | :---------------------------------------------------------------- | :---------------------------------- |
| `Config.MaxJobs`          | Maximum number of jobs a player can have (`false` for unlimited). | `3`                                 |
| `Config.Unemployed`       | The default job when a player has no other active job.            | `{ job = "unemployed", grade = 0 }` |
| `Config.CommandName`      | The command to open the multi-job menu.                           | `"multijob"`                        |
| `Config.ProhibitedGroups` | List of job groups that cannot be held simultaneously.            | `{{ 'police', 'ambulance' }, ...}`  |

## 🚀 Usage

-   **Command**: Use `/multijob` (or your configured command) to open the menu.
-   **Menu Options**:
    -   **Select Job**: Switch your active job.
    -   **Toggle Duty**: Go on/off duty for your current job.
    -   **Remove Job**: Quit a specific job.

## 📤 Exports

| Export              | Description                                                | Usage                                                   | Availability     |
| :------------------ | :--------------------------------------------------------- | :------------------------------------------------------ | :--------------- |
| `AddJob`            | Adds a job to the player's multi-job list.                 | `exports['qb-multijob']:AddJob(source, job, grade)`     | Online & Offline |
| `RemoveJob`         | Removes a job from the player's multi-job list.            | `exports['qb-multijob']:RemoveJob(source, job)`         | Online & Offline |
| `HasJob`            | Checks if a player has a specific job.                     | `exports['qb-multijob']:HasJob(source, job)`            | Online & Offline |
| `GetEmployees`      | Fetches a list of all players who have the specified job.  | `exports['qb-multijob']:GetEmployees(job)`              | Online & Offline |
| `GetPlayerMultiJob` | Fetches the list of jobs for a player.                     | `exports['qb-multijob']:GetPlayerMultiJob(source)`      | Online & Offline |
| `UpdateRank`        | Updates the grade of a job in the player's multi-job list. | `exports['qb-multijob']:UpdateRank(source, job, grade)` | Online & Offline |
| `SwitchJob`         | Switches the player's current job to the specified job.    | `exports['qb-multijob']:SwitchJob(source, job)`         | Online (Only)    |
| `ToggleDuty`        | Toggles the duty status for the player.                    | `exports['qb-multijob']:ToggleDuty(source, onDuty)`     | Online (Only)    |

## 📜 License

This project is licensed under the [GPL-3.0 License](LICENSE).
