function handles = prepararDatos(hObject, handles, numElementos, numprojection)
    % Obtener carpeta y rangos
    carpeta = handles.folderSelected;
    rangoX = 'A1:A8500';
    rangoY = 'B1:B8500';

    % Cargar si no existen
    if ~isfield(handles, 'X') || isempty(handles.X) || ~isfield(handles, 'Y') || isempty(handles.Y)
        [X, Y, nombres] = leerCSVdesdeCarpeta(carpeta, rangoX, rangoY);
        handles.X = X;
        handles.Y = Y;
    else
        X = handles.X;
        Y = handles.Y;
    end

    % Decidir cuál señal usar
    if get(handles.kalman, 'Value') == 1 && isfield(handles, 'Y_Filtradas') && ~isempty(handles.Y_Filtradas)
        Y_actual = handles.Y_Filtradas;
    else
        Y_actual = handles.Y;
    end

    % Calcular proyecciones
    [delta_t, N_time, N_amp, N_energy] = analizarMaximos(X, Y_actual, numElementos);

    % Guardarlos en handles
    handles.datosGuardados = struct( ...
        'delta_t', delta_t, ...
        'N_time', N_time, ...
        'N_amp', N_amp, ...
        'N_energy', N_energy, ...
        'Phi', round(linspace(0, 180, numprojection)) ...
    );
    guidata(hObject, handles);  % Muy importante para actualizar los cambios
end
