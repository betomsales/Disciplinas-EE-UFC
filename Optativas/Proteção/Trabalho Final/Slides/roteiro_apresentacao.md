# Roteiro da apresentação

Foram preparados 10 slides, incluindo a capa, para uma exposição estimada em **13min30s**, com reserva de **1min30s** até o limite de 15 minutos. A duração efetiva dependerá do ensaio e da fala dos apresentadores.

| Slide | Tema | Tempo | Acumulado | Ponto principal da fala |
| --- | --- | --- | --- | --- |
| 1 | Capa | 0:30 | 0:30 | Equipe, instalação e objetivo. |
| 2 | Sistema e premissas | 1:30 | 2:00 | Um transformador em serviço, outro em reserva; curtos fornecidos preservados. |
| 3 | Dimensionamento dos TCs | 1:30 | 3:30 | Três critérios; 1200/5 na entrada e 800/5 nos primários. |
| 4 | Curva e ajustes de fase | 1:30 | 5:00 | C2, limite de múltiplo 30 e função do aditivo de tempo. |
| 5 | Coordenação de fase | 1:30 | 6:30 | Curvas combinadas; 51 do primário em 1,179 s; margem geral–primário de aproximadamente 0,403 s na falta bifásica Dyn1. |
| 6 | Coordenação de neutro | 1:15 | 7:45 | Tempos de 0,303 / 0,753 / 1,203 s; sequência zero não transferida pelo triângulo. |
| 7 | Proteção diferencial | 2:00 | 9:45 | Normalização, compensação e fronteira percentual; módulos sensíveis e limitações transitórias. |
| 8 | Falha de disjuntor e religamento | 1:15 | 11:00 | A contagem de 0,25 s começou após TR; religamento bloqueado após 87T e 50BF. |
| 9 | Concessionária | 1:30 | 12:30 | Comparar 0,134 s e 0,748 s; a seletividade integral em 69 kV não foi demonstrada. |
| 10 | Conclusões | 1:00 | 13:30 | Resultados e verificações necessárias antes da implantação. |

## Uso e compilação

- O arquivo principal é document.tex; o PDF da apresentação é document.pdf.
- Foram mantidos a classe, as cores, o formato, o fundo e o rodapé do modelo UFC.
- A marca inferior foi mantida na capa; nos demais slides, foram mantidos a marca d'água e o rodapé.
- As notas de fala constam nos comandos de notas do arquivo .tex e ficaram ocultas no PDF.
- Os gráficos foram reutilizados da pasta Imagens do relatório e a bibliografia de referencias.bib, no diretório acima de Slides. Para compilar em outro computador, mantenha essa estrutura junto da pasta Slides.
- A compilação exigiu os pacotes do modelo UFC, incluindo fancybox, csquotes e footmisc, além de Beamer, TikZ e BibLaTeX/Biber.
- Execute, a partir da pasta Slides:

    pdflatex -interaction=nonstopmode -halt-on-error document.tex
    biber document
    pdflatex -interaction=nonstopmode -halt-on-error document.tex
    pdflatex -interaction=nonstopmode -halt-on-error document.tex

## Cuidados durante a exposição

- Os diagramas apresentaram tempos nominais para falta persistente, sem pressupor aberturas sucessivas de todos os disjuntores.
- O percentual de 80% da corrente de barra não comprovou alcance de 80% do comprimento dos alimentadores.
- O ponto de neutro de Pici foi uma extrapolação analítica; as funções de distância não foram substituídas por sobrecorrente.
- A curva diferencial representou condições estáticas; não foi apresentada como ensaio ou simulação transitória.
