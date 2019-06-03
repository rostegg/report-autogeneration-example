function X=Riccati(A,G,Q)
n=size(A,1);
Z=[A -G
    -Q -A'];
[U1,S1]=schur(Z);
[U,S]=ordschur(U1,S1,'lhp');
X=U(n+1:end,1:n)*U(1:n,1:n)^-1;