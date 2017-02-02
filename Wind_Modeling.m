%W. Gawronski Wind Model Paper
clear all

%WIND INFORMATION
mean_wind_velocity=15; %This is in whatevers per second

%GEOGRAPHICAL / INSTALLATION INFORMATION
%just go with meters if you can
height_from_ground_to_antenna_dish_center=2; %This must be in the same units as average_terrain_roughness_height
average_terrain_roughness_height=0.05; %This must be in the same units as height_from_ground_to_antenna_dish_center

%DAVENPORT SPECTRUM ANONAMOUS HANDLE
davenport_spectrum=@(f,mean_wind_velocity,terrain_based_surface_drag_coefficient,beta) 4800*mean_wind_velocity*terrain_based_surface_drag_coefficient*...
    ((beta*2*pi.*f)./(power(1+(power(beta,2)*power(2*pi.*f,2)),4/3)));

%DERIVED CONSTATNS
beta=(600)/(pi*mean_wind_velocity);
terrain_based_surface_drag_coefficient=1/power(2.5*log(height_from_ground_to_antenna_dish_center/average_terrain_roughness_height),2);

%%USE THESE SETTINGS IN ORDER TO REPLICATE FIGURE 2 FROM THE PAPER
% mean_wind_velocity=16; beta=(600)/(pi*mean_wind_velocity);
% height_from_ground_to_antenna_dish_center=17; average_terrain_roughness_height=0.1;
% terrain_based_surface_drag_coefficient=1/power(2.5*log(height_from_ground_to_antenna_dish_center/average_terrain_roughness_height),2);
% 
% loglog((sqrt(davenport_spectrum(0.0001:0.0001:10,mean_wind_velocity,terrain_based_surface_drag_coefficient,beta))))

