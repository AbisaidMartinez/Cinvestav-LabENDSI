% Especificar la ruta del conjunto de datos
dataPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Databases_for_publish\Database01\rgb';

% Cargar el conjunto de datos
imds = imageDatastore(dataPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');%, ...
    %'ReadFcn', @(filename) resizeFcn(imread(filename)));  % Redimensionar al leer

% Mostrar etiquetas asignadas
disp('Etiquetas detectadas:');
disp(categories(imds.Labels));

% Dividir el conjunto de datos en entrenamiento y validación
[imdsTrain, imdsValidation] = splitEachLabel(imds, 0.8, 'randomized'); %imds

%%
inputSize = [227 227 3]; % O [224 224 3] según prefieras

augimdsTrain = augmentedImageDatastore(inputSize, imdsTrain);
augimdsValidation = augmentedImageDatastore(inputSize, imdsValidation);

%% AlexNet

net = alexnet;

lgraph = layerGraph(net);

%newInputLayer = imageInputLayer([224 224 3], ...
%    'Name','new_input', ...
%    'Normalization','zerocenter');
% Reemplazar la capa original de entrada
%lgraph = replaceLayer(lgraph,'data',newInputLayer);

newFCLayer = fullyConnectedLayer(length(categories(imds.Labels)), 'Name', 'new_fc', 'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10); %6
newClassLayer = classificationLayer('Name', 'new_class');
lgraph = replaceLayer(lgraph, 'fc8', newFCLayer);
lgraph = replaceLayer(lgraph, 'output', newClassLayer);

%% SqueezeNet

net = squeezenet;

lgraph = layerGraph(net);

numClasses = 3;

% Nueva capa convolucional para 3 clases
newConvLayer = convolution2dLayer(1, numClasses, ...
    'Name','new_conv', ...
    'WeightLearnRateFactor',10, ...
    'BiasLearnRateFactor',10);

% Nueva capa de clasificación
newClassLayer = classificationLayer('Name','new_class');

% Reemplazar capas finales
lgraph = replaceLayer(lgraph,'conv10',newConvLayer);

lgraph = replaceLayer(lgraph, 'ClassificationLayer_predictions', newClassLayer);

%% googlenet non-pretrained

net = googlenet;%('weights', 'none');

lgraph = layerGraph(net);%net;%

newFCLayer = fullyConnectedLayer(length(categories(imds.Labels)), 'Name', 'new_fc', 'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10); %6
newClassLayer = classificationLayer('Name', 'new_class');
lgraph = replaceLayer(lgraph, 'loss3-classifier', newFCLayer);
lgraph = replaceLayer(lgraph, 'output', newClassLayer);


%%

% Opciones de entrenamiento - optimizadas para VGG
options = trainingOptions('sgdm', ...%'adam', ...%
    'MiniBatchSize', 32, ... % Tamaño de lote más pequeño debido a la profundidad de VGG
    'MaxEpochs', 20, ...
    'InitialLearnRate', 0.0001, ... % Tasa baja para fine-tuning
    'L2Regularization', 0.0005, ... % VGG suele necesitar regularización para evitar overfitting
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 5, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', 30, ...
    'ValidationPatience', 5, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu');

%analyzeNetwork(lgraph)

% Entrenar la red
[net, info] = trainNetwork(imdsTrain, lgraph, options);

% Guardar el modelo entrenado (opcional)
save('squeezenet_threeclassHW.mat', 'net', 'info');

%% Predecir etiquetas para el conjunto de validación
YPred = classify(net, imdsValidation);%augimdsValidation);%
YValidation = imdsValidation.Labels;
%allScores = scores;

% Calcular precisión general
accuracy = sum(YPred == YValidation)/numel(YValidation);
fprintf('Precisión en el conjunto de validación: %.2f%%\n', accuracy * 100);

% Matriz de confusión
figure;
cm = confusionchart(YValidation, YPred);
cm.Title = 'Matriz de Confusión para VGG-16';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';

% Métricas detalladas por clase
classNames = categories(YValidation);
numClasses = numel(classNames);


precision = zeros(numClasses, 1);
recall = zeros(numClasses, 1);
f1Score = zeros(numClasses, 1);

for i = 1:numClasses
    currentClass = classNames{i};
    
    % Calcular métricas
    truePositives = sum(YPred == currentClass & YValidation == currentClass);
    falsePositives = sum(YPred == currentClass & YValidation ~= currentClass);
    falseNegatives = sum(YPred ~= currentClass & YValidation == currentClass);
    
    precision(i) = truePositives / (truePositives + falsePositives);
    recall(i) = truePositives / (truePositives + falseNegatives);
    f1Score(i) = 2 * (precision(i) * recall(i)) / (precision(i) + recall(i));
    
    fprintf('Clase %s: Precisión=%.2f, Recall=%.2f, F1-Score=%.2f\n', ...
        currentClass, precision(i), recall(i), f1Score(i));
end

% Crear visualización adicional de las métricas por clase
figure;
bar([precision, recall, f1Score]);
set(gca, 'XTickLabel', classNames);
legend('Precisión', 'Recall', 'F1-Score');
title('Métricas de rendimiento por clase');
ylabel('Puntuación');
xlabel('Clase');