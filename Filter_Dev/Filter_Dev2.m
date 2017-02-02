clear all
LOWEST_FREQUENCY=1; %In Hz
OSAMPR=2;
SET_OUTPUT_SAMPLE_RATE=1000; %In Sp/s
DB_PER_DECADE=60;
CORNER_FREQUENCY=1; %In Hz
FILTER_LENGTH=OSAMPR*SET_OUTPUT_SAMPLE_RATE/LOWEST_FREQUENCY; %Minimum Filter Length Required To Represnet Desired Filter
%Since the AWG has a 16 bit resolution then so shall the noise
white_noise=randsrc(1,FILTER_LENGTH,linspace(-1,1,(2^15)-1));
nf=10*log10(abs(fftshift(fft(white_noise,(length(white_noise))))));
figure(1)
semilogx(nf((length(nf)/2):1:end),'b-')
grid on

DELTA=10*log10(linspace((CORNER_FREQUENCY/LOWEST_FREQUENCY),(FILTER_LENGTH/2),(FILTER_LENGTH/2)-(CORNER_FREQUENCY/LOWEST_FREQUENCY))/(CORNER_FREQUENCY/LOWEST_FREQUENCY));
Low_Pass_Filter=[ones(1,(CORNER_FREQUENCY/LOWEST_FREQUENCY)) power(10,((-DB_PER_DECADE*DELTA)/10)/10)];

h=fftshift(ifft([Low_Pass_Filter fliplr(Low_Pass_Filter)],(FILTER_LENGTH),'symmetric'));
a=10*log10(abs(fftshift(fft(h,(FILTER_LENGTH)))));
figure(2)
semilogx(a((length(a)/2):1:end),'b-')
grid on

white_noise_chunk=[fliplr(white_noise) white_noise fliplr(white_noise)];
Filtered_Noise=conv(h,white_noise_chunk);
Filtered_and_Chopped_Noise=Filtered_Noise((length(white_noise)+1):1:((2*length(white_noise))+1));
a=10*log10(abs(fftshift(fft(Filtered_and_Chopped_Noise,(FILTER_LENGTH)))));
figure(3)
semilogx(a((length(a)/2):1:end),'b-')
grid on
