function logMessage(handles, nuevoMensaje)
    % Obtiene el contenido actual
    actual = get(handles.MessageConsole, 'String');

    % Si es texto plano, conviértelo a cell
    if ischar(actual)
        actual = {actual};
    end

    % Añadir nuevo mensaje al final
    nuevo = [actual; {nuevoMensaje}];

    % Limitar número de líneas (opcional)
    maxLines = 200;
    if numel(nuevo) > maxLines
        nuevo = nuevo(end - maxLines + 1:end);
    end

    % Mostrar en consola
    set(handles.MessageConsole, 'String', nuevo);

    % Actualizar slider
    totalLines = length(nuevo);
    visibleLines = 10;
    maxSlider = max(1, totalLines - visibleLines + 1);
    set(handles.slider1, 'Min', 1);
    set(handles.slider1, 'Max', maxSlider);
    set(handles.slider1, 'SliderStep', [1, 10] ./ maxSlider);
    set(handles.slider1, 'Value', maxSlider);  % ¡Manténlo abajo!

    % Guarda en handles si quieres que el slider tenga control del buffer
    handles.consoleBuffer = nuevo;
    guidata(handles.figure1, handles);
end


%%
% function logMessage(handles, mensaje)
%     maxLines = 100;  % Número máximo de líneas que quieres mantener
% 
%     % Obtener los mensajes antiguos
%     oldMessages = get(handles.MessageConsole, 'String');
% 
%     % Asegurar formato de celda
%     if ischar(oldMessages)
%         oldMessages = {oldMessages};
%     end
% 
%     % Agregar el nuevo mensaje
%     allMessages = [oldMessages; {mensaje}];
% 
%     % Si hay demasiadas líneas, eliminar las más antiguas
%     if numel(allMessages) > maxLines
%         allMessages = allMessages(end-maxLines+1:end);
%     end
% 
%     % Actualizar la consola de mensajes
%     set(handles.MessageConsole, 'String', allMessages);
% 
%     % Mover scroll al final para ver el mensaje más reciente
%     set(handles.MessageConsole, 'Value', numel(allMessages));
% 
%     drawnow;  % Asegura que se actualice la interfaz
% end


%% Funcion original
% function logMessage(handles, mensaje)
%     oldMessages = get(handles.MessageConsole, 'String');
% 
%     % Asegura que siempre sea una celda de strings
%     if ischar(oldMessages)
%         oldMessages = {oldMessages};
%     end
% 
%     % Agrega nuevo mensaje
%     allMessages = [oldMessages; {mensaje}];
% 
%     % Muestra en consola
%     set(handles.MessageConsole, 'String', allMessages);
%     set(handles.MessageConsole, 'Value', numel(allMessages));
% end
