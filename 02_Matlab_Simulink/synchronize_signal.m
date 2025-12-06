function [t_sync, y_sync] = synchronize_signal(t, y, threshold, edge_type)
% SYNCHRONIZE_SIGNAL Wyrównuje sygnał do momentu wystąpienia zdarzenia
%
% Funkcja przycina sygnał, usuwając "ciszę" lub dane sprzed rozpoczęcia
% właściwego eksperymentu. Zeruje oś czasu w momencie wykrycia zbocza.
%
% UŻYCIE:
%   [t_s, y_s] = synchronize_signal(t, y, 0.5, 'rising');
%   [t_s, y_s] = synchronize_signal(t, y, 100, 'falling');
%
% ARGUMENTY:
%   t           - wektor czasu
%   y           - wektor danych
%   threshold   - wartość progowa
%   edge_type   - 'rising' (narastające - np. napełnianie) lub
%                 'falling' (opadające - np. opróżnianie)

    % Domyślna wartość marginesu (ile próbek zostawić "przed" skokiem)
    PRE_TRIGGER_SAMPLES = 5; 
    
    % Zabezpieczenie na wypadek pustych danych
    if isempty(y) || isempty(t)
        t_sync = []; y_sync = [];
        return;
    end

    % Domyślny poziom resetu, pozwala uniknąć problemu z poprzednimi
    % eksperymentami
    reset_level = threshold * 0.5; 
    
    % Indeks, od którego zaczniemy właściwe poszukiwania triggera
    idx_search_start = 1;

    %% 1. Reset
    switch lower(edge_type)
        case 'rising'
            % Szukamy zbocza narastającegp            
            % Sprawdzamy, czy na samym początku sygnał już nie jest wysoki
            if y(1) > threshold
                % Jeśli tak, to szukamy momentu, kiedy on najpierw opadnie
                idx_drop = find(y < reset_level, 1, 'first');
                
                if isempty(idx_drop)
                    warning('Sygnał zaczyna się wysoko i nigdy nie spada! Zwracam całość.');
                    idx_search_start = 1;
                else
                    % Znaleźliśmy koniec poprzedniej akcji, zaczynamy szukać po niej
                    idx_search_start = idx_drop;
                end
            end
            
            % Teraz szukamy właściwego momentu skoku w górę
            y_part = y(idx_search_start:end);
            idx_trigger_rel = find(y_part > threshold, 1, 'first');
            
        case 'falling'
            % Szukamy zbocza opadającego
            
            % Sprawdzamy, czy na początku sygnał już nie jest niski
            if y(1) < threshold
                % Jeśli tak, musimy poczekać aż najpierw urośnie
                % Uwaga: dla opadającego reset_level musi być wyższy niż threshold!
                reset_level_falling = threshold * 1.1; 
                
                idx_rise = find(y > reset_level_falling, 1, 'first');
                
                if isempty(idx_rise)
                    warning('Sygnał zaczyna się nisko i nigdy nie rośnie! Zwracam całość.');
                    idx_search_start = 1;
                else
                    idx_search_start = idx_rise;
                end
            end
            
            % Szukamy właściwego momentu spadku
            y_part = y(idx_search_start:end);
            idx_trigger_rel = find(y_part < threshold, 1, 'first');
            
        otherwise
            error('Nieznany typ zbocza. Użyj "rising" lub "falling".');
    end

    %% 2. Przycinanie
    
    if isempty(idx_trigger_rel)
        % Nie znaleziono triggera - zwracamy od początku
        idx_final = 1; 
    else
        % Przeliczamy indeks względny na bezwzględny
        idx_abs = idx_search_start + idx_trigger_rel - 1;
        
        % Cofamy się o kilka próbek, żeby złapać moment tuż przed zmianą
        idx_final = max(1, idx_abs - PRE_TRIGGER_SAMPLES);
    end
    
    % Przycinamy wektory
    t_sync = t(idx_final:end);
    y_sync = y(idx_final:end);
    
    % Zerujemy czas
    if ~isempty(t_sync)
        t_sync = t_sync - t_sync(1);
    end
end