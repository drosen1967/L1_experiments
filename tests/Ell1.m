% Brief L1 recovery test

n = 100;
m = 60;

trials = 5;
s_range = 1:1:40;
errors = [];
errorls = [];
% FISTA Options, 
options  = IRell1('defaults');
options.shrink = 'on'; % Apply iterative shrinking
options.IterBar = 'off';
options.RegParam = 1e-4;
options.MaxIter = 1000;
options.FlatTol = 1e-12;
options.MinTol = 100;
options.NoStop = 'on';

% Test FISTA for various levels of sparsity
for i = s_range
    cummulative_error = 0;
    cummulative_ls = 0;
    for j = 1:trials
        A = randn(m,n);
        on = randsample(n,i);
        x = zeros(n,1);
        x(on) = rand(i,1);
        b = A * x;
        x_rec = IRell1(A,b, options);
        x_ls = b\A;
        cummulative_error = cummulative_error + norm(x - x_rec)/norm(x);
        cummulative_ls = cummulative_ls + norm(x - x_ls)/norm(x);
    end
    errors(end + 1) = cummulative_error/trials;
    errorls(end + 1) = cummulative_ls/trials;
end

semilogy(s_range/n, errors, s_range/n, errorls);
xlabel("L_0 norm ratio");
ylabel(sprintf("Average norm error ratio over %d trials", trials));
title(sprintf("Basic L1 weighted Recovery for n=%d, m=%d", n,m));