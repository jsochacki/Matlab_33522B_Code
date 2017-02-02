function [cell_array]=Global_Types()

cell_array={}; i=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define Global Types And Casts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global L_TRUE; L_TRUE=logical(true);
cell_array{i}={'global L_TRUE;'}; i=i+1;
global L_FALSE; L_FALSE=logical(false);
cell_array{i}={'global L_FALSE;'}; i=i+1;
global ENABLED; ENABLED=double(1.0);
cell_array{i}={'global ENABLED;'}; i=i+1;
global DISABLED; DISABLED=double(0.0);
cell_array{i}={'global DISABLED;'}; i=i+1;

end