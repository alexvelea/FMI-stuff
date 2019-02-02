function gauss()
    A = [
            1 0 1; ...
            0 1 2; ...
            3 2 1
        ];
    b = [4; 8; 10];
%{
    A = [
            0 1 1; ...
            2 1 5; ...
            4 2 1
        ];
    b = [3; 5; 1];
%}

    SubsDesc([3 2 1;0 1 2; 0 0 2], [10; 8; 6]);
    x_1 = GaussFaraPivotare(A, b);
    x_2 = GaussCuPivotarePartiala(A, b);
    x_3 = GaussCuPivotareTotala(A, b);
    
    x_1
    Check(A, x_1, b, 1e-4)
    
    x_2
    Check(A, x_2, b, 1e-4)
    
    x_3
    Check(A, x_3, b, 1e-4)
end

% checks if the equation is ok, with a gives precision
function ok = Check(A, x, b, eps)
    a = A * x;
    ok = true;
    for i=1:size(a,1)
        if (a(i) - eps < b(i) && b(i) < a(i) + eps)
        else
            ok = false;
        end
    end
end

% metoda substitutiei descendente
% primeste o matrice superior triunghiulara asociata unui
% sistem superior triunghiular si returneaza un vector 
% reprezentand solutia sistemului
function x_ans = SubsDesc(A, b)
    [num_rows] = size(A, 1);
    x_ans = zeros(num_rows, 1);
    for i=num_rows:-1:1
        x_ans(i) = b(i);
        for j=(i+1):num_rows
            x_ans(i) = x_ans(i) - A(i, j) * x_ans(j);
        end
        x_ans(i) = x_ans(i) / A(i, i);
    end
end

function x_ans = GaussFaraPivotare(A, b)
    [n] = size(A, 1);
    Ap = [A b];

    % pt fiecare linie
    for k=1:n
        % cautam k <= p <= n a.i. Ap(p, k) != 0
        p = NaN;
        for j=k:n
            if (A(j, k) ~= 0)
                p = j;
                break;
            end
        end

        if (isnan(p))
            x_ans = NaN;
            return
        end

        % facem swap intre linii
        aux = Ap(k,:);
        Ap(k,:) = Ap(p,:);
        Ap(p,:) = aux;

        % facem 0 pe coloana K pe liniile K+1 ... n
        for i=(k+1):n
            coef = Ap(i,k) / Ap(k,k);
            Ap(i,:) = Ap(i,:) - coef * Ap(k,:);
        end
    end

    x_ans = SubsDesc(Ap(:,1:n), Ap(:,n+1));
end

function x_ans = GaussCuPivotarePartiala(A, b)
    [n] = size(A, 1);
    Ap = [A b];

    % pt fiecare linie
    for k=1:n
        % cautam k <= p <= n a.i. Ap(p, k) != 0
        p = NaN;
        max_val = 0;
        for j=k:n
            if (abs(A(j, k)) > max_val)
                p = j;
                max_val = abs(A(j, k));
            end
        end

        if (isnan(p))
            x_ans = NaN;
            return
        end

        % facem swap intre linii
        aux = Ap(k,:);
        Ap(k,:) = Ap(p,:);
        Ap(p,:) = aux;

        % facem 0 pe coloana K pe liniile K+1 ... n
        for i=(k+1):n
            coef = Ap(i,k) / Ap(k,k);
            Ap(i,:) = Ap(i,:) - coef * Ap(k,:);
        end
    end

    x_ans = SubsDesc(Ap(:,1:n), Ap(:,n+1));
end

function x_ans = GaussCuPivotareTotala(A, b)
    [n] = size(A, 1);
    Ap = [A b];
    
    swaps = zeros(n, 1);

    % pt fiecare linie
    for k=1:n
        % cautam k <= p <= n a.i. Ap(p, k) != 0
        p = NaN;
        q = NaN;
        max_val = 0;
        for j=k:n
            for l=k:n
                if (abs(A(j, l)) > max_val)
                    p = j;
                    q = l;
                    max_val = abs(A(j, l));
                end
            end
        end

        
        if (isnan(p))
            x_ans = NaN;
            return
        end
        % facem swap intre linii
        aux = Ap(k,:);
        Ap(k,:) = Ap(p,:);
        Ap(p,:) = aux;
        
        % facem swap intre coloane
        aux = Ap(:,k);
        Ap(:,k) = Ap(:,q);
        Ap(:,q) = aux;
        
        % setam swapurile
        swaps(k) = q;

        % facem 0 pe coloana K pe liniile K+1 ... n
        for i=(k+1):n
            coef = Ap(i,k) / Ap(k,k);
            Ap(i,:) = Ap(i,:) - coef * Ap(k,:);
        end
    end

    x_ans = SubsDesc(Ap(:,1:n), Ap(:,n+1));
    
    % punem swapurile pe x
    for i=n:-1:1
        q = swaps(i);
        % facem swap intre coloane
        aux = x_ans(i);
        x_ans(i) = x_ans(q);
        x_ans(q) = aux;
    end
end