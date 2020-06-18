function MetNewthonRaphson()
    F = @(x)(x*x*x -5*x*x -14*x +100);
    Solve(F, -3, +8);
end

function Solve(F, a, b)
    eps = 1e-5;
    f = F;
    f_dev = @(x)((f(x + eps) - f(x)) / (eps)); % derivative estimation
    f_dev_2 = @(x)((f_dev(x + eps) - f_dev(x)) / (eps)); % derivative estimation
    x_aprox = SolveMetNewthonRaphson(f_dev, f_dev_2, a, b, eps);
    
    x = linspace(a, b, 100);

    figure;
    hold on;
    plot(x, arrayfun(f, x)) % the graph of the function
    plot(x, arrayfun(f_dev, x)) % the graph of the derivative of function
    plot(x, arrayfun(f_dev_2, x)) % the graph of the derivative of function
    plot([x_aprox], [f(x_aprox)], 'or') % our intersection point
    plot([a b], [0 0]) % line x = 0
    hold off
end


function x_new = SolveMetNewthonRaphson(f, f_dev, a, b, epsilon)
    x_old = (a + b) / 2;

    while true
        x_new = x_old - f(x_old) / f_dev(x_old)
        
        if (abs(f(x_new)) < epsilon)
            break;
        end
        
        x_old = x_new;
    end
end