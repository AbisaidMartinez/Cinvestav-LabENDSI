function actualizarProyecciones(handles, opcion, numElementos, numproyecciones)
    % Obtener los datos procesados
    datos = handles.datosGuardados;

    % Crear figura temporal (oculta)
    fig = figure('Visible', 'off');

    % Seleccionar qué graficar
    switch opcion
        case 'Time'
            matriz = datos.N_time;
            tituloGeneral = 'Time Projections';
        case 'Time Standard'
            matriz = datos.delta_t;
            tituloGeneral = 'Time 2 Projections';    
        case 'Amplitude'
            matriz = datos.N_amp;
            tituloGeneral = 'Amplitude Projections';
        case 'Energy'
            matriz = datos.N_energy;
            tituloGeneral = 'Energy Projections';
    end

    hold on;
    for Id = 1 : numproyecciones
        subplot(4,5,Id);
        plot(matriz(:, Id));
        title(['Angle = ', num2str(datos.Phi(Id))]);
        xlim([0, numElementos]);
    end
    sgtitle(tituloGeneral);

    % Capturar imagen
    frame = getframe(fig);
    img = frame.cdata;
    close(fig);

    % Mostrar en el axes
    axes(handles.time_proj);
    imshow(imresize(img, [512, 1000]), 'Parent', handles.time_proj);
end
