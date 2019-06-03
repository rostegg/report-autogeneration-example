warning off;
digits(3)
W = tf([8.6], [0.0648, 0.54 1]);
Q = [1 0; 0 2];
dataToSave.originalQ11 = Q(1,1);
dataToSave.originalQ22 = Q(2,2);
R = 10;
dataToSave.originalR = R;
disp("________________SS (input)_______________")
ss(W)
A = ans.A;
B = ans.B;
C = ans.C;

dataToSave.a11 = A(1,1);
dataToSave.a12 = A(1,2);
dataToSave.a21 = A(2,1);
dataToSave.a22 = A(2,2);
dataToSave.b11 = B(1,1);
dataToSave.b21 = B(2,1);
dataToSave.c11 = C(1,1);
dataToSave.c12 = C(1,2);

disp("________________P (with rank)_______________")
P = [B A*B]
rank(P)

dataToSave.p11 = P(1,1);
dataToSave.p12 = P(1,2);
dataToSave.p21 = P(2,1);
dataToSave.p22 = P(2,2);

% intermediate calculation for Riccati equation
% uncomment above for usage

unknK = sym('k',[2 2]);
disp("________________-^K*A_______________")
tmpFirst = vpa(-unknK * A)
dataToSave.temporaryFirst11 = char(tmpFirst(1,1));
dataToSave.temporaryFirst12 = char(tmpFirst(1,2));
dataToSave.temporaryFirst21 = char(tmpFirst(2,1));
dataToSave.temporaryFirst22 = char(tmpFirst(2,2));

disp("________________-A^T*^K_______________")
tmpSecond = vpa(-A'*unknK)
dataToSave.temporarySecond11 = char(tmpSecond(1,1));
dataToSave.temporarySecond12 = char(tmpSecond(1,2));
dataToSave.temporarySecond21 = char(tmpSecond(2,1));
dataToSave.temporarySecond22 = char(tmpSecond(2,2));

disp("________________^K*B*r^-1*B^T*^K_______________")
tmpThird = vpa(unknK*B*R^-1*B'*unknK)
dataToSave.temporaryThird11 = char(tmpThird(1,1));
dataToSave.temporaryThird12 = char(tmpThird(1,2));
dataToSave.temporaryThird21 = char(tmpThird(2,1));
dataToSave.temporaryThird22 = char(tmpThird(2,2));

disp("________________Riccati matrix_______________")
eqMatrix = vpa(tmpFirst + tmpSecond + tmpThird - Q)
dataToSave.riccatiMatrix11 = char(eqMatrix(1,1));
dataToSave.riccatiMatrix12 = char(eqMatrix(1,2));
dataToSave.riccatiMatrix21 = char(eqMatrix(2,1));
dataToSave.riccatiMatrix22 = char(eqMatrix(2,2));


disp("________________^K_______________")
G = B*R^-1*B';
circumK = Riccati(A,G,Q)

dataToSave.riccatiResult11 = circumK(1,1);
dataToSave.riccatiResult12 = circumK(1,2);
dataToSave.riccatiResult21 = circumK(2,1);
dataToSave.riccatiResult22 = circumK(2,2);

disp("________________G_______________")
G = R^-1*B'*circumK

dataToSave.backPropG11 = G(1,1);
dataToSave.backPropG12 = G(1,2);

disp("________________g (using lqr)_______________")
g = lqr(A,B,Q,R)

% substitution of parameters section
% uncomment above for usage
%{
%}

%backup values
backup.Q = Q;
backup.R = R;
backup.g = g;

g1 = g(1);
g2 = g(2);
q11 = Q(1,1);
q22 = Q(2,2);

% first table
delta = 1;
dMatrixG = [
    g1 g2;
    more(g1, delta) g2;
    less(g1, delta) g2;
    g1 more(g2, delta);
    g1 less(g2, delta);
    more(g1, delta) more(g2, delta);
    less(g1, delta) less(g2, delta);
    more(g1, delta) less(g2, delta);
    less(g1, delta) more(g2, delta);
    ];

sz = [9 3];
varTypes = {'double','double','double'};
varNames = {'g1','g2','J'};
table1 = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
index=1;
disp(' ')
disp("________________STARTED_SUBSTITUTION_FOR_TABLE1_______________")
for row = dMatrixG.'
    try
        g1 = row(1);
        g2 = row(2);
        dataToSave.(strcat('table1Row',int2str(index),'g1')) = g1;
        dataToSave.(strcat('table1Row',int2str(index),'g2')) = g2;
        sim('model_regulator');
        j = J.Data(end);
        r = {g1,g2,j};
        dataToSave.(strcat('table1Row',int2str(index),'J')) = j;
        table1(index,:) = r;
        dataToSave.addprop('table1Row'+index+'g1');
        index=index+1;
    catch
        j = J.Data(end);
        r = {g1,g2,j};
        dataToSave.(strcat('table1Row',int2str(index),'J')) = j;
        table1(index,:) = r;
        index=index+1;
        fprintf('Inconsistent data in g1 = %s, g2 = %s; skipped.\n', vpa(g1), vpa(g2));
        
    end
    
end
disp(' ')
disp("________________TABLE1_______________")
table1;
disp(' ')
disp("________________TABLE1_END_______________")


% restore from backup
g1 = backup.g(1);
g2 = backup.g(2);

% second table

delta = 10;
dMatrixQR = [
    q11 q22 R;
    moreMul(q11, delta) moreMul(q22, delta) R;
    lessDiv(q11, delta) lessDiv(q22, delta) R;
    q11 q22 moreMul(R, delta);
    q11 q22 lessDiv(R, delta);
    moreMul(q11, delta) moreMul(q22, delta) moreMul(R, delta);
    lessDiv(q11, delta) lessDiv(q22, delta) lessDiv(R, delta);
    moreMul(q11, delta) moreMul(q22, delta) lessDiv(R, delta);
    lessDiv(q11, delta) lessDiv(q22, delta) moreMul(R, delta);
    ];

sz = [9 4];
varTypes = {'double','double','double','double'};
varNames = {'g1','g2','J','T'};
table2 = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
index=1;
disp(' ')
disp("________________STARTED_SUBSTITUTION_FOR_TABLE2_______________")
for row = dMatrixQR.'
    try
        % init params
        Q = [row(1) 0; 0 row(2)];
        R = row(3);
        g = lqr(A,B,Q,R);
        
        g1 = g(1);
        g2 = g(2);
        q11 = row(1);
        q22 = row(2);
        
        dataToSave.(strcat('table2Row',int2str(index),'g1')) = g1;
        dataToSave.(strcat('table2Row',int2str(index),'g2')) = g2;
        
        sim('model_regulator');
        
        j = J.Data(end);
        t = J.Time(end);
        r = {g1,g2,j,t};
        dataToSave.(strcat('table2Row',int2str(index),'J')) = j;
        dataToSave.(strcat('table2Row',int2str(index),'T')) = t;
        table2(index,:) = r;
        index=index+1;
    catch
        j = J.Data(end);
        t = J.Time(end);
        r = {g1,g2,j,t};
        dataToSave.(strcat('table2Row',int2str(index),'J')) = j;
        dataToSave.(strcat('table2Row',int2str(index),'T')) = t;
        table2(index,:) = r;
        index=index+1;
        fprintf('Inconsistent data in g1 = %s, g2 = %s; skipped.\n', vpa(g1), vpa(g2));
        
    end
    
end
disp(' ')
disp("________________TABLE2_______________")
table2
disp(' ')
disp("________________TABLE2_END_______________")

% restore from backup
Q = backup.Q;
R = backup.R;
g = backup.g;
g1 = g(1);
g2 = g(2);
q11 = Q(1,1);
q22 = Q(2,2);

jsonString = jsonencode(dataToSave);
fid = fopen('model_data.json', 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonString, 'char');
fclose(fid);

