function nativeScene = PBRTRemodellerStaggered3D(parentScene,nativeScene,mappings,names,conditionValues,conditionNumber)

% The function is called by the batch renderer when needed.  Various
% parameters are passed in, like the mexximp scene, the native scene, and
% names and values read from the conditions file.

%% Get condition values

pixelSamples = rtbGetNamedNumericValue(names, conditionValues, 'pixelSamples', []);
waterDepth = rtbGetNamedNumericValue(names, conditionValues, 'waterDepth', []);
cameraPosition = rtbGetNamedNumericValue(names, conditionValues, 'cameraPosition',[]);
volumeStepSize = rtbGetNamedNumericValue(names, conditionValues, 'volumeStepSize', []);

absorptionFile = rtbGetNamedValue(names, conditionValues, 'absorptionFiles', []);
scatteringFile = rtbGetNamedValue(names, conditionValues, 'scatteringFiles', []);
phaseFile = rtbGetNamedValue(names, conditionValues, 'phaseFiles', []);

%% Choose sampler.

% Change the number of samples
sampler = nativeScene.find('Sampler');
sampler.setParameter('pixelsamples', 'integer', pixelSamples);

%% Add water parameters

% integrator = nativeScene.find('SurfaceIntegrator');
% integrator.type = 'path';

% Add volume integrator
nativeScene.overall.find('SurfaceIntegrator','remove',true);
volumeIntegrator = MPbrtElement('VolumeIntegrator','type','single');
volumeIntegrator.setParameter('stepsize','float',volumeStepSize);
nativeScene.overall.append(volumeIntegrator);
        
% Add water volume
volume = MPbrtElement('Volume','type','water');
volume.setParameter('absorptionCurveFile','spectrum',fullfile('resources',absorptionFile));
volume.setParameter('scatteringCurveFile','spectrum',fullfile('resources',scatteringFile));
volume.setParameter('phaseFunctionFile','string',fullfile('resources',phaseFile));
volume.setParameter('p0','point',[-3000 -500 -1000]);
volume.setParameter('p1','point',[3000 5500 waterDepth]);
nativeScene.world.append(volume);

%% Choose a type of camera to render with

% Adjust the camera film distance (~FOV) so that the chart has always the
% same size in terms of camera pixels irrespective of the camera to chart
% distance.

filmHalfDiag = 10;
targetHalfDiag = 1.2*sqrt(4^2+6^2)*24/2;
cameraDistance = sqrt(sum((cameraPosition' - [0,5000,0]).^2));
filmDistance = filmHalfDiag*cameraDistance/targetHalfDiag;

camera =  nativeScene.find('Camera');
camera.type = 'pinhole';
camera.setParameter('filmdiag', 'float', 2*filmHalfDiag);
camera.setParameter('filmdistance', 'float', filmDistance);

%% Change light spectra

distantLight = nativeScene.world.find('LightSource','name','1_SunLight');
distantLight.setParameter('L','spectrum','resources/DistantLight.spd');
distantLight.setParameter('from','point',[0 0 20000]);
distantLight.setParameter('to','point',[0 2000 0]);

pointLight1 = nativeScene.world.find('LightSource','name','PointLight1');
pointLight1.setParameter('I','spectrum','resources/PointLight.spd');
pointLight1.setParameter('from','point',[1000 0 0]);

pointLight2 = nativeScene.world.find('LightSource','name','PointLight2');
pointLight2.setParameter('I','spectrum','resources/PointLight.spd');
pointLight2.setParameter('from','point',[-1500 0 0]);

% Remove extra lights
%nativeScene.world.find('LightSource','name','3_SunLight','remove',true);


%% Attach spectra to the cubes

for xx=1:6
    for yy=1:4
      
        id = (6-xx)*4 + (4-yy)+1;
        
        currPatch = nativeScene.world.find('MakeNamedMaterial','name',sprintf('Patch%i%i',yy-1,xx-1));
        currPatch.setParameter('Ks','rgb',[0 0 0]);
        currPatch.setParameter('Kd','spectrum',sprintf('mccBabel-%i.spd',id));
        
    end
end

end