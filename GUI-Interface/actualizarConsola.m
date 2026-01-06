function actualizarConsola(handles)
    if ~isfield(handles, 'consoleBuffer')
        return;
    end

    buffer = handles.consoleBuffer;
    totalLines = length(buffer);
    visibleLines = 10;

    % Leer posición actual del slider
    sliderVal = round(get(handles.slider1, 'Value'));
    startIndex = max(1, min(sliderVal, totalLines - visibleLines + 1));
    endIndex = min(totalLines, startIndex + visibleLines - 1);

    visibleText = buffer(startIndex:endIndex);

    % Mostrar en consola
    set(handles.MessageConsole, 'String', visibleText);

    % Actualizar el slider
    maxSlider = max(1, totalLines - visibleLines + 1);
    set(handles.slider1, 'Min', 1);
    set(handles.slider1, 'Max', maxSlider);
    set(handles.slider1, 'SliderStep', [1, 10] ./ maxSlider);
    set(handles.slider1, 'Value', startIndex);  % Mantener posición actual
end
