%% Instrument Connection

% Create a VISA-USB object.
interfaceObj = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x03C4::C010424::0::INSTR', 'Tag', ''); 

%Aqui guardo el modelo DPO USB::0x0699::0x0410::C020937::INSTR  

% Create the VISA-USB object if it does not exist


% otherwise use the object that was found.
if isempty(interfaceObj)
    interfaceObj = visa('NI', 'USB0::0x0699::0x03C4::C010424::0::INSTR');
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

% Create a device object. 
deviceObj = icdevice('tektronix_tds2024.mdd', interfaceObj);

% Connect device object to hardware.
connect(deviceObj);

%% Instrument Configuration and Control

% Execute device object function(s).
groupObj = get(deviceObj, 'Waveform');
[Y,X] = invoke(groupObj, 'readwaveform', 'channel1');
plot(X,Y)

%% To save signal
%global data x1 y1 name
data=[X',Y'];
name=('f_b_n1cm_t9.txt');`
save(name, 'data', '-ascii');