local Translations = {
    error = {
        cannot_add_job = "No puedes agregar el trabajo: %{job} porque ya tienes un trabajo en el mismo grupo.",
        cannot_remove_unemployed = "No puedes eliminar el trabajo de desempleado.",
    },
    success = {
        new_job = "Has sido contratado para el trabajo: %{job}.",
        removed_job = "Has sido eliminado del trabajo: %{job}.",
        set_job = "Has sido asignado al trabajo: %{job}.",
        updated_grade = "Has sido actualizado al grado: %{grade} para el trabajo: %{job}.",
    },
    info = {
        removed_current_job = "Has sido eliminado de tu trabajo actual: %{job}. Has sido puesto como desempleado.",
    },
    command = {
        description = "Abrir el menú de multi-trabajo",
    },
    menu = {
        title = "Menú de Multi-Trabajo",
        subtitle = "Selecciona un trabajo para cambiar a él",
        current_job = "Trabajo actual.",
        select_job = "Selecciona este trabajo para cambiar a él.",
        set_job = "Asignar este trabajo como tu trabajo actual.",
        set_job_description = "Asignar este trabajo como tu trabajo actual.",
        toggle_duty = "Alternar estado de servicio.",
        toggle_duty_description = "Alternar tu estado de servicio para este trabajo.",
        remove_job = "Eliminar este trabajo.",
        remove_job_description = "Eliminar este trabajo de tu lista de trabajos múltiples.",
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end