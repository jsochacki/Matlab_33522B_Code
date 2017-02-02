function obj=Setup_Local(obj)
  
    %Define Static Parameters
    obj.AWG.Parameters.Set.TIMEOUT=15e3; %In milliseconds
    %Define Dynamic Parameters
    %Arbitrary Waveform Generator
    obj.AWG.Parameters.Set.SAMPLE_RATE=double(1e3); %250Msps Maximum
    obj.AWG.Parameters.Set.CHANNEL_1_PEAK_TO_PEAK_VOLTAGE=double(1); %10 Volts Maximum
    obj.AWG.Parameters.Set.CHANNEL_2_PEAK_TO_PEAK_VOLTAGE=double(1); %10 Volts Maximum
    obj.AWG.Parameters.Set.CHANNEL_1_DC_OFFSET=double(0); 
    obj.AWG.Parameters.Set.CHANNEL_2_DC_OFFSET=double(0); 
    obj.AWG.Parameters.Set.CHANNEL_1_PHASE_OFFSET=int32(0); 
    obj.AWG.Parameters.Set.CHANNEL_2_PHASE_OFFSET=int32(0);
    obj.AWG.Parameters.Set.CHANNEL_1_PHASE_OFFSET_MAX=int32(0); 
    obj.AWG.Parameters.Set.CHANNEL_1_PHASE_OFFSET_MIN=int32(0); 
    obj.AWG.Parameters.Set.CHANNEL_2_PHASE_OFFSET_MAX=int32(0); 
    obj.AWG.Parameters.Set.CHANNEL_2_PHASE_OFFSET_MIN=int32(0);
    
    obj.AWG.Parameters.Read.SAMPLE_RATE=[]; %250Msps Maximum
    obj.AWG.Parameters.Read.CHANNEL_1_PEAK_TO_PEAK_VOLTAGE=[]; %10 Volts Maximum
    obj.AWG.Parameters.Read.CHANNEL_2_PEAK_TO_PEAK_VOLTAGE=[]; %10 Volts Maximum
    obj.AWG.Parameters.Read.CHANNEL_1_DC_OFFSET=[]; 
    obj.AWG.Parameters.Read.CHANNEL_2_DC_OFFSET=[]; 
    obj.AWG.Parameters.Read.CHANNEL_1_PHASE_OFFSET=[]; 
    obj.AWG.Parameters.Read.CHANNEL_2_PHASE_OFFSET=[];
    obj.AWG.Parameters.Read.CHANNEL_1_PHASE_OFFSET_MAX=[]; 
    obj.AWG.Parameters.Read.CHANNEL_1_PHASE_OFFSET_MIN=[]; 
    obj.AWG.Parameters.Read.CHANNEL_2_PHASE_OFFSET_MAX=[]; 
    obj.AWG.Parameters.Read.CHANNEL_2_PHASE_OFFSET_MIN=[];
    %Input
    obj.Input.Parameters.ZO=50;
    obj.Input.Waveforms.Channel1.Name='Channel1';
    obj.Input.Waveforms.Channel2.Name='Channel2';
    obj.Input.Waveforms.Channel1.Data=[];
    obj.Input.Waveforms.Channel2.Data=[];
      
    %Declare Methods
    obj.Output.Measurements.Channel.WriteWaveformOnChannel=@WaveformWrite;
    obj.Output.Measurements.Channel.WriteDTFTPOnChannel=@DTFTPWrite;
    obj.Output.Measurements.Channel.WriteTimestepOnChannel=@TimestepWrite;
    
    %Define Globals
    cell_array={}; i=1;
    global VRANGE_PTP; VRANGE_PTP = double(1.0);
    cell_array{i}={'global VRANGE_PTP;'}; i=i+1;
    obj.Oscilloscope.Parameters.Global=cell_array;
    
    cell_array={}; i=1;
    global AWGG; AWGG = double(1.0);
    cell_array{i}={'global AWGG;'}; i=i+1;
    obj.AWG.Parameters.Global=cell_array;
    
    cell_array={}; i=1;
    global IG; IG = double(1.0);
    cell_array{i}={'global IG;'}; i=i+1;
    obj.Input.Parameters.Global=cell_array;
    
    cell_array={}; i=1;
    global OG; OG = double(1.0);
    cell_array{i}={'global OG;'}; i=i+1;
    obj.Output.Parameters.Global=cell_array;
    
    %Define Handles
    obj.Setup.Parameters.DeclareAllGlobals=@DeclareGlobals;
    
    %Define Functions For Methods
    function DeclareGlobals()
        useage_error='Useage Error.'',''Dont Pass or Assign, Just Call';
        switch nargin
            case 0
                for i=1:1:length(obj.AWG.Parameters.Global), evalin('caller',obj.AWG.Parameters.Global{i}{1});,end;
                for i=1:1:length(obj.Input.Parameters.Global), evalin('caller',obj.Input.Parameters.Global{i}{1});,end;
            otherwise
                sprintf('%s',useage_error)
        end
    end

end