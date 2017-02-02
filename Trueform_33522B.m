function [handle]=Trueform_33622A()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Device Declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%DECLARATION: START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%DECLARATION: HWID ADDRESSES AND WRAPPED DRIVERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%DECLARATION: HWID ADDRESSES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Trueform_33522B_USB_HWID='USB0::2391::11271::MY52811157::0::INSTR';
%Trueform_33522B_USB_HWID='USB0::2391::11271::MY52814249::0::INSTR';
Trueform_33522B_USB_HWID='TCPIP0::192.168.77.208::INSTR';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%DECLARATION: IVI-COM WRAPPED DRIVERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Trueform_33522B_IVI_COM_WRAPPED_DRIVER='Ag33522B_IVICOM_Driver';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%DECLARATION: IVI-C WRAPPED DRIVERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Trueform_33522B_IVI_C_WRAPPED_DRIVER='Ag33522B_IVIC_Driver';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%DECLARATION: END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


handle=struct('HardwareId',...
                struct('USB',Trueform_33522B_USB_HWID),...
              'Drivers',...
                struct('IAg3352x4',instrument.driver.Ag3352x(),...
                       'IVI_COM_Matlab_Wrapped',Trueform_33522B_IVI_COM_WRAPPED_DRIVER,...
                       'IVI_C_Matlab_Wrapped',Trueform_33522B_IVI_C_WRAPPED_DRIVER),...
              'Global',...
                struct('Enumerations',eval('@() Global_Enums_For_Trueform_33522B()'),...
                       'Types',eval('@() Global_Types()'),...
                       'Casts',eval('@() Global_Casts()')));
                   
end