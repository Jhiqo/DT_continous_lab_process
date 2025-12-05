function main_pid_optimizer
% MAIN_PID_OPTIMIZER
% Skrypt do strojenia regulatora PID przy użyciu algorytmu Neldera-Meada (fminsearch).
% Model: DT_offline
% Cel: Minimalizacja ITAE z ograniczeniem przeregulowania i chatteringu.

    %% Konfiguracja symulacji
    config.model_name = 'DT_offline';
    config.sim_time   = 400;      
    config.set_point  = 30;      
    config.filter_N   = 10;
    
    % Punkt startowy [Kp, Ki, Kd] dobrany eksperymentalnie
    x0 = [10, 0.5, 0.1]; 

    fprintf('--- Start optymalizacji PID ---\n');
    fprintf('Model: %s\n', config.model_name);
    fprintf('Startowe nastawy: Kp=%.4f, Ki=%.4f, Kd=%.4f\n\n', x0(1), x0(2), x0(3));
    
    %% Optymalizacja
    fprintf('%-5s | %-8s %-8s %-8s | %-10s %-10s %-10s | %-10s\n', ...
            'Iter', 'Kp', 'Ki', 'Kd', 'J_track', 'J_over', 'J_pump', 'TOTAL COST');
    fprintf('%s\n', repmat('-', 1, 85));

    options = optimset('Display', 'off', 'TolX', 1e-4, 'TolFun', 1e-4, 'MaxIter', 50);
    
    cost_fun = @(x) pid_cost_function(x, config);
    
    tic;
    [x_opt, fval] = fminsearch(cost_fun, x0, options);
    elapsed_time = toc;
    
    %% Wyniki i weryfikacja
    fprintf('\n--- Wyniki końcowe ---\n');
    fprintf('Czas obliczeń: %.2f s\n', elapsed_time);
    fprintf('Optymalne: Kp=%.4f, Ki=%.4f, Kd=%.4f\n', x_opt(1), x_opt(2), x_opt(3));
    fprintf('Koszt końcowy: %.4f\n', fval);
    
    % Zapis do Workspace (dla łatwego uruchomienia modelu ręcznie)
    assignin('base', 'K_p', x_opt(1));
    assignin('base', 'K_i', x_opt(2));
    assignin('base', 'K_d', x_opt(3));
    assignin('base', 'N', config.filter_N);
    assignin('base', 'h1_zadane', config.set_point);
    
    % Uruchomienie symulacji weryfikacyjnej
    run_verification(x_opt, config);
end

%% Funkcja kosztu
function J = pid_cost_function(params, cfg)
    % Parametry PID
    Kp = params(1);
    Ki = params(2);
    Kd = params(3);

    % Kary za parametry ujemne
    if any(params < 0)
        J = 1e15; return; 
    end

    % Wagi składników funkcji kosztu
    W_TRACK = 1.0;      % Waga uchybu (ITAE)
    W_OVER  = 10.0;     % Waga przeregulowania
    W_PUMP  = 50.0;     % Waga chatteringu

    try
        % Konfiguracja obiektu SimulationInput
        in = Simulink.SimulationInput(cfg.model_name);
        in = in.setModelParameter('StopTime', num2str(cfg.sim_time));
        in = in.setModelParameter('SimulationMode', 'normal');
        in = in.setVariable('K_p', Kp);
        in = in.setVariable('K_i', Ki);
        in = in.setVariable('K_d', Kd);
        in = in.setVariable('N', cfg.filter_N);
        in = in.setVariable('h1_zadane', cfg.set_point);
        
        % Symulacja
        simOut = sim(in);
        
        % Pobranie logowanych sygnałów
        t = simOut.logsout.get('A1_poziom').Values.Time;
        y = simOut.logsout.get('A1_poziom').Values.Data;
        
        try
            u = simOut.logsout.get('PID_out').Values.Data;
        catch
            u = zeros(size(y));
        end
        
        % Jakość regulacji (ITAE)
        e = cfg.set_point - y;
        J_track = trapz(t, t .* abs(e)); 
        
        % Kara za przeregulowanie
        max_y = max(y);
        if max_y > cfg.set_point
            J_over = (max_y - cfg.set_point)^2;
        else
            J_over = 0;
        end
        
        % Kara za chattering (zmienność sterowania)
        if length(u) > 1 
            du = diff(u);
            J_pump = sum(du.^2);
        else
            J_pump = 0;
        end
        
        % Wartość funkcji kosztu
        J = (W_TRACK * J_track) + (W_OVER * J_over) + (W_PUMP * J_pump);
        
        % Logi iteracji
        persistent iter_count;
        if isempty(iter_count), iter_count = 1; else, iter_count = iter_count + 1; end
        
        fprintf('%-5d | %-8.2f %-8.2f %-8.2f | %-10.1f %-10.1f %-10.1f | %-10.1f\n', ...
            iter_count, Kp, Ki, Kd, J_track, J_over, J_pump, J);
            
    catch ME
        fprintf('[ERROR] Symulacja nie powiodła się: %s\n', ME.message);
        J = 1e15; % Duża kara w przypadku błędu
    end
end

%% Weryfikacja
function run_verification(params, cfg)
    try
        in = Simulink.SimulationInput(cfg.model_name);
        in = in.setModelParameter('StopTime', num2str(cfg.sim_time));
        in = in.setVariable('K_p', params(1));
        in = in.setVariable('K_i', params(2));
        in = in.setVariable('K_d', params(3));
        in = in.setVariable('N', cfg.filter_N);
        in = in.setVariable('h1_zadane', cfg.set_point);
        
        simOut = sim(in);
    
        y = simOut.logsout.get('A1_poziom').Values.Data;
        t = simOut.logsout.get('A1_poziom').Values.Time;
        
        % Pobranie sterowania do weryfikacji gładkości
        try
            u = simOut.logsout.get('PID_out').Values.Data;
        catch
            u = zeros(size(y));
        end
        
        figure('Color', 'w', 'Name', 'Weryfikacja PID'); 
        
        subplot(2,1,1);
        plot(t, y, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]); grid on;
        yline(cfg.set_point, 'r--', 'Wartość zadana (SP)', 'LineWidth', 1.5); 
        title(['Przebieg regulacji: Kp=' num2str(params(1), '%.2f') ...
               ', Ki=' num2str(params(2), '%.2f') ', Kd=' num2str(params(3), '%.2f')]);
        ylabel('Poziom [%]'); 
        legend('PV', 'SP', 'Location', 'best');
        
        subplot(2,1,2);
        plot(t, u, 'LineWidth', 1.5, 'Color', [0.8500 0.3250 0.0980]); grid on;
        title('Sygnał sterujący (Wyjście PID)');
        ylabel('Sterowanie [%]'); xlabel('Czas [s]');
        
    catch ME
        warning(ME.identifier, 'Nie udało się wygenerować wykresu końcowego: %s', ME.message);
    end
end