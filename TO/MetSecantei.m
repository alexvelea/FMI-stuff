function MetSecantei()
    F = @(x)(x*x*x -5*x*x -14*x +100);
    Solve(F, -3, +8);
end

function Solve(F, a, b)
    eps = 1e-5;
    f = F;
    f_dev = @(x)((f(x + eps) - f(x)) / (eps)); % derivative estimation
    x_aprox = MetodaSecantei(f_dev, a, b, eps);
    
    x = linspace(a, b, 100);

    figure;
    hold on;
    plot(x, arrayfun(f, x)) % the graph of the function
    plot(x, arrayfun(f_dev, x)) % the graph of the derivative of function
    plot([x_aprox], [f(x_aprox)], 'or') % our intersection point
    plot([a b], [0 0]) % line x = 0
    hold off
end

function x_aprox = MetodaSecantei(f, a, b, epsilon)
    x_0 = a;
    x_1 = b;
    x_aprox = NaN;
    while (abs(x_1 - x_0) / abs(x_1) >= epsilon)
        x_aprox
        x_new = (x_0 * f(x_1) - x_1 * f(x_0)) / (f(x_1) - f(x_0));
        if x_new < a || b < x_new
            break
            x_aprox = NaN
        end
        
        x_0 = x_1;
        x_1 = x_new;
        x_aprox = x_1;
    end
end