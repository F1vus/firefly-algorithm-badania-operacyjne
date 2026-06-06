clear all; close all;
firefly_gui();

function firefly_gui()
% ═══════════════════════════════════════════════════════════
%  STAŁE KOLORÓW I UKŁADU
% ═══════════════════════════════════════════════════════════
BG   = [0.94 0.94 0.94];   % tło okna
PAN  = [0.88 0.88 0.88];   % tło paneli
TXT  = [0.10 0.10 0.10];   % tekst główny
HINT = [0.52 0.52 0.52];   % tekst pomocniczy
GRN  = [0.05 0.42 0.18];   % tekst wyników
BLU  = [0.18 0.42 0.80];   % przycisk "dodaj"

MAX_N   = 6;   % max liczba zmiennych
MAX_CON = 7;   % max liczba ograniczeń
curN    = 3;   % aktualnie aktywne n
curCon  = 3;   % aktualnie aktywna liczba ograniczeń

% ── Geometria tabeli ograniczeń ──────────────────────────
COL_X   = 52;   % x pierwszej kolumny współczynnika
COL_W   = 70;   % szerokość pola współczynnika
COL_GAP =  4;   % odstęp między polami
SIGN_W  = 62;   % szerokość listy "znak"
B_W     = 70;   % szerokość pola b
DEL_W   = 30;   % szerokość przycisku ✕
HDR_Y   = 292;  % y wiersza nagłówków (wewnątrz panelCon)
ROW_H   = 34;   % wysokość wiersza
FLD_H   = 26;   % wysokość pola edycji

% ═══════════════════════════════════════════════════════════
%  OKNO
% ═══════════════════════════════════════════════════════════
fig = uifigure('Name', 'Algorytm Świetlika', ...
    'Position', [80 50 1100 750], 'Color', BG);

% ── Tytuł ───────────────────────────────────────────────
uilabel(fig, 'Text', 'ALGORYTM ŚWIETLIKA  —  MIN / MAX', ...
    'Position', [20 710 680 32], ...
    'FontSize', 20, 'FontWeight', 'bold', ...
    'FontColor', TXT, 'BackgroundColor', BG);

% ── URUCHOM (duży blok po prawej, obejmuje oba rzędy) ───
uibutton(fig, 'Text', sprintf('▶  URUCHOM'), ...
    'Position', [858 622 222 90], ...
    'FontSize', 15, 'FontWeight', 'bold', ...
    'BackgroundColor', [0.14 0.62 0.36], 'FontColor', [1 1 1], ...
    'ButtonPushedFcn', @(~,~) run_algorithm());

% ── Rząd 1: funkcja celu + n ────────────────────────────
uilabel(fig, 'Text', 'f(x) =', ...
    'Position', [20 670 55 28], ...
    'FontSize', 13, 'FontColor', TXT, 'BackgroundColor', BG);

fldObj = uieditfield(fig, 'text', ...
    'Value', '@(x1,x2,x3) 2*x1 + 4*x2 + 3*x3', ...
    'Position', [78 668 555 30], 'FontSize', 12);

uilabel(fig, 'Text', 'n =', ...
    'Position', [650 670 30 28], ...
    'FontSize', 13, 'FontColor', TXT, 'BackgroundColor', BG);

fldN = uieditfield(fig, 'numeric', ...
    'Value', curN, 'Limits', [1 MAX_N], ...
    'RoundFractionalValues', 'on', ...
    'Position', [682 668 52 30], 'FontSize', 13);

uibutton(fig, 'Text', '⟳  Ustaw n', ...
    'Position', [744 668 104 30], ...
    'FontSize', 11, 'BackgroundColor', [0.78 0.78 0.78], ...
    'ButtonPushedFcn', @(~,~) applyN());

% ── Rząd 2: tryb ────────────────────────────────────────
uilabel(fig, 'Text', 'Tryb optymalizacji:', ...
    'Position', [20 629 152 28], ...
    'FontSize', 12, 'FontColor', TXT, 'BackgroundColor', BG);

ddMode = uidropdown(fig, ...
    'Items', {'maksymalizuj', 'minimalizuj'}, ...
    'Value', 'maksymalizuj', ...
    'Position', [178 627 180 30], 'FontSize', 12);

% ═══════════════════════════════════════════════════════════
%  PANEL: PARAMETRY ALGORYTMU
% ═══════════════════════════════════════════════════════════
panelAlg = uipanel(fig, 'Title', 'Parametry algorytmu', ...
    'Position', [20 258 334 352], ...
    'BackgroundColor', PAN, 'ForegroundColor', TXT, 'FontSize', 12);

labA = {'Świetliki m:', 'Iteracje:', 'B0:', 'alpha:', 'Dolne lb:', 'Górne ub:'};
defA = {25, 120, 1, 0.2, 0, 40};
flds = cell(1, 6);
yy = 278;
for k = 1:6
    uilabel(panelAlg, 'Text', labA{k}, ...
        'Position', [15 yy 115 22], ...
        'FontSize', 11, 'FontColor', TXT, 'BackgroundColor', PAN);
    flds{k} = uieditfield(panelAlg, 'numeric', ...
        'Value', defA{k}, ...
        'Position', [140 yy 168 26], 'FontSize', 11);
    yy = yy - 37;
end
fldM     = flds{1};
fldGen   = flds{2};
fldB0    = flds{3};
fldAlpha = flds{4};
fldLb    = flds{5};
fldUb    = flds{6};

% ═══════════════════════════════════════════════════════════
%  PANEL: OGRANICZENIA
% ═══════════════════════════════════════════════════════════
panelCon = uipanel(fig, 'Title', 'Ograniczenia  (A · x  rel  b)', ...
    'Position', [366 258 712 352], ...
    'BackgroundColor', PAN, 'ForegroundColor', TXT, 'FontSize', 12);

% ── Nagłówek ─────────────────────────────────────────────
uilabel(panelCon, 'Text', '#', ...
    'Position', [14 HDR_Y 28 22], ...
    'FontSize', 10, 'FontColor', HINT, 'BackgroundColor', PAN, ...
    'HorizontalAlignment', 'center');

hdrCoef = gobjects(MAX_N, 1);
for k = 1:MAX_N
    hdrCoef(k) = uilabel(panelCon, ...
        'Text', sprintf('x%d', k), ...
        'Position', [COL_X + (k-1)*(COL_W+COL_GAP)  HDR_Y  COL_W  22], ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'FontColor', TXT, 'BackgroundColor', PAN, ...
        'HorizontalAlignment', 'center');
end

% Nagłówki "znak" i "b" — pozycja x aktualizowana dynamicznie
hdrSign = uilabel(panelCon, 'Text', 'znak', ...
    'Position', [0 HDR_Y SIGN_W 22], ...
    'FontSize', 11, 'FontWeight', 'bold', ...
    'FontColor', TXT, 'BackgroundColor', PAN, ...
    'HorizontalAlignment', 'center');
hdrB = uilabel(panelCon, 'Text', 'b', ...
    'Position', [0 HDR_Y B_W 22], ...
    'FontSize', 11, 'FontWeight', 'bold', ...
    'FontColor', TXT, 'BackgroundColor', PAN, ...
    'HorizontalAlignment', 'center');

% ── Domyślne dane ograniczeń ─────────────────────────────
defAc = [3 4 2 0 0 0;
         2 1 2 0 0 0;
         1 3 2 0 0 0;
         zeros(4, 6)];
defRc = repmat({'<='}, MAX_CON, 1);
defBc = [60; 40; 80; 0; 0; 0; 0];

% ── Wiersze ograniczeń (pre-created, show/hide) ──────────
conRows = cell(MAX_CON, 1);
for r = 1:MAX_CON
    rowY = HDR_Y - r * ROW_H;
    row  = struct();

    row.num = uilabel(panelCon, 'Text', num2str(r), ...
        'Position', [14 rowY+2 28 22], ...
        'FontSize', 10, 'FontColor', HINT, 'BackgroundColor', PAN, ...
        'HorizontalAlignment', 'center', 'Visible', 'off');

    row.coef = gobjects(MAX_N, 1);
    for k = 1:MAX_N
        row.coef(k) = uieditfield(panelCon, 'numeric', ...
            'Value', defAc(r, k), ...
            'Position', [COL_X + (k-1)*(COL_W+COL_GAP)  rowY  COL_W  FLD_H], ...
            'FontSize', 11, 'Visible', 'off');
    end

    % Pozycje x ustawione na 0 — updateDisplay je uaktualni
    row.sign = uidropdown(panelCon, ...
        'Items', {'<=', '=', '>='}, 'Value', defRc{r}, ...
        'Position', [0  rowY  SIGN_W  FLD_H], ...
        'FontSize', 10, 'Visible', 'off');

    row.bfld = uieditfield(panelCon, 'numeric', ...
        'Value', defBc(r), ...
        'Position', [0  rowY  B_W  FLD_H], ...
        'FontSize', 11, 'Visible', 'off');

    row.del = uibutton(panelCon, 'Text', '✕', ...
        'Position', [0  rowY  DEL_W  FLD_H], ...
        'FontSize', 10, ...
        'BackgroundColor', [0.80 0.18 0.18], 'FontColor', [1 1 1], ...
        'Visible', 'off');
    row.del.UserData = r;                             % stały index pozycji
    row.del.ButtonPushedFcn = @deleteRowByBtn;

    conRows{r} = row;
end

% ── Przycisk "Dodaj ograniczenie" ────────────────────────
uibutton(panelCon, 'Text', '＋  Dodaj ograniczenie', ...
    'Position', [14 6 178 28], ...
    'FontSize', 11, 'BackgroundColor', BLU, 'FontColor', [1 1 1], ...
    'ButtonPushedFcn', @(~,~) addRow());

% ═══════════════════════════════════════════════════════════
%  PANEL: WYNIK
% ═══════════════════════════════════════════════════════════
panelRes = uipanel(fig, 'Title', 'Wynik', ...
    'Position', [20 16 1060 236], ...
    'BackgroundColor', PAN, 'ForegroundColor', TXT, 'FontSize', 12);

txtResult = uitextarea(panelRes, 'Value', '', ...
    'Position', [14 14 385 198], ...
    'FontColor', GRN, 'BackgroundColor', [1 1 1], ...
    'FontSize', 15, 'FontWeight', 'bold', 'Editable', 'off');

ax = uiaxes(panelRes, 'Position', [412 14 632 198]);
ax.Color  = [1 1 1];
ax.XColor = TXT;
ax.YColor = TXT;
title(ax,  'Przebieg najlepszego wyniku');
xlabel(ax, 'Iteracja');
ylabel(ax, 'Wartość');
grid(ax, 'on');

% ── Inicjalizacja ────────────────────────────────────────
updateDisplay();

% ═══════════════════════════════════════════════════════════
%  FUNKCJE ZAGNIEŻDŻONE  (współdzielą workspace z firefly_gui)
% ═══════════════════════════════════════════════════════════

    function updateDisplay()
            n = round(fldN.Value);
        
            % przesunięcia kolumn zależne od n
            sigX = COL_X + n * (COL_W + COL_GAP) + 10;
            bX   = sigX + SIGN_W + 6;
            dX   = bX + B_W + 6;
        
            % nagłówki x1...xn
            for k = 1:MAX_N
                hdrCoef(k).Visible = fa_vis(k <= n);
                hdrCoef(k).Position = [COL_X + (k-1)*(COL_W+COL_GAP), HDR_Y, COL_W, 22];
            end
        
            % nagłówek "#"
            [x0, y0, w0, h0] = deal(14, HDR_Y, 28, 22);
            set(hdrSign.Parent.Children(end), 'Position', [x0 y0 w0 h0]); % opcjonalnie jeśli chcesz ruszyć też #
            % jeśli nie chcesz ruszać #, zostaw bez tej linii
        
            % nagłówki "znak" i "b"
            hdrSign.Position = [sigX, HDR_Y, SIGN_W, 22];
            hdrB.Position    = [bX,   HDR_Y, B_W,    22];
        
            % układanie wierszy od góry do dołu
            startY = HDR_Y - ROW_H;
            for r = 1:MAX_CON
                row = conRows{r};
        
                if r <= curCon
                    rowY = startY - (r-1) * ROW_H;
        
                    row.num.Position  = [14, rowY+2, 28, 22];
                    row.num.Visible   = 'on';
        
                    for k = 1:MAX_N
                        row.coef(k).Position = [COL_X + (k-1)*(COL_W+COL_GAP), rowY, COL_W, FLD_H];
                        row.coef(k).Visible  = fa_vis(k <= n);
                    end
        
                    row.sign.Position = [sigX, rowY, SIGN_W, FLD_H];
                    row.bfld.Position = [bX,   rowY, B_W,    FLD_H];
                    row.del.Position  = [dX,   rowY, DEL_W,  FLD_H];
        
                    row.sign.Visible = 'on';
                    row.bfld.Visible = 'on';
                    row.del.Visible  = 'on';
                else
                    row.num.Visible  = 'off';
                    row.sign.Visible = 'off';
                    row.bfld.Visible = 'off';
                    row.del.Visible  = 'off';
        
                    for k = 1:MAX_N
                        row.coef(k).Visible = 'off';
                    end
                end
            end
        end

    function applyN()
        curN = round(fldN.Value);
        updateDisplay();
    end

    function addRow()
        if curCon >= MAX_CON
            uialert(fig, sprintf('Maksymalnie %d ograniczeń.', MAX_CON), 'Info');
            return;
        end
    
        curCon = curCon + 1;
    
        % opcjonalnie wyzeruj nowy wiersz
        newRow = conRows{curCon};
        for k = 1:MAX_N
            newRow.coef(k).Value = 0;
        end
        newRow.sign.Value = '<=';
        newRow.bfld.Value = 0;
    
        updateDisplay();
    end

    % Callback przycisku ✕ — UserData zawiera stały index pozycji UI
    function deleteRowByBtn(src, ~)
        r = src.UserData;
        if r > curCon, return; end

        % Przesuń dane w górę (od wiersza r do curCon-1)
        for i = r : curCon - 1
            s = conRows{i + 1};
            d = conRows{i};
            for k = 1:MAX_N
                d.coef(k).Value = s.coef(k).Value;
            end
            d.sign.Value = s.sign.Value;
            d.bfld.Value = s.bfld.Value;
        end

        % Wyczyść ostatni wiersz
        last = conRows{curCon};
        for k = 1:MAX_N, last.coef(k).Value = 0; end
        last.sign.Value = '<=';
        last.bfld.Value = 0;

        curCon = curCon - 1;
        updateDisplay();
        drawnow;
    end

    function run_algorithm()
        expr = strtrim(fldObj.Value);
        if isempty(expr)
            uialert(fig, 'Wpisz funkcję celu.', 'Błąd'); return;
        end

        n = round(fldN.Value);

        try
            fobj  = str2func(expr);
            targs = num2cell(ones(1, n));
            fobj(targs{:});
        catch
            uialert(fig, ...
                sprintf('Zły wzór. Użyj np.: @(x1,...,x%d) wyrażenie', n), 'Błąd');
            return;
        end

        if curCon == 0
            uialert(fig, 'Dodaj przynajmniej jedno ograniczenie.', 'Błąd'); return;
        end

        A_r   = zeros(curCon, n);
        rel_r = cell(curCon, 1);
        b_r   = zeros(curCon, 1);
        for r = 1:curCon
            row = conRows{r};
            for k = 1:n, A_r(r, k) = row.coef(k).Value; end
            rel_r{r} = row.sign.Value;
            b_r(r)   = row.bfld.Value;
        end

        if strcmp(ddMode.Value, 'minimalizuj'), sense = 1; else, sense = -1; end

        m    = round(fldM.Value);
        MaxG = round(fldGen.Value);
        B0   = fldB0.Value;
        alph = fldAlpha.Value;
        lb   = fldLb.Value;
        ub   = fldUb.Value;
        lbv  = lb * ones(1, n);
        ubv  = ub * ones(1, n);

        txtResult.Value = {'Działanie...'}; drawnow;

        [xb, fb, bh] = firefly_algorithm( ...
            fobj, A_r, b_r, rel_r, m, n, MaxG, B0, alph, lbv, ubv, sense, ax);

        if sense == 1
            res = {'Wynik MIN', sprintf('f_min = %.6f', fb)};
        else
            res = {'Wynik MAX', sprintf('f_max = %.6f', fb)};
        end
        for k = 1:n
            res{end+1} = sprintf('x%d = %.6f', k, xb(k));
        end
        txtResult.Value = res;

        cla(ax);
        plot(ax, bh, 'LineWidth', 1.8, 'Color', [0.18 0.55 0.34]);
        grid(ax, 'on');
        title(ax,  'Przebieg najlepszego wyniku');
        xlabel(ax, 'Iteracja'); ylabel(ax, 'Wartość');
    end

end   % koniec firefly_gui

% ═══════════════════════════════════════════════════════════
%  FUNKCJE POMOCNICZE (poziom pliku)
% ═══════════════════════════════════════════════════════════
function s = fa_vis(flag)
    if flag, s = 'on'; else, s = 'off'; end
end

% ═══════════════════════════════════════════════════════════
%  ALGORYTM ŚWIETLIKA
% ══════════════════════════════════════════════════════════=
function [x_best, f_best, bh] = firefly_algorithm( ...
        fobj, A, b, rels, m, n, MaxGen, B0, alpha, lb, ub, sense, ax)

    x = lb + rand(m, n) .* (ub - lb);
    PW = 1e6;

    fitness = zeros(m, 1);
    for i = 1:m
        fitness(i) = fa_pen(fobj, x(i,:), A, b, rels, PW, sense);
    end

    canPlot = (n >= 2);
    if canPlot
        [X, Y] = meshgrid( ...
            lb(1):(ub(1)-lb(1))/50:ub(1), ...
            lb(2):(ub(2)-lb(2))/50:ub(2));
        Z = arrayfun(@(x1,x2) fa_slice(fobj, x1, x2, n), X, Y);
        figure(2); clf;
    end

    bh = zeros(MaxGen, 1);

    for t = 1:MaxGen
        for i = 1:m
            for j = 1:m
                if fitness(j) < fitness(i)
                    r    = norm(x(i,:) - x(j,:));
                    beta = B0 * exp(-r^2);
                    step = alpha * (rand(1,n) - 0.5) .* (ub - lb);
                    x(i,:) = max(min(x(i,:) + beta*(x(j,:)-x(i,:)) + step, ub), lb);
                    fitness(i) = fa_pen(fobj, x(i,:), A, b, rels, PW, sense);
                end
            end
        end

        [~, idx] = min(fitness);
        x_best  = x(idx, :);
        f_best  = fa_eval(fobj, x_best);
        bh(t)   = f_best;

        if canPlot
            figure(2); clf;
            contour(X, Y, Z, 30); hold on;
            scatter(x(:,1), x(:,2), 80, 'filled');
            plot(x_best(1), x_best(2), 'r*', 'MarkerSize', 15);
            title(['Iteracja = ', num2str(t)]); grid on; drawnow;
        end

        if ~isempty(ax) && isvalid(ax)
            cla(ax);
            plot(ax, bh(1:t), 'LineWidth', 1.6, 'Color', [0.18 0.55 0.34]);
            title(ax, sprintf('Iteracja %d', t));
            xlabel(ax, 'Iteracja'); ylabel(ax, 'Wartość'); grid(ax, 'on');
            drawnow limitrate;
        end
    end
end

function fit = fa_pen(fobj, x, A, b, rels, PW, sense)
    f   = fa_eval(fobj, x);
    pen = 0;
    for i = 1:size(A, 1)
        lhs = A(i,:) * x(:);
        switch char(rels{i})
            case '<=';  v = max(0, lhs - b(i));
            case '>=';  v = max(0, b(i) - lhs);
            case '=';   v = abs(lhs - b(i));
            otherwise;  v = 0;
        end
        pen = pen + v^2;
    end
    pen = pen + sum(max(0, -x(:)).^2);
    fit = sense * f + PW * pen;
end

function v = fa_eval(fobj, x)
    args = num2cell(x);
    v    = fobj(args{:});
end

function z = fa_slice(fobj, x1, x2, n)
    x = zeros(1, n);
    x(1) = x1;
    if n >= 2, x(2) = x2; end
    z = fa_eval(fobj, x);
end