function [obj]=Create_AWG(obj_in)
    
    %Define Dynamic Parameters (Will Change With Change In Instrument)
    obj_internal.Setup.Driver=obj_in.Drivers.IAg3352x4;

    %Define Static Parameters
    obj.Setup.HardwareId.USB=obj_in.HardwareId.USB;
    obj.Setup.Definitions.Global.DeviceSpecific.Enumerations=obj_in.Global.Enumerations();
    obj.Setup.Definitions.Global.Generic.Types=obj_in.Global.Types();
    
    obj.Setup.InitializationOptions.Reset.NoReset=logical(false);
    obj.Setup.InitializationOptions.Reset.FullReset=logical(true);
    obj.Setup.InitializationOptions.Id.DontQuery=logical(false);
    obj.Setup.InitializationOptions.Id.Query=logical(true);
    obj.Setup.InitializationOptions.OpperationMode.Test='simulate=false';
    obj.Setup.InitializationOptions.OpperationMode.Simulation='simulate=true';
    obj.Setup.OpperationMode.RunInTest='simulate=false';
    
    %Define Objects With Methods and Parameters
    obj.Opperation=obj_internal.Setup.Driver.DeviceSpecific;
    
    clear obj_internal;
    
    %Define Methods
    obj.Setup.Declarations.Global=@DeclareGlobal;
    obj.Setup.Initialization.CheckStatus=@CheckInitializationStatus;
    obj.Setup.Initialization.Initialize=@InitializeLink;
    obj.Setup.AddChannels=@AddChannels;
    obj.Output.SetUpOutput=@SetUpCommonOutput;
    obj.OutputFunction.SetUpOutputFunction=@SetUpCommonOutputFunction;
    obj.OutputFunction.UpdateWaveform=@UpdateWaveform;
    obj.DisplayLocal=@DisplayLocalAWGValues;
    obj.UpdateLocal=@UpdateLocalAWGValues;
    obj.Wait=@WaitForOpperationToCompleteOrTimeout;
    
    %Define Functions For Methods
    function DeclareGlobal(varargin)
        useage_error='Useage Error.'',''Please Call either "Enumerations" or "Types"';
        switch nargin
            case 0
                sprintf('%s',useage_error)
            case 1
                if strcmp(varargin{1},'Enumerations')
                    for i=1:1:length(obj.Setup.Definitions.Global.DeviceSpecific.Enumerations), evalin('caller',obj.Setup.Definitions.Global.DeviceSpecific.Enumerations{i}{1});,end;
                elseif strcmp(varargin{1},'Types')
                    for i=1:1:length(obj.Setup.Definitions.Global.Generic.Types), evalin('caller',obj.Setup.Definitions.Global.Generic.Types{i}{1});,end;
                else
                    sprintf('%s',useage_error)
                end
            otherwise
                sprintf('%s',useage_error)
        end
    end

    function CheckInitializationStatus(varargin)
        useage_error='Useage Error.'',''Sorry';
        switch nargin
            case 0
                if obj.Opperation.Initialized
                    sprintf('%s','Initialization Was Successful.')
                else
                    sprintf('%s','Initialization Failed.')
                end
            otherwise
                sprintf('%s',useage_error)
        end
    end

    function obj=InitializeLink(obj,HwId,QueryId,Reset,Mode)
        useage_error='Useage Error.'',''obj=InitializeLink(obj,HwId,QueryId,Reset,Mode) eg obj=InitializeLink(obj,obj.Setup.HardwareId.USB,obj.Setup.InitializationOptions.Id.Query,scope_1.Setup.InitializationOptions.Reset.FullReset,obj.Setup.InitializationOptions.OpperationMode.Simulation';
        switch nargin
            case 5
                if strcmp(Mode,obj.Setup.InitializationOptions.OpperationMode.Test)
                        obj.Opperation.Initialize(HwId,QueryId,Reset,Mode);
                        obj.Setup.OpperationMode=Mode;
                elseif strcmp(Mode,obj.Setup.InitializationOptions.OpperationMode.Simulation)
                        obj.Opperation.Initialize(HwId,QueryId,Reset,Mode);
                        obj.Setup.OpperationMode=Mode;
                else
                    sprintf('%s',useage_error)                    
                end
            otherwise
                sprintf('%s',useage_error)
        end
    end

    function obj=AddChannels(obj)
        useage_error='Useage Error.'',''Pass In Object Please and Assign On Output eg obj=AddChannels(obj)';
        switch nargin
            case 0
                sprintf('%s',useage_error)
            case 1
                if obj.Opperation.Initialized
                    if strcmp(obj.Setup.OpperationMode,obj.Setup.InitializationOptions.OpperationMode.Test)
                        obj.Channels.Channel1=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(1));
                        obj.AdvancedChannels.Channel1=obj.Opperation.Channels2.Item2(obj.Opperation.Channels2.Name(1));
                        obj.Channels.Channel2=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(2));
                        obj.AdvancedChannels.Channel2=obj.Opperation.Channels2.Item2(obj.Opperation.Channels2.Name(2));
                    elseif strcmp(obj.Setup.OpperationMode,obj.Setup.InitializationOptions.OpperationMode.Simulation)
                        obj.Channels.Channel1=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(1));
                        obj.AdvancedChannels.Channel1=obj.Opperation.Channels2.Item2(obj.Opperation.Channels2.Name(1));
                    end
                else
                    sprintf('%s','Initialization Must Be Completed First')
                end
            otherwise
                sprintf('%s',useage_error)
        end
    end

    function SetUpCommonOutput(obj,Channel_Number,Local,Sync_Channel)
       useage_error='Useage Error.'',''Pass In Object Channel Pointer, Channel Number, Local, and Sync Channel Please eg. obj.Output.SetUpOutput(obj,Channel_Number,Local,Sync_Channel)';
       switch nargin
            case 4
                global ENABLED DISABLED ATOMN ATOPN ATOFM_CW ATOSM_N ATOSP_N ATOSS_CH1 ATOSS_CH1 ATOVU_VPP
                switch Channel_Number
                    case 1
                        obj=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(1));
                    case 2
                        obj=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(2));
                    otherwise
                        sprintf('%s',useage_error)
                end
                obj.Output.Enabled=DISABLED;

                obj.Output.Load=Local.Input.Parameters.ZO;
                obj.Output.Mode=ATOMN;
                obj.Output.Polarity=ATOPN;
                obj.Output.FrequencyMode=ATOFM_CW;
                obj.Output.Sync.Enabled=ENABLED;
                obj.Output.Sync.Mode=ATOSM_N;
                obj.Output.Sync.Polarity=ATOSP_N;
                
                obj.Output.Voltage.Units=ATOVU_VPP;
                obj.Output.Voltage.Offset.DCOffset=Local.AWG.Parameters.Set.CHANNEL_1_DC_OFFSET;
                obj.Output.Voltage.Amplitude=obj.Output.Voltage.AmplitudeMax;
                
                switch Sync_Channel
                    case 1
                        obj.Output.Sync.Source=ATOSS_CH1;
                    case 2
                        obj.Output.Sync.Source=ATOSS_CH2;
                    otherwise
                        sprintf('%s',useage_error)
                end                

            otherwise
                sprintf('%s',useage_error)
        end
    end

    function SetUpCommonOutputFunction(obj,Channel_Number,Local)
       useage_error='Useage Error.'',''Pass In Object Channel Pointer, Channel Number, and Local Please eg. obj.OutputFunction.SetUpOutputFunction(obj,Channel_Number,Local)';
       switch nargin
            case 3
                global ENABLED DISABLED ATOF_A ATOFAWI_D ATOFAWACS_T ATOFAWSCM_R
                switch Channel_Number
                    case 1
                        obj=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(1));
                    case 2
                        obj=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(2));
                    otherwise
                        sprintf('%s',useage_error)
                end
                obj.OutputFunction.Function=ATOF_A;

                obj.OutputFunction.ArbitraryWaveform.InterpolationEnabled=ATOFAWI_D;
                %obj.OutputFunction.ArbitraryWaveform.AdvanceClockSource=ATOFAWACS_T;
                %obj.OutputFunction.ArbitraryWaveform.SRate.Coupling.Mode=ATOFAWSCM_R;
                obj.OutputFunction.ArbitraryWaveform.SRate.Coupling.Ratio=1;          

            otherwise
                sprintf('%s',useage_error)
        end
    end

    function error_msg=UpdateWaveform(obj,Channel_Number,Local)
       useage_error='Useage Error.'',''Pass In Object Channel Pointer, Channel Number, and Local Please eg. error_msg=obj.Output.SetUpOutput(obj,Channel_Number,Local)';
       switch nargin
            case 3               
                global ENABLED DISABLED
                baseobj=obj;
                switch Channel_Number
                    case 1
                        obj=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(1));
                        waveform_data=Local.Input.Waveforms.Channel1.Data;
                        waveform_name=Local.Input.Waveforms.Channel1.Name;
                    case 2
                        obj=obj.Opperation.Channels.Item(obj.Opperation.Channels.Name(2));
                        waveform_data=Local.Input.Waveforms.Channel2.Data;
                        waveform_name=Local.Input.Waveforms.Channel2.Name;
                    otherwise
                        sprintf('%s',useage_error)
                end
                obj.Output.Enabled=DISABLED;
                
                obj.OutputFunction.ArbitraryWaveform.Clear();
                obj.OutputFunction.ArbitraryWaveform.LoadArbWaveform(waveform_name,waveform_data);
                baseobj.Opperation.System.WaitForOperationComplete(Local.AWG.Parameters.Set.TIMEOUT);
                obj.OutputFunction.ArbitraryWaveform.SelectArbWaveform(waveform_name);
                obj.Output.Enabled=ENABLED;        
                [error_number error_msg]=baseobj.Opperation.Utility.ErrorQuery;
                switch Channel_Number
                    case 1
                        obj.Apply.SetArbWaveform(Local.AWG.Parameters.Set.SAMPLE_RATE,Local.AWG.Parameters.Set.CHANNEL_1_PEAK_TO_PEAK_VOLTAGE,Local.AWG.Parameters.Set.CHANNEL_1_DC_OFFSET);
                        baseobj.AdvancedChannels.Channel1.OutputFunction2.ArbitraryWaveform2.SynchronizeArbs;
                    case 2
                        obj.Apply.SetArbWaveform(Local.AWG.Parameters.Set.SAMPLE_RATE,Local.AWG.Parameters.Set.CHANNEL_2_PEAK_TO_PEAK_VOLTAGE,Local.AWG.Parameters.Set.CHANNEL_2_DC_OFFSET);
                        baseobj.AdvancedChannels.Channel2.OutputFunction2.ArbitraryWaveform2.SynchronizeArbs;
                    otherwise
                        sprintf('%s',useage_error)
                end                              
            otherwise
                sprintf('%s',useage_error)
        end
    end

    function DisplayLocalAWGValues(Local)
       useage_error='Useage Error.'',''obj.DisplayLocal(Local)';
       switch nargin
            case 1
                name_list=fieldnames(Local.AWG.Parameters.Set);
%                 updateible_names_list={'SAMPLE_RATE'...
%                     ;'CHANNEL_1_PEAK_TO_PEAK_VOLTAGE';'CHANNEL_2_PEAK_TO_PEAK_VOLTAGE'...
%                     ;'CHANNEL_1_DC_OFFSET';'CHANNEL_2_DC_OFFSET'...
%                     ;'CHANNEL_1_PHASE_OFFSET';'CHANNEL_2_PHASE_OFFSET'...
%                     ;'CHANNEL_1_PHASE_OFFSET_MAX';'CHANNEL_2_PHASE_OFFSET_MAX'...
%                     ;'CHANNEL_1_PHASE_OFFSET_MIN';'CHANNEL_2_PHASE_OFFSET_MIN'};
                fprintf(1,'Set Values \n');
                for i=1:1:length(name_list)
%                    if sum(strcmp(updateible_names_list(:),name_list(i)))
                        [temp_name]=sprintf('%s%s','Local.AWG.Parameters.Set.',name_list{i});
                        %sprintf('%s\n','Local.AWG.Parameters.Set.',name_list{i})
                        [temp_val]=eval(sprintf('%s%s','Local.AWG.Parameters.Set.',name_list{i}));
                        fprintf(1,'%s = %5.5e \n',temp_name,temp_val);
%                    end
                end
                fprintf(1,'Read Values \n');
                name_list=fieldnames(Local.AWG.Parameters.Read);
                for i=1:1:length(name_list)
%                    if sum(strcmp(updateible_names_list(:),name_list(i)))
                        [temp_name]=sprintf('%s%s','Local.AWG.Parameters.Read.',name_list{i});
                        %sprintf('%s\n','Local.AWG.Parameters.Set.',name_list{i})
                        [temp_val]=eval(sprintf('%s%s','Local.AWG.Parameters.Read.',name_list{i}));
                        fprintf(1,'%s = %5.5e \n',temp_name,temp_val);
%                    end
                end
            otherwise
                sprintf('%s',useage_error)
        end
    end

    function Local=UpdateLocalAWGValues(obj,Local)
       useage_error='Useage Error.'',''Pass In Object Pointer and Local Please eg. Local=obj.UpdateLocalAWGValues(obj,Local)';
       switch nargin
            case 2
                %Incorporate sample rate so you can monitor and set
                Local.AWG.Parameters.Read.SAMPLE_RATE=obj.Channels.Channel1.OutputFunction.ArbitraryWaveform.SRate.SampleRate;
                Local.AWG.Parameters.Read.CHANNEL_1_PEAK_TO_PEAK_VOLTAGE=obj.Channels.Channel1.Output.Voltage.Amplitude;
                Local.AWG.Parameters.Read.CHANNEL_2_PEAK_TO_PEAK_VOLTAGE=obj.Channels.Channel2.Output.Voltage.Amplitude;
                Local.AWG.Parameters.Read.CHANNEL_1_PEAK_TO_PEAK_VOLTAGE_MAX=obj.Channels.Channel1.Output.Voltage.AmplitudeMax;
                Local.AWG.Parameters.Read.CHANNEL_2_PEAK_TO_PEAK_VOLTAGE_MAX=obj.Channels.Channel2.Output.Voltage.AmplitudeMax;
                Local.AWG.Parameters.Read.CHANNEL_1_DC_OFFSET=obj.Channels.Channel1.Output.Voltage.Offset.DCOffset;
                Local.AWG.Parameters.Read.CHANNEL_2_DC_OFFSET=obj.Channels.Channel2.Output.Voltage.Offset.DCOffset;
            otherwise
                sprintf('%s',useage_error)
        end
    end

    function WaitForOpperationToCompleteOrTimeout(baseobj,Local)
       useage_error='Useage Error.'',''eg. WaitForOpperationToCompleteOrTimeout(obj,Local)';
       switch nargin
            case 2
                baseobj.Opperation.System.WaitForOperationComplete(Local.AWG.Parameters.Set.TIMEOUT);
            otherwise
                sprintf('%s',useage_error)
        end
    end

end