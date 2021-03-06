clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Important Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Functionality
%%%  For a full list of the supported methods, properties, ect..
%%%  look at the help file
%%%  in the driver directory it's self as all listed are applicable in
%%%  the appropriate driver section and their use is spelled out.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Device Instantiations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%INSTANTIATION: START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

awg_1=Create_AWG(Trueform_33522B());

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%INSTANTIATION: END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Device Initialize, Verify, and Reset -Full Factory Reset For Consistent Opperation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%INITIALIZE_VERIFY_RESET: START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

awg_1=awg_1.Setup.Initialization.Initialize(awg_1,awg_1.Setup.HardwareId.USB,awg_1.Setup.InitializationOptions.Id.Query,awg_1.Setup.InitializationOptions.Reset.FullReset,awg_1.Setup.InitializationOptions.OpperationMode.Test)

awg_1.Setup.Initialization.CheckStatus()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add And Set Up Common Test Parameter Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Local=Setup_Local_AWG();
Local.Setup.Parameters.DeclareAllGlobals()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%INITIALIZE_VERIFY_RESET: END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Hardware Specific Notes
%%%  The Trueform_33522B has a maximum output sampling rate of 250Msps
%%%  @ 16 Bits reguardless of the number of channels used when in arbitrary
%%%  wave mode.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define Global Enums and Typecasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

awg_1.Setup.Declarations.Global('Enumerations');
awg_1.Setup.Declarations.Global('Types');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Up Channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%AWG Areas to method . all functionality is in channels.item pointer
awg_1.Opperation.Display.Text=sprintf('%s','Setting up AWG');

awg_1=awg_1.Setup.AddChannels(awg_1);

awg_1.Output.SetUpOutput(awg_1,1,Local,1);
awg_1.Wait(awg_1,Local);
awg_1.Output.SetUpOutput(awg_1,2,Local,1);
awg_1.Wait(awg_1,Local);

awg_1.OutputFunction.SetUpOutputFunction(awg_1,1,Local);
awg_1.Wait(awg_1,Local);
awg_1.OutputFunction.SetUpOutputFunction(awg_1,2,Local);
awg_1.Wait(awg_1,Local);

%Select the type of degradation
SELECTED_FILTER='Delay Degradation';

%Generate The ARB Signal
LOWEST_FREQUENCY=0.05; %In Hz
OSAMPR=2; FMAX=1000;
SET_OUTPUT_SAMPLE_RATE=OSAMPR*FMAX; %In Sp/s
DB_PER_DECADE=40;
SET_CORNER_FREQUENCY=1;
ADJUSTED_CORNER_FREQUENCY=SET_CORNER_FREQUENCY; %In Hz
FILTER_LENGTH=SET_OUTPUT_SAMPLE_RATE/LOWEST_FREQUENCY; %Minimum Filter Length Required To Represnet Desired Filter

if strcmp(SELECTED_FILTER,'Delay Degradation')
    %Since the AWG has a 16 bit resolution then so shall the noise
    white_noise=randsrc(1,FILTER_LENGTH,linspace(-1,1,(2^15)-1));
    nf=10*log10(abs(fftshift(fft(white_noise,(length(white_noise))))));

    DELTA=10*log10(linspace((ADJUSTED_CORNER_FREQUENCY/LOWEST_FREQUENCY),(FILTER_LENGTH/2),(FILTER_LENGTH/2)-(ADJUSTED_CORNER_FREQUENCY/LOWEST_FREQUENCY))/(ADJUSTED_CORNER_FREQUENCY/LOWEST_FREQUENCY));
    Low_Pass_Filter=[ones(1,(ADJUSTED_CORNER_FREQUENCY/LOWEST_FREQUENCY)) power(10,((-DB_PER_DECADE*DELTA)/20)/10)];

    h=fftshift(ifft([Low_Pass_Filter],(FILTER_LENGTH),'symmetric'));
elseif strcmp(SELECTED_FILTER,'Vibration Degradation')
    Vibration_Filter_Linearily_Interpolated=[];
    Vibration_Filter_Linearily_Interpolated(1,:)=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,200,300,400,500,600,700,800,900,1000];
    Vibration_Filter_Linearily_Interpolated(2,:)=[-5.553608628,-5.553608628,-5.553608628,-5.553608628,-5.553608628,-5.553608628,-5.553608628,-5.553608628,-5.553608628,-5.553608628,-8.550037303,-10.30713022,-7.667982415,-5.564390768,-3.855222555,-2.647920122,-1.661440076,-0.778800036,0,-2.984265122,-9.13791631,-13.51758618,-17.04678407,-20.02730192,-22.45587203,-24.55327349,-25.09094653,-25.54536711,-28.54454296,-30.30163588,-31.57401351,-32.51314938,-33.45228525,-34.39142112,-35.330557,-36.26969287,-37.20882874];

    Vibration_Filter=[];
    x_data=Vibration_Filter_Linearily_Interpolated(1,:); y_data=power(10,Vibration_Filter_Linearily_Interpolated(2,:)./20);
    desired_frequency_points=linspace(1,(FILTER_LENGTH/2),(FILTER_LENGTH/2))*(LOWEST_FREQUENCY);

    [Vibration_Filter]=Series_Interpolator(x_data,y_data,desired_frequency_points,'Logarithmic');
    h=fftshift(ifft([Vibration_Filter],(FILTER_LENGTH),'symmetric'));
end

white_noise_chunk=[fliplr(white_noise) white_noise fliplr(white_noise)];
Filtered_Noise=conv(h,white_noise_chunk);
Filtered_and_Chopped_Noise=Filtered_Noise((length(white_noise)+1):1:((2*length(white_noise))+1));
%%%%CONSIDER REMOVING THIS AS IT CAUSES ERRORS!!!!
%Filtered_and_Chopped_Noise=Filtered_and_Chopped_Noise-mean(Filtered_and_Chopped_Noise);
%%%%CONSIDER REMOVING THIS AS IT CAUSES ERRORS!!!!
Filtered_and_Chopped_Noise=Filtered_and_Chopped_Noise./max(abs(Filtered_and_Chopped_Noise));
a=20*log10(abs(fftshift(fft(Filtered_and_Chopped_Noise,(FILTER_LENGTH)))));
figure(3)
semilogx(a((length(a)/2):1:end),'b-')
grid on

%Set The Sample Rate For Update Upon New Waveform
Local.AWG.Parameters.Set.SAMPLE_RATE=double(SET_OUTPUT_SAMPLE_RATE);

Local.Input.Waveforms.Channel1.Data=Filtered_and_Chopped_Noise;
Local.Input.Waveforms.Channel2.Data=Filtered_and_Chopped_Noise;
awg_1.OutputFunction.UpdateWaveform(awg_1,1,Local)
awg_1.Channels.Channel1.Output.Voltage.Amplitude=2;%awg_1.Channels.Channel1.Output.Voltage.AmplitudeMax;
%Local.AWG.Parameters.Set.CHANNEL_1_PEAK_TO_PEAK_VOLTAGE;
%awg_1.OutputFunction.UpdateWaveform(awg_1,2,Local)
%awg_1.Channels.Channel2.Output.Voltage.Amplitude=awg_1.Channels.Channel1.Output.Voltage.Amplitude;

%Make sure The Sample Rate got set
Local=awg_1.UpdateLocal(awg_1,Local);
if Local.AWG.Parameters.Read.SAMPLE_RATE==SET_OUTPUT_SAMPLE_RATE
    disp('The Output Sample Rate Was Properly Set')
else
    disp('There Was An Error Setting The Output Sample Rate')
end

awg_1.Channels.Channel1.Output.Enabled=DISABLED;%ENABLED;
awg_1.Channels.Channel2.Output.Enabled=DISABLED;%ENABLED;
awg_1.Opperation.Display.Text=sprintf('%s','Running Test');
awg_1.Opperation.Display.TextClear();

awg_1.Opperation.Memory.CurrentDirectory='INT:\JS_OCXO_PN_ARBS'
if awg_1.Opperation.Memory.CurrentDirectory()=='INT:\JS_OCXO_PN_ARBS'
    disp('Directory is correct')
else
    disp('DIRECTORY ERROR!')
end

%For manipulating ARB remotly
% awg_1.Channels.Channel1.Output.Enabled=DISABLED;
% [a b Loaded_ARB_List]=awg_1.Opperation.Memory.GetCatalogDataFiles('INT:\JS_OCXO_PN_ARBS',1,1,{'',''})
% for n=1:1:length(Loaded_ARB_List)
% name_end=strfind(Loaded_ARB_List{n},',');
% Loaded_ARB_Name_List{n}=strtrim(Loaded_ARB_List{n}(1:1:(name_end-1)));
% end
% Load the ones you want
% awg_1.Channels.Channel1.OutputFunction.ArbitraryWaveform.OpenArbWaveform(Loaded_ARB_Name_List{end})
% Make sure you loaded what you meant to
% Catalog_List=awg_1.Channels.Channel1.OutputFunction.ArbitraryWaveform.GetCatalog()
% %%CLear current waveform if you are having issues
% %%awg_1.Channels.Channel1.OutputFunction.ArbitraryWaveform.Clear()
% Select from waveforms in volatile memory
% awg_1.Channels.Channel1.OutputFunction.ArbitraryWaveform.SelectArbWaveform(strcat('INT:\JS_OCXO_PN_ARBS\',Loaded_ARB_Name_List{end}))
% awg_1.Channels.Channel1.OutputFunction.ArbitraryWaveform.SelectArbWaveform(Catalog_List{2})
% CHeck for errors
% if ~awg_1.Opperation.Utility.ErrorQuery()
%     disp('Waveform Loaded Properly')
% else
%     disp('WAVEFORM LOAD ERROR!')
% end
% awg_1.Channels.Channel1.Output.Voltage.Amplitude=6.5;
% awg_1.Channels.Channel1.Output.Enabled=ENABLED;
% CHeck for errors
% if ~awg_1.Opperation.Utility.ErrorQuery()
%     disp('Settigns Applied')
% else
%     disp('Error applying settings!')
% end

%Store ARB For Later
awg_1.Channels.Channel1.OutputFunction.ArbitraryWaveform.StoreArbWaveform('INT:\JS_OCXO_PN_ARBS\2ksps_output_xHz_Fc_xxdB_dec.arb')
if ~awg_1.Opperation.Utility.ErrorQuery()
    disp('Waveform Loaded Properly')
else
    disp('WAVEFORM LOAD ERROR!')
end

%[a b c]=awg_1.Opperation.Memory.GetCatalogDataFiles('INT:\JS_OCXO_PN_ARBS',1,1,{'',''})
%awg_1.Opperation.Memory.UploadFile('INT:\JS_OCXO_PN_ARBS\2ksps_output_Worst_Case_Allowable_SAN_Vibe_V2.arb','C:\Users\jsochacki\Desktop\ARBS\2ksps_output_Worst_Case_Allowable_SAN_Vibe_V2.arb')
%awg_1.Opperation.Memory.RemoveFile('TEST2ksps_output_xHz_Fc_xxdB_dec.arb')

% destination_path='INT:\JS_OCXO_PN_ARBS\';
% source_path='C:\Users\jsochacki\Desktop\ARBS\';
% file_list=dir(source_path);
% for n=3:1:length(file_list) % 1 is . and 2 is ..
%     file_name=file_list(n).name;
%     awg_1.Opperation.Memory.DownloadFile(sprintf('%s%s',source_path,file_name),sprintf('%s%s',destination_path,file_name));
% end


%awg_1.Opperation.Memory.StoreState('1ksps_output.sta')
%awg_1.Opperation.Memory.LoadState('1ksps_output.sta')
awg_1.Opperation.Display.TextClear()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if awg_1.Opperation.Initialized
    awg_1.Opperation.Close();
    disp('awg_1 Closed');
end

clear awg_1

disp('Done');
disp(blanks(1)');