function Character = Charactergenerator(texto, NX, angulo)
%GENERARLETRABINARIA Genera una imagen binaria de una letra centrada.
%
%   ImagenBinaria = generarLetraBinaria('A')
%
%   Entradas:
%       texto - Carácter (letra) a insertar en la imagen.
%
%   Salida:
%       ImagenBinaria - Imagen binaria con la letra renderizada al centro.

    % Dimensiones de la imagen
    Nx = NX;
    Ny = Nx;

    x0 = round(Nx / 2);
    y0 = x0;

    % Imagen en negro
    Imagen = zeros(Nx, Ny);

    % Posición del texto
    posicion = [x0, y0 - 10];  % Ajuste fino del centro

    % Insertar texto en la imagen
    ImagenConTexto = insertText(Imagen, posicion, texto, ...
        'Font', 'Lucida Calligraphy', ...
        'FontSize', 100, ...
        'BoxOpacity', 0, ...
        'TextColor', 'white', ...
        'AnchorPoint', 'center');

    % Convertir a imagen binaria
    Character = imbinarize(rgb2gray(ImagenConTexto), 0);
    Character = imrotate(Character, angulo, 'nearest', 'crop');
    % (Opcional) Mostrar resultado
    % figure; imshow(ImagenBinaria, []);
end
