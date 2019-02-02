% Fie ecuatia x^3 − 18x − 10 = 0.

function t18()
    % a) Intr-un fisier script sa se construiasca graficul functiei pe intervalul [−5, 5].
    %{
    Plot(@Evaluate, -5, +5, [], []);
    %}
    
    % c) Alegeti din grafic trei subintervale, astfel ıncat 
    %    pe fiecare subinterval sa fie respectate ipotezele 
    %    teoremei I.3. Aflati cele trei solutii apeland procedura 
    %    MetSecantei cu eroarea de aproximare ε = 10−3
    % Construiti punctele (xaprox, f(xaprox)) pe graficul functiei.
    %{
    x_sol_1 = MetodaSecantei(@Evaluate, -4, -3, -4, -3, 1e-3);
    x_sol_2 = MetodaSecantei(@Evaluate, -1, +1, -1, +1, 1e-3);
    x_sol_3 = MetodaSecantei(@Evaluate, +4, +5, +4, +5, 1e-3);
    
    Plot(@Evaluate, -5, +5, ...
        [x_sol_1, x_sol_2, x_sol_3], ...
        [Evaluate(x_sol_1), Evaluate(x_sol_2), Evaluate(x_sol_3)]);
    %}    
    
    % d) Alegeti din grafic trei subintervale, astfel ıncat 
    %     pe fiecare subinterval ecuatia f(x) = 0
    %     admite o solutie unica. Aflati cele trei solutii 
    %     apeland procedura MetPozFalse cu eroarea 
    %     de aproximare ε = 10−3
    % Construiti punctele (xaprox, f(xaprox)) pe graficul functiei.
    
    x_sol_1 = MetodaPozitieiFalse(@Evaluate, -4, -3, 1e-3);
    x_sol_2 = MetodaPozitieiFalse(@Evaluate, -1, +1, 1e-3);
    x_sol_3 = MetodaPozitieiFalse(@Evaluate, +4, +5, 1e-3);
    
    Plot(@Evaluate, -5, +5, ...
        [x_sol_1, x_sol_2, x_sol_3], ...
        [Evaluate(x_sol_1), Evaluate(x_sol_2), Evaluate(x_sol_3)]);
    
end

function answer = Evaluate(x)
    answer = x^3 - 18 * x - 10;
end

% Primim ca parametrii si niste puncte bonus pe care pe putem 
% Plota - x_bonus si y_bonus
% util pt afisarea solutiilor
function Plot(f, a, b, x_bonus, y_bonus)
    xi = linspace(a, b, 100);
    yi = arrayfun(f, xi);
    
    figure;
    hold on;
    
    plot(xi, yi);
    plot([a b], [0 0]); % punem si axa ox sa fie mai frumos
    plot(x_bonus, y_bonus, 'og');
    
    hold off;
end

% b) Sa se construiasca ın Matlab o procedura cu sintaxa 
%     [xaprox] = MetSecantei(f, a, b, x0, x1, ε)
%     conform algoritmului metodei secantei.
function x_aprox = MetodaSecantei(f, a, b, x_0, x_1, epsilon)
    x_aprox = NaN;
    while (abs(x_1 - x_0) / abs(x_1) >= epsilon)
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

% c) Sa se construiasca ın Matlab o procedura cu sintaxa 
%    [xaprox] = MetPozFalse(f, a, b, ε) 
%    conform algoritmului metodei pozitiei false.
function x_aprox = MetodaPozitieiFalse(f, a, b, epsilon)
    while true
        x = (a * f(b) - b * f(a)) / (f(b) - f(a));
        if (abs(f(x)) < epsilon)
            break;
        end
        
        if (f(a) * f(x) > 0)
            a = x;
        else
            b = x;
        end
    end
        
    x_aprox = x;
end