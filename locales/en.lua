local Translations = {
    error = {
        cannot_add_job = "You cannot add the job: %{job} because you already have a job in the same group.",
        cannot_remove_unemployed = "You cannot remove the unemployed job.",
    },
    success = {
        new_job = "You have been hired for the job: %{job}.",
        removed_job = "You have been removed from the job: %{job}.",
        set_job = "You have been set to the job: %{job}.",
        updated_grade = "You have been updated to grade: %{grade} for the job: %{job}.",
    },
    info = {
        removed_current_job = "You have been removed from your current job: %{job}. You have been set to unemployed.",
    },
    command = {
        description = "Open the multi-job menu",
    },
    menu = {
        title = "Multi-Job Menu",
        subtitle = "Select a job to switch to",
        current_job = "Current job.",
        select_job = "Select this job to switch to it.",
        set_job = "Set this job as your current job.",
        set_job_description = "Set this job as your current job.",
        toggle_duty = "Toggle duty status.",
        toggle_duty_description = "Toggle your duty status for this job.",
        remove_job = "Remove this job.",
        remove_job_description = "Remove this job from your multi-job list.",
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})