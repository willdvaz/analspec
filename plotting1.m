function plotting1(signal, frequence, type_noise , estimate_type, window_type)



%----------------AJOUT DE BRUIT-------------
switch type_noise
    case 'noNoise'
        signal = signal;
    case 'weak_white_noise'
        signal = awgn(signal,30);

    case 'strong_white_noise'
        signal = awgn(signal,20);

    case 'weak_pink_noise'
        signal = signal + pinknoise(length(signal))';

    case 'strong_pink_noise'
        signal = signal + 3*pinknoise(length(signal))';

end
%----------------------

% Taille du signal
signal_size = size(signal);
signal_length = signal_size(1, 1);

% Affichage des informations du signal
fprintf('Signal de taille %d et de fr�quence %d Hz.\n', signal_length, frequence);

%taille de la fen�tre
T = 40; % en ms

% Nombre d'elements
points_by_sample = frequence * T / 1000;

% Affichage des informations de sampling
fprintf('En utilisant des �chantillons de %d ms, on a %d points par �chantillon.\n', T, points_by_sample);

% Combien d'�chantillons donc ? TODO : et les r�sidus ?
nb_samples = floor(signal_length / points_by_sample);
fprintf('Ce qui revient � %d �chantillons.\n', nb_samples);

% Cr�ation des �chantillons
samples = zeros(nb_samples, points_by_sample);
samples_times = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    samples(i, :) = signal((i - 1) * points_by_sample + 1: i * points_by_sample);
    samples_times(i, :) = [(i - 1) * points_by_sample + 1: i * points_by_sample];
end
 
% m�thode alternative: fen�trage et lissage des �chantillons


switch window_type
    case 'blackman'
window = blackman(points_by_sample); %%%ici tu r�gels la fen�tre
    case 'hamming'
        window = hamming(points_by_sample); %%%ici tu r�gels la fen�tre
    case 'hanning'
        window = hanning(points_by_sample); %%%ici tu r�gels la fen�tre
    case 'bartlett'
        window = bartlett(points_by_sample); %%%ici tu r�gels la fen�tre
end
for i = 1:nb_samples
    samples(i, :) = samples(i, :) .* window';
end 
 

switch estimate_type
    case 'fft'

% -------------------------- FFT -------------------------
% FFT des �chantillons
ffts = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    ffts(i, :) = abs(fft(samples(i, :)));
end
fft_axis = (1:(points_by_sample / 2));
fft_frequencies = frequence / 2 * linspace(0, 1, points_by_sample / 2);

%taking only the positive frequencies of the fft
ffts = ffts(:, 1:points_by_sample / 2);

% Plotting
figure
mesh(log(ffts)) % ecrit par will:j'ai rajout� le log ici, je ne sais pas si tu l'avais enlev� ou mis � un autre endroit ? 
figure
imagesc(log(ffts)); % ecrit par will:j'ai rajout� le log ici, je ne sais pas si tu l'avais enlev� ou mis � un autre endroit ?
rotate3d on

% le vecteur des fr�quences est fft_frequencies
%pour plotter juste pour un �chantillon, faire
%plot(fft_frequencies,ffts(100, :)/trapz(fft_frequencies,ffts(100, :))), (on normalise par l'aire) par exemple pour le 100� �chantillon




%-------------------------------WITH LEVINSONDURBIN------------------------------------------
    case 'levinson'
pp = 100;
for i = 1:nb_samples
[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin (samples(i, :), pp, frequence);
if i == 1
    levinson = zeros(nb_samples, length(find(ff>0)));
end
levinson(i, :) = mydsp(find(ff>0));
% keep only the positive frequencies
levinson_frequencies  = ff(find(ff>0));    
end
% Plotting
% figure
% mesh(log(levinson))
% figure
imagesc(log(levinson));
title(strcat('DSP par Levinson, ', window_type, ', ',type_noise))
% xaxis('Frequency')
% yaxis('Sample')
% axis( [0 frequence/2 1 length(levinson(:,1))])
rotate3d on

% le vecteur des fr�quences est levinson_frequencies
%pour plotter juste pour un �chantillon, faire
%plot(levinson_frequencies,levinson(100, :)/trapz(levinson_frequencies,levinson(100, :))), (on normalise par l'aire) par exemple pour le 100� �chantillon
%pour plotter sur le m�me plan qu'un autre faire subplot et bien garder les
%vecteurs XXX_frequencies en abscisse de chaque plot

%--------------------------WITH PERIODOGRAM---------------------------------------------
    case 'periodogram'
% FFT des �chantillons
perio = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    perio(i, :) = abs(fft(samples(i, :))).^2;
end
perio_axis = (1:(points_by_sample / 2));
perio_frequencies = frequence / 2 * linspace(0, 1, points_by_sample / 2);

% Plotting
figure
mesh(log(ffts(:, 1:points_by_sample / 2))) % ecrit par will:j'ai rajout� le log ici, je ne sais pas si tu l'avais enlev� ou mis � un autre endroit ? 
figure
imagesc(log(ffts(:, 1:points_by_sample / 2))); % ecrit par will:j'ai rajout� le log ici, je ne sais pas si tu l'avais enlev� ou mis � un autre endroit ?
rotate3d on



%----------------------WITH BURG---------------------


 case 'burg'
pp = 100;
for i = 1:nb_samples
[aa, sigma2, ref, ff, mydsp] = myburg(samples(i, :), pp, frequence);
if i == 1
    burg = zeros(nb_samples, length(find(ff>0)));
end
burg(i, :) = mydsp(find(ff>0));
% keep only the positive frequencies
burg_frequencies  = ff(find(ff>0));    
end
% Plotting
% figure
% mesh(log(burg))
% figure
figure('units','normalized','outerposition',[0 0 1 1])
imagesc(log(burg));
title(strcat('DSP par burg, ', window_type, ', ',type_noise))
% xaxis('Frequency')
% yaxis('Sample')
% axis( [0 frequence/2 1 length(burg(:,1))])
rotate3d on

% le vecteur des fr�quences est burg_frequencies
%pour plotter juste pour un �chantillon, faire
%plot(burg_frequencies,burg(100, :)/trapz(burg_frequencies,burg(100, :))), (on normalise par l'aire) par exemple pour le 100� �chantillon
%pour plotter sur le m�me plan qu'un autre faire subplot et bien garder les
%vecteurs XXX_frequencies en abscisse de chaque plot







%-----------------------------------------------------













end








