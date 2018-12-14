% file: atan_compare.m
% Author: John Niemynski 
% Descr: script to compare 
% the atan2 function native in matlab
% to the atan_approx function 

%define input range to be x,y from unit circle
%x = 
%y = 

%clear current working matlab environment
clear;
close all;
clc;

%figure;
%hold on
th = double(-pi:pi/1000:pi);
r=1;
xunit = r * cos(th);
yunit = r * sin(th);
xfxpt = fi(xunit,1,16,13);
yfxpt = fi(yunit,1,16,13);
%plot(xunit, yunit)
%hold off
figure;
plot(atan2(yunit,xunit).*180/pi)
title("Plot of atan vs gcoridcatan");
hold on
%generate bit accurate lut model
luts = cordiclut_generation(11, true, 16);
%11 luts long, fixed point, 12 bits
fileIDina = fopen('atanInaData.txt','w');
fileIDinb = fopen('atanInbData.txt','w');
fileIDout = fopen('atanOutputData.txt','w');
for idx = 1:numel(xunit)
  fprintf(fileIDina, '%s\n', bin(xfxpt(idx)));
  fprintf(fileIDinb, '%s\n', bin(yfxpt(idx)));
  result(idx) = gcordicatan2(yunit(idx),xunit(idx), luts);
  resultfxpt = fi(result(idx),1,16,13);
  fprintf(fileIDout,'%s\n',bin(resultfxpt));
end
fclose(fileIDina);
fclose(fileIDinb);
fclose(fileIDout);
plot(result*180/pi)
hold off
figure;
plot(abs(atan2(yunit,xunit)*180/pi)-abs(result).*180/pi)
title("Plot of error of gcordicatan to atan in degrees");