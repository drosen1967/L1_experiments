% Brief L1 recovery test

n = 100;
m = 60;

trials = 100;
s_range = 1:1:40;
errors = [];

options  = IRfista('defaults');
options.shrink = 'on';
options.RegParam = .1;
options.IterBar = 'off';

for i = s_range
    cummulative_error = 0;
    for j = 1:trials
        A = randn(m,n);
        on = randsample(n,i);
        x = zeros(n,1);
        x(on) = rand(i,1);
        b = A * x;
        x_rec = IRfista(A,b, options);
        cummulative_error = cummulative_error + norm(x - x_rec)/norm(x);
    end
    errors(end + 1) = cummulative_error/trials;
end
semilogy(errors);
xlabel("L_0 norm");
ylabel(sprintf("Average norm error ratio over %d trials", trials));
title(sprintf("Basic L1 weighted Recovery for n=%d, m=%d", n,m));