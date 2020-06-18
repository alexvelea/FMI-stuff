% minimizeaza o functie f facand f derivat = 0

function MetBisectiei()
    F = @(x)(x*x + 3 * x + 8);
    Solve(F, -5, +5);
end

function Solve(f, a, b)
    eps = 1e-5;
    F = @(x)((f(x + eps) - f(x)) / (eps)); % derivative estimation
    x_aprox = MetBis(F, a, b, eps);
    
    x = linspace(a, b, 100);

    figure;
    hold on;
    plot(x, arrayfun(f, x)) % the graph of the function
    plot(x, arrayfun(F, x)) % the graph of the derivative of function
    plot([x_aprox], [f(x_aprox)], 'or') % our intersection point
    plot([a b], [0 0]) % line x = 0
    hold off
end

function x = MetBis(f, a, b, epsilon)
    x = (a + b) / 2;
    N = floor(log2((b - a) / epsilon) - 1) + 2;
    for k=1:N
        if (f(x) == 0)
            break;
        end
        
        if (f(a) * f(x) < 0)
            b = x;
        else 
            a = x;
        end
        
        x = (a + b) / 2;
    end
    
    x_aprox = x;
end