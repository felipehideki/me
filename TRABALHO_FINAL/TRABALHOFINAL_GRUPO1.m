% % TRABALHO FINAL DE ENGENHARIA MÉDICA 2S/2020
% % GRUPO 1

% % CLASSIFICAÇÃO DE INDIVÍDUOS SAUDÁVEIS/DOENTES DE UM BANCO DE DADOS DE
% % AUSCULTAÇÕES TORÁXICAS



% % EXTRAINDO INÍCIO E FINAL DOS CICLOS RESPIRATÓRIOS EM CADA GRAVAÇÃO
pathname = 'C:\Users\$USER$\Desktop\EngenhariaMedica\TRABALHOFINAL\Respiratory_Sound_Database\Respiratory_Sound_Database\audio_and_txt_files';

S = dir(fullfile(pathname,'*.txt'));
outtxt = cell(size(S));
w = waitbar(0,'Importando arquivos .txt');
for k = 1:numel(S)
    waitbar(k/numel(S));
    filename = S(k).name;
    filepath = fullfile(pathname,filename);
    outtxt{k} = load(filepath);
end
delete(w);
clear filename filepath k S w

S = dir(fullfile(pathname,'*.wav'));
ciclos = cell(size(S));
fs = zeros(size(S));
w = waitbar(0,'Importando arquivos .wav');
for k = 1:numel(S)
    waitbar(k/numel(S));
    filename = S(k).name;
    filepath = fullfile(pathname,filename);
    [dados,fs(k)] = audioread(filepath);
    for i = 1:size(outtxt{k},1)
        if floor(outtxt{k}(i,1)*fs(k))
            ciclos{k,i} = dados((floor(outtxt{k}(i,1)*fs(k))):(ceil(outtxt{k}(i,2)*fs(k))));
        else %caso o primeiro índice do ciclo seja 0
            ciclos{k,i} = dados(1:(ceil(outtxt{k}(i,2)*fs(k))));
        end
    end
end
delete(w);
clear dados filename filepath i k w outtxt

T = readtable('C:\Users\$USER$\Desktop\EngenhariaMedica\TRABALHOFINAL\Respiratory_Sound_Database\Respiratory_Sound_Database\patient_diagnosis.csv');
w = waitbar(0,'Relacionando classes');
classes_all = table;
for j = 1:size(S)
    waitbar(j/numel(S));
    id = S(j).name;
    for m = 1:size(T,1)
        if sum(id(1:3)==num2str(T.Var1(m)))==3
            classes_all.Var1(j,1) = T.Var2(m);
        end
    end
end
delete(w);
clear id j m pathname S T w
            

% % EXTRAÇÃO DE CARACTERÍSTICAS PRINCIPAIS
media = zeros(size(ciclos));
variancia = zeros(size(ciclos));
mobilidade = zeros(size(ciclos));
complexidade = zeros(size(ciclos));
freq_central = zeros(size(ciclos));
largura_banda = zeros(size(ciclos));
freq_margem = zeros(size(ciclos));

w = waitbar(0,'Extraindo características');
for i=1:size(ciclos,1)
    waitbar(i/size(ciclos,1));
    for j=1:size(ciclos,2)
        if isempty(ciclos{i,j})
            break;
        else
            [media(i,j),variancia(i,j),mobilidade(i,j),complexidade(i,j),freq_central(i,j),largura_banda(i,j),freq_margem(i,j)] = PRINCIPAIS_CARACTERISTICAS(ciclos{i,j}',fs(i));
        end
    end
end
delete(w);
clear i j w ciclos fs

% % ORGANIZANDO DADOS
w = waitbar(0,'Organizando dados');
classes = table;
dados = zeros(sum(sum(media~=0)),7);
indice = 1;
for i=1:size(classes_all,1)
    waitbar(i/size(classes_all,1));
    j = 1;
    while j<34
        if media(i,j)~=0
            classes.Var1(indice,1) = classes_all.Var1(i);
            dados(indice,1) = media(i,j);
            dados(indice,2) = variancia(i,j);
            dados(indice,3) = mobilidade(i,j);
            dados(indice,4) = complexidade(i,j);
            dados(indice,5) = freq_central(i,j);
            dados(indice,6) = largura_banda(i,j);
            dados(indice,7) = freq_margem(i,j);
            indice = indice+1;
            j = j+1;
        else
            break;
        end
    end
end
delete(w);
clear classes_all media variancia mobilidade complexidade freq_central largura_banda freq_margem indice i j w