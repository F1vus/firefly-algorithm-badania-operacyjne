function [x_best, f_best, x, fval] = firefly_algorithm(fobj, m, n, MaxGeneration, B0, alpha, lb, ub)

    % x - populacja świetlików: m x n
    x = lb + rand(m, n) .* (ub - lb);

    % wartości funkcji celu
    fval = zeros(m, 1);
    for i = 1:m
        fval(i) = fobj(x(i, :));
    end

    [X,Y] = meshgrid(-5:0.2:5, -5:0.2:5);
    Z = X.^2 + Y.^2;
    for t = 1:MaxGeneration
        for i = 1:m
            for j = 1:m
                if fval(j) < fval(i)
                    r = norm(x(i,:) - x(j,:));
                    beta = B0 * exp(-r^2);

                    step = alpha * (rand(1, n) - 0.5) .* (ub - lb);

                    x(i,:) = x(i,:) + beta * (x(j,:) - x(i,:)) + step;

                    % ograniczenia
                    x(i,:) = max(x(i,:), lb);
                    x(i,:) = min(x(i,:), ub);

                    % aktualizacja wartości funkcji
                    fval(i) = fobj(x(i,:));

                    figure(1)
                    clf
                    
                    contour(X,Y,Z,30)
                    hold on
                    
                    scatter(x(:,1), x(:,2), 80, 'filled')

                    

                end
            end
        end
    end

    [f_best, idx] = min(fval);
    x_best = x(idx, :);
    plot(x_best(1), x_best(2), 'r*', 'MarkerSize', 15)
    title(['Iteracja = ', num2str(t)])
    grid on
                    
    drawnow
    pause(0.1)
end

fobj = @(z) z(1)^2 + z(2)^2;

[x_best, f_best] = firefly_algorithm(fobj, 20, 2, 100, 1, 0.2, -5, 5);