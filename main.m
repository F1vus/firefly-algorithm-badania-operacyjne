clear all; close all;

firefly_gui();

function firefly_gui()
    %========================
    %  GUI
    %========================
    fig = uifigure('Name', 'Algorytm Swietlika', ...
        'Position', [100 80 920 620], ...
        'Color', [0.15 0.15 0.15]);

    % Title
    uilabel(fig, 'Text', 'ALGORYTM SWIETLIKA - MIN / MAX', ...
        'Position', [20 575 420 30], ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'FontColor', [0.95 0.95 0.95], ...
        'BackgroundColor', [0.15 0.15 0.15]);

    % -------------------------
    % Objective
    % -------------------------
    uilabel(fig, 'Text', 'Funkcja celu:', ...
        'Position', [20 530 120 22], ...
        'FontSize', 12, ...
        'FontColor', [0.9 0.9 0.9], ...
        'BackgroundColor', [0.15 0.15 0.15]);

    fldObj = uieditfield(fig, 'text', ...
        'Value', '2*x1 + 4*x2 + 3*x3', ...
        'Position', [140 528 300 26], ...
        'FontSize', 12);

    uilabel(fig, 'Text', 'Tryb:', ...
        'Position', [460 530 50 22], ...
        'FontSize', 12, ...
        'FontColor', [0.9 0.9 0.9], ...
        'BackgroundColor', [0.15 0.15 0.15]);

    ddMode = uidropdown(fig, ...
        'Items', {'minimalizuj', 'maksymalizuj'}, ...
        'Value', 'maksymalizuj', ...
        'Position', [510 528 140 26], ...
        'FontSize', 12);

    % -------------------------
    % Algorithm parameters
    % -------------------------
    panelAlg = uipanel(fig, ...
        'Title', 'Parametry algorytmu', ...
        'Position', [20 270 360 230], ...
        'BackgroundColor', [0.19 0.19 0.19], ...
        'ForegroundColor', [0.95 0.95 0.95], ...
        'FontSize', 12);

    labelsAlg = {'Liczba swietlikow m:', 'Liczba iteracji:', 'B0:', 'alpha:', 'lb:', 'ub:'};
    defaultsAlg = {25, 120, 1, 0.2, 0, 40};
    algFields = cell(1,6);

    y0 = 170;
    for k = 1:6
        uilabel(panelAlg, 'Text', labelsAlg{k}, ...
            'Position', [15 y0 120 22], ...
            'FontSize', 11, ...
            'FontColor', [0.9 0.9 0.9], ...
            'BackgroundColor', [0.19 0.19 0.19]);

        algFields{k} = uieditfield(panelAlg, 'numeric', ...
            'Value', defaultsAlg{k}, ...
            'Position', [145 y0 180 26], ...
            'FontSize', 11);
        y0 = y0 - 30;
    end

    fldM = algFields{1};
    fldGen = algFields{2};
    fldB0 = algFields{3};
    fldAlpha = algFields{4};
    fldLb = algFields{5};
    fldUb = algFields{6};

    % -------------------------
    % Constraints panel
    % -------------------------
    panelCon = uipanel(fig, ...
        'Title', 'Ograniczenia', ...
        'Position', [400 170 490 330], ...
        'BackgroundColor', [0.19 0.19 0.19], ...
        'ForegroundColor', [0.95 0.95 0.95], ...
        'FontSize', 12);

    uilabel(panelCon, 'Text', 'A*x <= b', ...
        'Position', [15 285 120 22], ...
        'FontSize', 11, ...
        'FontColor', [0.7 0.9 0.7], ...
        'BackgroundColor', [0.19 0.19 0.19]);

    % Column headers
    uilabel(panelCon, 'Text', 'x1', 'Position', [95 260 40 20], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.19 0.19 0.19]);
    uilabel(panelCon, 'Text', 'x2', 'Position', [185 260 40 20], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.19 0.19 0.19]);
    uilabel(panelCon, 'Text', 'x3', 'Position', [275 260 40 20], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.19 0.19 0.19]);
    uilabel(panelCon, 'Text', 'b',  'Position', [405 260 40 20], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.19 0.19 0.19]);

    % Constraint 1
    uilabel(panelCon, 'Text', '1:', 'Position', [15 225 30 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.19 0.19 0.19]);
    c11 = uieditfield(panelCon, 'numeric', 'Value', 3, 'Position', [80 225 75 26]);
    c12 = uieditfield(panelCon, 'numeric', 'Value', 4, 'Position', [170 225 75 26]);
    c13 = uieditfield(panelCon, 'numeric', 'Value', 2, 'Position', [260 225 75 26]);
    b1  = uieditfield(panelCon, 'numeric', 'Value', 60, 'Position', [395 225 75 26]);

    % Constraint 2
    uilabel(panelCon, 'Text', '2:', 'Position', [15 185 30 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.19 0.19 0.19]);
    c21 = uieditfield(panelCon, 'numeric', 'Value', 2, 'Position', [80 185 75 26]);
    c22 = uieditfield(panelCon, 'numeric', 'Value', 1, 'Position', [170 185 75 26]);
    c23 = uieditfield(panelCon, 'numeric', 'Value', 2, 'Position', [260 185 75 26]);
    b2  = uieditfield(panelCon, 'numeric', 'Value', 40, 'Position', [395 185 75 26]);

    % Constraint 3
    uilabel(panelCon, 'Text', '3:', 'Position', [15 145 30 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.19 0.19 0.19]);
    c31 = uieditfield(panelCon, 'numeric', 'Value', 1, 'Position', [80 145 75 26]);
    c32 = uieditfield(panelCon, 'numeric', 'Value', 3, 'Position', [170 145 75 26]);
    c33 = uieditfield(panelCon, 'numeric', 'Value', 2, 'Position', [260 145 75 26]);
    b3  = uieditfield(panelCon, 'numeric', 'Value', 80, 'Position', [395 145 75 26]);

    % Bounds info
    uilabel(panelCon, 'Text', 'Ograniczenia nieujemnosci: x1 >= 0, x2 >= 0, x3 >= 0', ...
        'Position', [15 100 460 22], ...
        'FontSize', 11, ...
        'FontColor', [0.8 0.8 0.8], ...
        'BackgroundColor', [0.19 0.19 0.19]);

    % -------------------------
    % Results panel
    % -------------------------
    panelRes = uipanel(fig, ...
        'Title', 'Wynik', ...
        'Position', [20 20 870 230], ...
        'BackgroundColor', [0.19 0.19 0.19], ...
        'ForegroundColor', [0.95 0.95 0.95], ...
        'FontSize', 12);

    txtResult = uitextarea(panelRes, ...
        'Value', '', ...
        'Position', [15 15 370 185], ...
        'FontColor', [0.2 0.9 0.5], ...
        'BackgroundColor', [0.08 0.08 0.08], ...
        'FontSize', 11, ...
        'Editable', 'off');

    ax = uiaxes(panelRes, 'Position', [410 15 445 185]);
    ax.Color = [0.95 0.95 0.95];
    title(ax, 'Przebieg najlepszego wyniku');
    xlabel(ax, 'Iteracja');
    ylabel(ax, 'Wartosc');
    grid(ax, 'on');

    % -------------------------
    % Run button
    % -------------------------
    uibutton(fig, 'Text', 'URUCHOM', ...
        'Position', [690 520 200 35], ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.7 0.45], 'FontColor', [1 1 1], ...
        'ButtonPushedFcn', @(~,~) run());

    %========================
    %  CALLBACK
    %========================
    function run()
        expr = strtrim(fldObj.Value);
        if isempty(expr)
            uialert(fig, 'Wpisz funkcje celu.', 'Blad');
            return;
        end

        % Fixed 3-variable GUI
        n = 3;

        % Build objective function from text
        % User types: 2*x1 + 4*x2 + 3*x3
        try
            fobj = str2func(['@(x1,x2,x3) ' expr]);
            fobj(1,1,1); % test
        catch
            uialert(fig, 'Nieprawidlowa funkcja celu. Uzyj x1, x2, x3.', 'Blad');
            return;
        end

        A = [c11.Value c12.Value c13.Value;
             c21.Value c22.Value c23.Value;
             c31.Value c32.Value c33.Value];
        b = [b1.Value; b2.Value; b3.Value];

        if strcmp(ddMode.Value, 'minimalizuj')
            sense = 1;
        else
            sense = -1;
        end

        m = fldM.Value;
        MaxGeneration = fldGen.Value;
        B0 = fldB0.Value;
        alpha = fldAlpha.Value;
        lb = fldLb.Value;
        ub = fldUb.Value;

        % For 3 variables keep bounds as vectors
        lbv = [lb lb lb];
        ubv = [ub ub ub];

        txtResult.Value = {'Dzialanie...'};
        drawnow;

        [x_best, f_best, best_history] = firefly_algorithm( ...
            fobj, A, b, m, n, MaxGeneration, B0, alpha, lbv, ubv, sense, ax);

        if sense == 1
            header = sprintf('Wynik MIN\n');
            valText = sprintf('f_min = %.6f\n', f_best);
        else
            header = sprintf('Wynik MAX\n');
            valText = sprintf('f_max = %.6f\n', f_best);
        end

        resultText = {header, valText};
        resultText{end+1} = sprintf('x1 = %.6f', x_best(1));
        resultText{end+1} = sprintf('x2 = %.6f', x_best(2));
        resultText{end+1} = sprintf('x3 = %.6f', x_best(3));

        txtResult.Value = resultText;

        cla(ax);
        plot(ax, best_history, 'LineWidth', 1.8);
        grid(ax, 'on');
        title(ax, 'Przebieg najlepszego wyniku');
        xlabel(ax, 'Iteracja');
        ylabel(ax, 'Wartosc');

        % Console summary too
        disp('--- RESULT ---');
        disp(resultText);
    end
end

%=====================================================
% Firefly Algorithm for 3 variables with constraints
%=====================================================
function [x_best, f_best, best_history] = firefly_algorithm(fobj, A, b, m, n, MaxGeneration, B0, alpha, lb, ub, sense, ax)

    % Random initialization inside bounds
    x = lb + rand(m, n) .* (ub - lb);

    % Penalty coefficient
    penalty_weight = 1e6;

    fitness = zeros(m, 1);
    for i = 1:m
        fitness(i) = objective_with_penalty(fobj, x(i, :), A, b, penalty_weight, sense);
    end

    [X, Y] = meshgrid( ...
        lb(1):(ub(1)-lb(1))/50:ub(1), ...
        lb(2):(ub(2)-lb(2))/50:ub(2));
    
    Z = arrayfun(@(x1, x2) fobj(x1, x2, 0), X, Y);

    best_history = zeros(MaxGeneration, 1);
    figure(2)
    for t = 1:MaxGeneration
        for i = 1:m
            for j = 1:m
                if fitness(j) < fitness(i)
                    r = norm(x(i,:) - x(j,:));
                    beta = B0 * exp(-r^2);
                    step = alpha * (rand(1, n) - 0.5) .* (ub - lb);

                    x(i,:) = x(i,:) + beta * (x(j,:) - x(i,:)) + step;
                    x(i,:) = max(x(i,:), lb);
                    x(i,:) = min(x(i,:), ub);

                    fitness(i) = objective_with_penalty(fobj, x(i, :), A, b, penalty_weight, sense);
                end
            end
        end

        [~, idx] = min(fitness);
        x_best = x(idx, :);
        f_best = fobj(x_best(1), x_best(2), x_best(3));
        best_history(t) = f_best;

        clf
        contour(X, Y, Z, 30)
        hold on
        scatter(x(:,1), x(:,2), 80, 'filled')
        plot(x_best(1), x_best(2), 'r*', 'MarkerSize', 15)
        title(['Iteracja = ', num2str(t)])
        grid on
        drawnow

        % Optional live plot of convergence
        if ~isempty(ax) && isvalid(ax)
            cla(ax);
            plot(ax, best_history(1:t), 'LineWidth', 1.6);
            title(ax, sprintf('Przebieg najlepszego wyniku (iteracja %d)', t));
            xlabel(ax, 'Iteracja');
            ylabel(ax, 'Wartosc');
            grid(ax, 'on');
            drawnow limitrate;
        end
    end
end

function fit = objective_with_penalty(fobj, x, A, b, penalty_weight, sense)
    % Raw objective
    f = fobj(x(1), x(2), x(3));

    % Inequality constraints A*x <= b
    viol = max(0, A*x(:) - b).^2;

    % Nonnegativity
    viol_bounds = max(0, -x(:)).^2;

    penalty = penalty_weight * (sum(viol) + sum(viol_bounds));

    % Convert to minimization if needed
    fit = sense * f + penalty;
end
