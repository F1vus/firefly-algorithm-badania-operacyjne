clear all; close all;


firefly_gui();
 
function firefly_gui()
 
fig = uifigure('Name', 'Algorytm Swietlika', 'Position', [100 80 320 520], 'Color', [0.15 0.15 0.15]);
 
uilabel(fig, 'Text', 'fobj (np. x^2 + y^2):', 'Position', [15 488 270 22], ...
    'FontColor', [0.6 0.6 0.6], 'BackgroundColor', [0.15 0.15 0.15], 'FontSize', 11);
fldFobj = uieditfield(fig, 'text', 'Value', 'x^2 + y^2', ...
    'Position', [15 462 270 26], 'FontSize', 12);
 
uilabel(fig, 'Text', 'm (swietliki):',  'Position', [15 425 130 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.15 0.15 0.15], 'FontSize', 12);
fldM = uieditfield(fig, 'numeric', 'Value', 20,  'Position', [155 425 130 26], 'FontSize', 12);
 
uilabel(fig, 'Text', 'MaxGeneration:', 'Position', [15 385 130 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.15 0.15 0.15], 'FontSize', 12);
fldGen = uieditfield(fig, 'numeric', 'Value', 100,'Position', [155 385 130 26], 'FontSize', 12);
 
uilabel(fig, 'Text', 'B0:',            'Position', [15 345 130 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.15 0.15 0.15], 'FontSize', 12);
fldB0 = uieditfield(fig, 'numeric', 'Value', 1,   'Position', [155 345 130 26], 'FontSize', 12);
 
uilabel(fig, 'Text', 'alpha:',         'Position', [15 305 130 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.15 0.15 0.15], 'FontSize', 12);
fldAlpha = uieditfield(fig, 'numeric', 'Value', 0.2,'Position', [155 305 130 26], 'FontSize', 12);
 
uilabel(fig, 'Text', 'lb:',            'Position', [15 265 130 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.15 0.15 0.15], 'FontSize', 12);
fldLb = uieditfield(fig, 'numeric', 'Value', -5,  'Position', [155 265 130 26], 'FontSize', 12);
 
uilabel(fig, 'Text', 'ub:',            'Position', [15 225 130 22], 'FontColor', [0.9 0.9 0.9], 'BackgroundColor', [0.15 0.15 0.15], 'FontSize', 12);
fldUb = uieditfield(fig, 'numeric', 'Value', 5,   'Position', [155 225 130 26], 'FontSize', 12);

txtResult = uitextarea(fig, 'Value', '', ...
    'Position', [15 95 270 115], ...
    'FontColor', [0.2 0.9 0.5], 'BackgroundColor', [0.08 0.08 0.08], ...
    'FontSize', 10, 'Editable', 'off');

uibutton(fig, 'Text', 'URUCHOM', 'Position', [15 20 270 60], ...
    'FontSize', 15, 'FontWeight', 'bold', ...
    'BackgroundColor', [0.2 0.7 0.45], 'FontColor', [1 1 1], ...
    'ButtonPushedFcn', @(~,~) run());
 
        function run()
        % Slowa kluczowe MATLABa do wykluczenia
        matlab_keywords = {'sin','cos','tan','exp','log','sqrt','abs', ...
            'mod','rem','floor','ceil','round','pi','inf','nan', ...
            'asin','acos','atan','sinh','cosh','tanh','sign','max','min'};
 
        expr = fldFobj.Value;
 
        % Znajdz wszystkie slowa (potencjalne zmienne)
        tokens = regexp(expr, '[a-zA-Z][a-zA-Z0-9_]*', 'match');
        % Usun duplikaty i slowa kluczowe
        vars = unique(tokens);
        vars = vars(~ismember(vars, matlab_keywords));
 
        if isempty(vars)
            uialert(fig, 'Nie znaleziono zmiennych! Uzyj np.: x^2 + y^2', 'Blad');
            return;
        end
 
        n = length(vars);
 
        % Zamien zmienne na var(1), var(2), ... - od najdluzszych zeby uniknac
        % blednego zastapienia (np. 'xx' przed 'x')
        [~, ord] = sort(cellfun(@length, vars), 'descend');
        vars_sorted = vars(ord);
        expr_mapped = expr;
        for k = 1:length(vars_sorted)
            idx = find(strcmp(vars, vars_sorted{k}));
            expr_mapped = regexprep(expr_mapped, ...
                ['(?<![a-zA-Z0-9_])' vars_sorted{k} '(?![a-zA-Z0-9_])'], ...
                sprintf('var(%d)', idx));
        end
 
        try
            fobj = str2func(['@(var) ' expr_mapped]);
            fobj(zeros(1, n)); % test
        catch
            uialert(fig, 'Nieprawidlowa funkcja!', 'Blad');
            return;
        end
 
        txtResult.Value = 'Dzialanie...';

        [x_best, f_best] = firefly_algorithm(fobj, ...
            fldM.Value, n, fldGen.Value, ...
            fldB0.Value, fldAlpha.Value, fldLb.Value, fldUb.Value);


        resultText = sprintf('f_min = %.6f\n', f_best);
        for k = 1:n
            resultText = [resultText sprintf('%s = %.6f\n', vars{k}, x_best(k))];
        end
        txtResult.Value = resultText;
    end
 
end

%fobj = @(z) z(1)^2 + z(2)^2;

%[x_best, f_best] = firefly_algorithm(fobj, 20, 2, 100, 1, 0.2, -5, 5);

function [x_best, f_best, x, fval] = firefly_algorithm(fobj, m, n, MaxGeneration, B0, alpha, lb, ub)

    x = lb + rand(m, n) .* (ub - lb);

    fval = zeros(m, 1);
    for i = 1:m
        fval(i) = fobj(x(i, :));
    end

    [X, Y] = meshgrid(lb:(ub-lb)/50:ub, lb:(ub-lb)/50:ub);
    Z = arrayfun(@(a,b) fobj([a, b, zeros(1, n-2)]), X, Y);

    figure(1)

    for t = 1:MaxGeneration
        for i = 1:m
            for j = 1:m
                if fval(j) < fval(i)
                    r = norm(x(i,:) - x(j,:));
                    beta = B0 * exp(-r^2);

                    step = alpha * (rand(1, n) - 0.5) .* (ub - lb);

                    x(i,:) = x(i,:) + beta * (x(j,:) - x(i,:)) + step;

                    x(i,:) = max(x(i,:), lb);
                    x(i,:) = min(x(i,:), ub);

                    fval(i) = fobj(x(i,:));
                end
            end
        end

        [f_best, idx] = min(fval);
        x_best = x(idx, :);

        clf
        contour(X, Y, Z, 30)
        hold on
        scatter(x(:,1), x(:,2), 80, 'filled')
        plot(x_best(1), x_best(2), 'r*', 'MarkerSize', 15)
        title(['Iteracja = ', num2str(t)])
        grid on
        drawnow
    end
end