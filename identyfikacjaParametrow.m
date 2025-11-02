function [params_opt, q_min] = identyfikacjaParametrow(t_data, y_data_100, h_i, S_i)
% WEJŚCIA:
%   t_data:       Wektor czasów pomiaru (duration lub double)
%   y_data_100:   Wektor zmierzonych poziomów w procentach (0 do 100)
%   h_i:          Poziom początkowy w zbiorniku, x_i(0) [m]
%   S_i:          Stałe pole przekroju poprzecznego zbiornika [m^2]
%
% WYJŚCIA:
%   params_opt: Wektor 1x2 z optymalnymi parametrami [c_i, alpha_i]
%   q_min:      Minimalna wartość funkcji celu q (równanie 2.2)
% --- Sprawdzenie poprawności danych wejściowych ---
if ~isvector(t_data) || ~isvector(y_data_100)
    error('Dane wejściowe t_data i y_data_100 muszą być wektorami.');
end
if length(t_data) ~= length(y_data_100)
    error('Wektory t_data i y_data_100 muszą mieć tę samą długość.');
end

% --- Konwersja 'duration' na 'double' (sekundy) ---
if isduration(t_data)
    t_data = seconds(t_data);
elseif ~isnumeric(t_data)
    error('t_data musi być wektorem numerycznym lub typu duration.');
end

% --- Upewnienie się, że wektory są kolumnowe ---
t_data = t_data(:);
% ZMIANA: Konwersja skali 0-100 na 0-1.0 na potrzeby obliczeń
y_data_p = y_data_100(:) / 100.0; 

n = length(t_data); % Liczba pomiarów

% --- Definicja funkcji błędu (wersja procentowa 0-1.0) ---
% Ta funkcja wewnętrzna nadal działa na skali 0-1.0 dla stabilności
    function F = funkcjaBledu_procenty(params)
        c_i = params(1);
        alpha_i = params(2);
        
        if abs(alpha_i - 1.0) < 1e-9
            % Rozwiązanie dla alpha_i = 1 (skala 0-1)
            x_model_p = exp(-(c_i / S_i) * t_data);
        else
            % Przypadek ogólny (skala 0-1)
            wykladnik = 1 - alpha_i;
            h_term = h_i^(alpha_i - 1);
            C_grouped = c_i * h_term / S_i;
            
            baza_p = 1.0 - wykladnik * C_grouped * t_data;
            baza_p(baza_p < 0) = 0;
            
            x_model_p = baza_p.^(1 / wykladnik);
        end
        
        % Błąd jest różnicą na skali 0-1.0
        F = x_model_p - y_data_p;
    end

% --- Optymalizacja ---
% ZMIANA: Obliczamy dynamicznie wartość początkową, zamiast używać [1.0, 0.5]
% To drastycznie poprawia stabilność dla dużych h_i.

% 1. Zgadujemy, że alpha jest bliskie 0.5 (zgodnie z krzywą)
alpha_guess = 0.5;

% 2. Bierzemy ostatni punkt czasowy jako szacowany czas opróżnienia
t_end = max(t_data); 
if t_end == 0
    t_end = 1; % Zabezpieczenie przed dzieleniem przez zero
end

% 3. Obliczamy zgadywaną stałą C_grup z modelu
%    Z wzoru: 1 - (1-a_g) * C_g * t_end = 0  => C_g = 1 / ((1-a_g)*t_end)
C_grup_guess = 1 / ((1 - alpha_guess) * t_end);

% 4. Obliczamy c_i_guess, które da nam tę stałą C_grup
%    Z wzoru: C_g = c_i * h_i^(a_g - 1) / S_i => c_i = C_g * S_i / h_i^(a_g - 1)
h_term_guess = h_i^(alpha_guess - 1); % h_i^(-0.5)

% Zabezpieczenie przed dzieleniem przez zero, jeśli h_term jest bardzo małe
if abs(h_term_guess) < 1e-9
    c_i_guess = 1.0; % Wartość domyślna, jeśli obliczenia zawiodą
else
    c_i_guess = C_grup_guess * S_i / h_term_guess;
end

% Używamy obliczonych wartości jako punktu startowego
p0 = [c_i_guess, alpha_guess];

% Wyświetlenie zgadywanych wartości (możesz to usunąć później)
fprintf('Używam wartości początkowych: p0 = [%.4f, %.4f]\n', p0(1), p0(2));

lb = [0, 0];
options = optimoptions('lsqnonlin', 'Display', 'off', 'Algorithm', 'trust-region-reflective');

[params_opt, resnorm] = lsqnonlin(@funkcjaBledu_procenty, p0, lb, [], options);

% --- Obliczenie finalnej wartości funkcji celu q (2.2) ---
q_min = (1 / (2 * n)) * resnorm;

end