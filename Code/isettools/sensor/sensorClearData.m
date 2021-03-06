function sensor = sensorClearData(sensor)
%Clear data and noise fields stored in the sensor array.
%
%   sensor = sensorClearData(sensor)
%
% When parameters change and data are no longer consistent, we clear the
% data and various stored noise image fields.  
%
% Copyright ImagEval Consultants, LLC, 2003.

if checkfields(sensor,'data'),           sensor = sensorSet(sensor,'data',[]); end
if checkfields(sensor,'offsetFPNimage'), sensor = sensorSet(sensor,'offsetFPNimage',[]); end
if checkfields(sensor,'gainFPNimage'),   sensor = sensorSet(sensor,'gainFPNimage',[]); end
if checkfields(sensor,'colOffset'),      sensor = sensorSet(sensor,'coloffsetfpnvector',[]); end
if checkfields(sensor,'colGain'),        sensor = sensorSet(sensor,'colgainfpnvector',[]); end

return;