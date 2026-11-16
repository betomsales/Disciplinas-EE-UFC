function arquivoZIP = gerar_ilustracoes(pasta_saida)
% Gera as oito figuras do Projeto Final e prepara o ZIP para download.
% Uso: arquivoZIP = gerar_ilustracoes;
% Dados: capitulos 4 e 5. Correntes em A; tempos em s; diferencial em pu.
% Exportacao: mathworks.com/help/matlab/ref/exportgraphics.html
if nargin < 1, pasta_saida = pwd; end
if ~isfolder(pasta_saida), mkdir(pasta_saida); end

% Colunas: RTC, TAP secundario, dial e aditivo de tempo.
% Dial do primario AT = 0,68, definido pela falta bifasica na MT (Dyn1).
fase = [40 3.13 .33 0; 80 4.10 .38 0; ...
        160 .41 .68 0; 240 .32 .64 .45];
neutro = [40 .60 .65 0; 80 .75 .65 .45; 40 1.50 .65 .90; ...
          160 .38 .33 0; 240 .50 .33 .45];
nomesF = {'51 alimentador','51 geral MT', ...
          '51 primário AT','51 entrada AT'};
nomesN = {'51N alimentador','51N geral MT','51G neutro do transformador', ...
          '51N primário AT','51N entrada AT'};
I3 = 2882.7; I1 = 2918.4; I3AT = 15683.2; I1AT = 10575.5;
RTT = 5;
Ip50 = [40*57.66, 40*58.37, 160*6.24, 160*1.25];
nomes = {'01_coordenograma_fase_MT','02_coordenograma_neutro_MT', ...
    '03_coordenograma_fase_AT','04_coordenograma_neutro_AT', ...
    '05_diagramas_tempo_MT','06_diagramas_tempo_barra_AT', ...
    '07_diagrama_falha_disjuntor','08_caracteristica_diferencial'};
f = gobjects(1,8);

% Tempos de referencia; as correntes AT de fase mantiveram 576,5 A.
correntesF = [I3 I3 576.5 576.5];
correntesN = [I1 I1 I1 I1AT I1AT];
tF = zeros(1,4); tN = zeros(1,5);
for k = 1:4, tF(k) = tempo51(correntesF(k),fase(k,:)); end
for k = 1:5, tN(k) = tempo51(correntesN(k),neutro(k,:)); end
tRet = tempo51(337,fase(3,:));
% Pici: contribuicoes proprias; 51N foi extrapolacao C2 sem patamar.
tPCI = 13.5*.12/(15179.3/1161.6-1);
tPCIN = 13.5*.55/(10235.1/160.8-1);
esperados = [.202272348 .658644851 1.178719906 1.777900740 ...
             .302586207 .752586207 1.202586207 .153620690 .603620690];
assert(max(abs([tF tN]-esperados)) < 1e-8, ...
    'Os tempos diferem dos valores de referencia.');
% Falta bifasica na MT: o primario em triangulo ve 2/sqrt(3) da corrente
% refletida, ou seja, os mesmos 576,5 A da falta trifasica.
I2 = sqrt(3)/2*I3;
tGeral2F = tempo51(I2,fase(2,:));
tAT2F = tempo51(2/sqrt(3)*I2/RTT,fase(3,:));
assert(tAT2F - tGeral2F >= .40 - 1e-3, ...
    'Margem geral-primario insuficiente na falta bifasica.');

% Estagios instantaneos por linha de fase/neutro: [pick-up primario no
% proprio vao (A), atraso (s)]; NaN = estagio desabilitado.
inst50F = [Ip50(1) .10; NaN NaN; Ip50(3) .05; NaN NaN];
inst50N = [Ip50(2) .10; NaN NaN; NaN NaN; Ip50(4) .05; NaN NaN];
rotF = {'50/51 alimentador (50: pré-ajuste)','51 geral MT (50 desabilitado)', ...
        '50/51 primário AT','51 entrada AT (50 desabilitado)'};
rotN = {'50N/51N alimentador (50N: pré-ajuste)','51N geral MT (50N desabilitado)', ...
        '51G neutro do transformador','50N/51N primário AT', ...
        '51N entrada AT (50N desabilitado)'};

% 1 e 2: coordenogramas 50/51 na base de media tensao.
% O eixo vai alem do curto maximo para mostrar o 50 AT (4.992 A na MT).
f(1) = coordenograma('Coordenograma 50/51 de fase — base de 13,8 kV', ...
    [110 7000],fase,inst50F,[1 1 RTT RTT],rotF,{},I3,'I_{cc,3\phi} máx. MT');
rodape(f(1),{'Curvas C2 com degrau do estágio 50 quando habilitado. O 50 da saída é pré-ajuste de alcance.', ...
    '50 AT = 4.992 A referidos à MT, acima do curto máximo de 2.882,7 A: não atua para faltas na MT.'});
f(2) = coordenograma('Coordenograma 50N/51N de neutro — base de 13,8 kV', ...
    [10 4000],neutro(1:3,:),inst50N(1:3,:),[1 1 1],rotN(1:3), ...
    {15.2,60,'51NS: verificar desequilíbrio',':'},I1,'I_{cc,1\phi} máx. MT');
rodape(f(2),{'51NS depende da verificação do desequilíbrio; 50N da saída é pré-ajuste de alcance.', ...
    'As curvas residuais de 69 kV foram representadas separadamente.'});

% 3 e 4: coordenogramas 50/51 AT; o ponto PCI representou a falta de barra.
for k = 3:4
    if k == 3
        p = fase(3:4,:); inst = inst50F(3:4,:); rotulos = rotF(3:4);
        imax = I3AT; tipo = '50/51 de fase'; rotIcc = 'I_{cc,3\phi} máx. AT';
        tp = tPCI; legendaPCI = '51 PCI: referência para a falta na barra';
    else
        p = neutro(4:5,:); inst = inst50N(4:5,:); rotulos = rotN(4:5);
        imax = I1AT; tipo = '50N/51N de neutro'; rotIcc = 'I_{cc,1\phi} máx. AT';
        tp = tPCIN; legendaPCI = '51N PCI: estimativa analítica, M > 30';
    end
    f(k) = coordenograma(['Coordenograma ' tipo ' — base de 69 kV'], ...
        [40 1.3*imax],p,inst,[1 1],rotulos,{},imax,rotIcc);
    plot(imax,tp,'kx','MarkerSize',9,'LineWidth',2,'DisplayName',legendaPCI);
    legend('show','Location','northeast');
    rodape(f(k),{'A participação de cada vão depende da localização da falta.', ...
        'O ponto PCI usa sua contribuição própria. Proteção de distância não modelada.'});
end

% 5 e 6: tempos contados desde o inicio de uma falta persistente.
f(5) = novafigura([22 19]);
diagrama(f(5),1,'Falta trifásica próxima à saída', ...
    [{'50 saída: condicional'} nomesF],[.10 tF],2);
diagrama(f(5),2,'Falta fase-terra próxima à saída', ...
    {'50N saída: condicional','51N alimentador','51N geral MT', ...
     '51G transformador','51 fase AT: retaguarda'},[.10 tN(1:3) tRet],2.5);
rodape(f(5),{'Tempos nominais para falta persistente; os estágios 50/50N da saída dependem de liberação.', ...
    'Não foram somados tempos desconhecidos de comunicação e interrupção dos disjuntores.'});
f(6) = novafigura([22 17]);
diagrama(f(6),1,'Falta trifásica na barra de 69 kV', ...
    {'51 PCI','51 entrada 12L1'},[tPCI tempo51(I3AT,fase(4,:))],.9);
diagrama(f(6),2,'Falta fase-terra na barra de 69 kV', ...
    {'51N PCI: estimativa','51N entrada 12L1'},[tPCIN tN(5)],.7);
rodape(f(6),{'A referência PCI antecede a entrada nos eventos apresentados.', ...
    '51N PCI é extrapolação analítica. Não foi demonstrada seletividade integral em 69 kV.'});

% 7: atraso BF de 0,25 s contado apos o comando TR.
f(7) = novafigura([21 13]);
a = axes('Parent',f(7),'Position',[.27 .25 .68 .60]); hold(a,'on');
tr = [.10 tF(1)];
for k = 1:2
    plot([0 tr(k)],[k k],'-','Color',[0 .35 .70],'LineWidth',3);
    plot([tr(k) tr(k)+.25],[k k],'-','Color',[.85 .33 .10],'LineWidth',3);
    plot(tr(k),k,'kv','MarkerFaceColor','k');
    plot(tr(k)+.25,k,'ks','MarkerFaceColor','w');
    text(tr(k)+.26,k,sprintf('BF: %.3f s',tr(k)+.25),'FontSize',9);
end
set(a,'YDir','reverse','YTick',1:2, ...
    'YTickLabel',{'TR por 50: condicional','TR por 51'});
xlim([0 .65]); ylim([.5 2.5]); grid on;
xlabel('Tempo desde o início da falta (s)');
title('Falha do disjuntor de saída');
rodape(f(7),{'Azul: intervalo até TR. Laranja: atraso BF de 0,25 s após TR.', ...
    'Foi pressuposta corrente persistente. Comunicação e abertura a montante não foram somadas.'});

% 8: fronteira estatica; HS1 de pico nao foi desenhado como limite eficaz.
f(8) = novafigura([23 13]);
InMT = 6.25e6/(sqrt(3)*13.8e3);
externas = [I1/sqrt(3) I3]/InMT;
for k = 1:2
    a = subplot(1,2,k,'Parent',f(8)); hold(a,'on');
    limites = [12 10; 2 1.5];
    r = unique([linspace(0,limites(k,1),1200) 2/3 1]);
    d = limite87(r);
    fill([r fliplr(r)],[d zeros(size(d))],[.90 .96 .93], ...
        'EdgeColor','none','HandleVisibility','off');
    fill([r fliplr(r)],[d limites(k,2)*ones(size(d))],[.99 .92 .93], ...
        'EdgeColor','none','HandleVisibility','off');
    plot(r,d,'Color',[0 .35 .70],'LineWidth',1.8,'DisplayName','Fronteira estática');
    if k == 1
        plot(externas,[0 0],'o','Color',[.1 .55 .28], ...
            'MarkerFaceColor',[.1 .55 .28],'DisplayName','Faltas externas ideais');
        title('Domínio das faltas externas');
    else
        title('Detalhe da sensibilidade');
    end
    plot(1,0,'ks','MarkerFaceColor','w','DisplayName','Carga ONAF ideal');
    plot(.5,1,'rd','MarkerFaceColor','r','DisplayName','Falta interna exemplificativa');
    xlim([0 limites(k,1)]); ylim([-.04 limites(k,2)]);
    xlabel('I_r máximo entre fases (pu ONAF)'); ylabel('I_d por fase (pu ONAF)');
    legend('show','Location','northwest'); box on;
    pos = a.Position; a.Position = [pos(1) .24 pos(3) .62];
end
rodape(f(8),{'P642 sensível: Is1 = 0,20 pu; K1 = 30%; Is2 = 1,00 pu; K2 = 80%.', ...
    'Verde: restrição estática. Rosa: operação potencial, sujeita aos bloqueios e à restrição transitória.'});
arquivoZIP = exportar(f,nomes,pasta_saida);
end

function t = tempo51(I,p)
% C2: sem partida em I <= Ip; patamar em multiplo 30.
M = I/(p(1)*p(2));
t = 13.5*p(3)./(min(M,30)-1)+p(4);
t(M<=1) = NaN;
end

function d = limite87(r)
% Patamar de 0,20 pu, primeira inclinacao 30% e segunda 80%.
d = max(.20,.30*r);
d(r>1) = .30+.80*(r(r>1)-1);
end

function f = novafigura(tamanho)
f = figure('Color','w','Units','centimeters','Position',[2 2 tamanho]);
set(f,'DefaultAxesFontName','Times New Roman', ...
    'DefaultTextFontName','Times New Roman','DefaultAxesFontSize',10);
end

function t = tempo5051(I,p,inst)
% Curva combinada: C2 da 51 e degrau de tempo definido da 50 a partir
% do seu pick-up; inst = [Ip50 t50] no mesmo vao, NaN se desabilitado.
t = tempo51(I,p);
if ~isnan(inst(1))
    m = I >= inst(1);
    t(m) = min(t(m),inst(2));
end
end

function f = coordenograma(titulo,faixa,p,inst,escala,rotulos,extras,icc,rotIcc)
% A escala converte apenas a base de corrente do grafico.
f = novafigura([20 15]);
a = axes('Parent',f,'Position',[.13 .23 .82 .65]);
set(a,'XScale','log','YScale','log','XMinorGrid','on','YMinorGrid','on');
hold(a,'on'); grid(a,'on'); box(a,'on');
I = unique([logspace(log10(faixa(1)),log10(faixa(2)),1800) ...
    inst(~isnan(inst(:,1)),1)'.*escala(~isnan(inst(:,1)))]);
cores = [0 .35 .70; .85 .33 .10; .1 .55 .28; .49 .18 .56];
for k = 1:size(p,1)
    plot(I,tempo5051(I/escala(k),p(k,:),inst(k,:)), ...
        'Color',cores(k,:),'LineWidth',1.6,'DisplayName',rotulos{k});
end
for k = 1:size(extras,1)
    t = extras{k,2}*ones(size(I)); t(I<extras{k,1}) = NaN;
    plot(I,t,extras{k,4},'Color',[.4 .4 .4], ...
        'LineWidth',1.6,'DisplayName',extras{k,3});
end
plot([icc icc],[.025 100],'--','Color',[.55 .55 .55],'LineWidth',1, ...
    'DisplayName',sprintf('%s = %s A',rotIcc,milhar(icc)));
xlim(faixa); ylim([.025 100]); title(titulo);
xlabel('Corrente primária na base indicada (A)'); ylabel('Tempo nominal (s)');
legend('show','Location','northeast');
end

function s = milhar(x)
% Formato brasileiro: 2882.7 -> '2.882,7'.
s = strrep(sprintf('%.1f',x),'.',',');
inteiro = regexprep(extractBefore(s,','),'(\d)(?=(\d{3})+$)','$1.');
s = [inteiro ',' extractAfter(s,',')];
end

function diagrama(f,k,titulo,rotulos,t,xmax)
a = subplot(2,1,k,'Parent',f);
barh(a,1:numel(t),t,.6,'FaceColor',[.13 .39 .64]);
set(a,'YDir','reverse','YTick',1:numel(t),'YTickLabel',rotulos);
xlim(a,[0 xmax]); grid(a,'on'); title(a,titulo);
xlabel(a,'Tempo nominal desde o início da falta (s)');
for j = 1:numel(t)
    text(a,t(j)+.015*xmax,j,sprintf('%.3f s',t(j)),'FontSize',9);
end
a.Position = [.31 .16+(k==1)*.44 .62 .28];
end

function rodape(f,nota)
annotation(f,'textbox',[.05 .015 .91 .11],'String',nota, ...
    'EdgeColor','none','FontName','Times New Roman','FontSize',8);
end

function destino = exportar(figuras,nomes,pasta_saida)
% Exporta no disco temporario, valida e so depois copia o ZIP.
imformats('factory');
origem = tempname; mkdir(origem);
arquivos = cell(1,16); dados = cell(1,16);
for k = 1:8
    figure(figuras(k)); drawnow; pause(1);
    for j = 1:2
        extensoes = {'.png','.pdf'}; n = 2*(k-1)+j;
        arquivos{n} = [nomes{k} extensoes{j}];
        caminho = fullfile(origem,arquivos{n});
        if j == 1
            exportgraphics(figuras(k),caminho,'Resolution',300,'BackgroundColor','white');
        else
            exportgraphics(figuras(k),caminho,'ContentType','vector','BackgroundColor','white');
        end
        dados{n} = ler(caminho);
        if j == 1
            assert(numel(dados{n})>=8 && isequal(dados{n}(1:8), ...
                uint8([137;80;78;71;13;10;26;10])),'PNG invalido: %s',caminho);
            imagem = imread(caminho);
            assert(~isempty(imagem),'PNG vazio: %s',caminho);
        else
            b = dados{n};
            assert(numel(b)>=8 && isequal(b(1:5),uint8('%PDF-')'), ...
                'Cabecalho PDF invalido: %s',caminho);
            assert(contains(char(b(max(1,numel(b)-4095):end)'),'%%EOF'), ...
                'PDF incompleto: %s',caminho);
        end
    end
end
pacote = [tempname '.zip']; zip(pacote,arquivos,origem);
conferencia = tempname; mkdir(conferencia); unzip(pacote,conferencia);
for k = 1:16
    assert(isequal(ler(fullfile(conferencia,arquivos{k})),dados{k}), ...
        'O ZIP alterou o arquivo %s.',arquivos{k});
end
[~,id] = fileparts(origem);
destino = fullfile(pasta_saida,['Ilustracoes_Verificadas_' id '.zip']);
copyfile(pacote,destino);
assert(isequal(ler(pacote),ler(destino)),'Falha ao copiar o ZIP para download.');
fprintf('\nOito figuras exportadas e ZIP conferido:\n%s\n',destino);
fprintf('No MATLAB Online: Files > botao direito no ZIP > Download.\n');
fprintf('Extraia o ZIP no computador antes de abrir os PDFs e PNGs.\n');
end

function b = ler(arquivo)
fid = fopen(arquivo,'rb');
assert(fid~=-1,'Nao foi possivel ler %s.',arquivo);
fechar = onCleanup(@() fclose(fid));
b = fread(fid,Inf,'*uint8');
end
