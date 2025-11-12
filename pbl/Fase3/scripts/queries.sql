-- ==================================================
-- PBL FASE 3: ANÁLISE DE DADOS DA TABELA COLHEITA
-- Banco de Dados: Oracle 11g
-- Data: 11/11/2025
-- ==================================================

-- *** QUERY 1: Contagem Total de Registros ***
-- Objetivo: Validar que todos os 1000 registros foram importados com sucesso
-- Resultado esperado: 1000 registros
SELECT COUNT(*) AS Total_Registros FROM COLHEITA;

-- *** QUERY 2: Primeiros 10 Registros ***
-- Objetivo: Visualizar amostra dos dados importados e confirmar integridade
-- Resultado esperado: 10 linhas com dados variados e consistentes
SELECT * FROM COLHEITA WHERE ROWNUM <= 10;

-- *** QUERY 3: Resumo dos Dados Importados ***
-- Objetivo: Obter visão executiva dos dados importados
-- Mostra: total de registros, período coberto, médias de umidade e temperatura
-- Resultado esperado: 1000 registros, datas entre 01/01/2024 e ~11/02/2024
SELECT 
    COUNT(*) AS total_registros,
    MIN(DATA_HORA) AS primeira_data,
    MAX(DATA_HORA) AS ultima_data,
    ROUND(AVG(SOLO_UMIDADE), 2) AS umidade_media,
    ROUND(AVG(SOLO_TEMPERATURA), 2) AS temperatura_media
FROM COLHEITA;

-- *** QUERY 4: Umidade Média do Solo ***
-- Objetivo: Analisar variação de umidade do solo durante o período
-- Calcula: média, máximo e mínimo de umidade em percentual (%)
-- Resultado esperado: Umidade média ~65%, máximo ~90%, mínimo ~20%
SELECT 
    ROUND(AVG(SOLO_UMIDADE), 2) AS umidade_media,
    ROUND(MAX(SOLO_UMIDADE), 2) AS umidade_maxima,
    ROUND(MIN(SOLO_UMIDADE), 2) AS umidade_minima,
    COUNT(*) AS total_registros
FROM COLHEITA;

-- *** QUERY 5: Temperatura do Solo ***
-- Objetivo: Estatísticas de temperatura do solo
-- Calcula: média, máximo e mínimo em graus Celsius (°C)
-- Resultado esperado: Temp média ~20-25°C, máximo ~30-35°C, mínimo ~10-15°C
SELECT 
    ROUND(AVG(SOLO_TEMPERATURA), 2) AS temp_media,
    ROUND(MAX(SOLO_TEMPERATURA), 2) AS temp_maxima,
    ROUND(MIN(SOLO_TEMPERATURA), 2) AS temp_minima,
    COUNT(*) AS total_registros
FROM COLHEITA;

-- *** QUERY 6: Registros por Data ***
-- Objetivo: Análise diária de umidade e temperatura
-- Agrupa por data e calcula médias para cada dia
-- Mostra: Top 15 datas mais recentes com maior detalhe
SELECT 
    DATA_HORA AS data_leitura,
    COUNT(*) AS total_leituras,
    ROUND(AVG(SOLO_UMIDADE), 2) AS umidade_media_dia,
    ROUND(AVG(SOLO_TEMPERATURA), 2) AS temp_media_dia
FROM COLHEITA
GROUP BY DATA_HORA
ORDER BY DATA_HORA DESC
FETCH FIRST 15 ROWS ONLY;

-- *** QUERY 7: Períodos Críticos de Baixa Umidade (< 30%) ***
-- Objetivo: Identificar momentos críticos que necessitam irrigação urgente
-- Filtra: Registros com umidade menor que 30% (limiar crítico)
-- Mostra: Data, umidade do solo, temperatura, umidade do ar e status de irrigação
-- Resultado esperado: Múltiplos registros com umidade baixa
SELECT 
    DATA_HORA,
    SOLO_UMIDADE,
    SOLO_TEMPERATURA,
    AR_UMIDADE,
    IRRIGADO
FROM COLHEITA
WHERE SOLO_UMIDADE < 30
ORDER BY SOLO_UMIDADE ASC
FETCH FIRST 15 ROWS ONLY;

-- *** QUERY 8: Efetividade da Irrigação ***
-- Objetivo: Comparar condições do solo em períodos com e sem irrigação
-- Agrupa por: status de irrigação (1 = ligada, 0 = desligada)
-- Calcula: umidade média, temperatura média e umidade do ar média para cada estado
-- Resultado esperado: Diferença visível entre períodos com/sem irrigação
SELECT 
    IRRIGADO,
    COUNT(*) AS total_registros,
    ROUND(AVG(SOLO_UMIDADE), 2) AS umidade_media,
    ROUND(AVG(SOLO_TEMPERATURA), 2) AS temperatura_media,
    ROUND(AVG(AR_UMIDADE), 2) AS ar_umidade_media
FROM COLHEITA
GROUP BY IRRIGADO;

-- *** QUERY 9: Precipitação vs Umidade do Solo ***
-- Objetivo: Validar correlação entre chuva e umidade do solo
-- Filtra: Registros com precipitação maior que 1mm
-- Mostra: Data, precipitação, umidade, temperatura, velocidade do vento
-- Resultado esperado: Demonstra impacto da chuva na umidade
SELECT 
    DATA_HORA,
    PRECIPITACAO,
    SOLO_UMIDADE,
    SOLO_TEMPERATURA,
    VENTO_VELOCIDADE
FROM COLHEITA
WHERE TO_NUMBER(PRECIPITACAO) > 1
ORDER BY SOLO_UMIDADE DESC
FETCH FIRST 15 ROWS ONLY;

-- *** QUERY 10: Análise por Horário do Dia ***
-- Objetivo: Identificar padrões de umidade e temperatura por horário
-- Agrupa por: hora do dia (0-23h)
-- Calcula: total de leituras, umidade média, temperatura média para cada hora
-- Resultado esperado: Padrões visíveis (ex: umidade mais alta à noite)
SELECT 
    EXTRACT(HOUR FROM TO_DATE(DATA_HORA, 'DD/MM/YYYY')) AS hora_do_dia,
    COUNT(*) AS total_leituras,
    ROUND(AVG(SOLO_UMIDADE), 2) AS umidade_media,
    ROUND(AVG(SOLO_TEMPERATURA), 2) AS temperatura_media
FROM COLHEITA
GROUP BY EXTRACT(HOUR FROM TO_DATE(DATA_HORA, 'DD/MM/YYYY'))
ORDER BY EXTRACT(HOUR FROM TO_DATE(DATA_HORA, 'DD/MM/YYYY'));

-- *** QUERY 11: Eventos de Irrigação com Contexto Ambiental ***
-- Objetivo: Analisar contexto completo quando sistema de irrigação foi acionado
-- Filtra: Registros onde IRRIGADO = 1 (sistema ligado)
-- Mostra: Umidade do solo, umidade do ar, pressão, radiação solar, vento
-- Resultado esperado: Entender condições que acionam irrigação automática
SELECT 
    DATA_HORA,
    SOLO_UMIDADE,
    AR_UMIDADE,
    PRESSAO_ATMOSFERICA,
    RADIACAO_SOLAR,
    VENTO_VELOCIDADE,
    IRRIGADO
FROM COLHEITA
WHERE IRRIGADO = 1
ORDER BY DATA_HORA DESC
FETCH FIRST 15 ROWS ONLY;

-- *** QUERY 12: Resumo Consolidado - Dashboard Executivo ***
-- Objetivo: Visão completa e consolidada de toda a campanha de colheita
-- Calcula: Total de registros, eventos de irrigação, médias gerais de parâmetros
-- Resultado esperado: KPIs principais para análise executiva
SELECT 
    COUNT(*) AS total_registros,
    COUNT(CASE WHEN IRRIGADO = 1 THEN 1 END) AS vezes_irrigado,
    ROUND(AVG(SOLO_UMIDADE), 2) AS umidade_media_geral,
    ROUND(AVG(SOLO_TEMPERATURA), 2) AS temperatura_media_geral,
    ROUND(AVG(AR_UMIDADE), 2) AS umidade_ar_media,
    ROUND(AVG(PH), 2) AS ph_medio
FROM COLHEITA;

-- ==================================================
-- FIM DO SCRIPT DE QUERIES
-- ==================================================
