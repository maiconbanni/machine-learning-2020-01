WITH VISAO_GERAL AS (
  SELECT
      ENEM.SG_UF_RESIDENCIA
    , ENEM.NU_IDADE
    , ENEM.TP_SEXO
    , ENEM.TP_ESTADO_CIVIL
    , ENEM.TP_COR_RACA
    , ENEM.TP_ST_CONCLUSAO
    , ENEM.TP_ANO_CONCLUIU
    , ENEM.TP_ENSINO
    ,  CASE WHEN ( ENEM.TP_ENSINO = 1 
       OR ( ENEM.Q026 = 'A' AND ENEM.NU_IDADE <=21) 
       OR ( ENEM.TP_ANO_CONCLUIU <= 1 AND ENEM.NU_IDADE <= 21 )
       OR ( ENEM.TP_ANO_CONCLUIU <= 2 AND ENEM.NU_IDADE <= 22 )
       OR ( ENEM.TP_ANO_CONCLUIU <= 3 AND ENEM.NU_IDADE <= 23 )
      )  THEN 1 ELSE 0 END AS TIPO_ENSINO
    , ENEM.Q001
    , ENEM.Q002
    , ENEM.Q003
    , ENEM.Q004
    , ENEM.Q005
    , ENEM.Q006
    , ENEM.Q008
    , ENEM.Q012
    , ENEM.Q025
    , ENEM.Q026
    , ENEM.Q027
    , CASE WHEN ENEM.Q006 = 'A' THEN ROUND(( 1 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'B' THEN ROUND(( 1 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'C' THEN ROUND(( 1.5 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'D' THEN ROUND(( 2 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'E' THEN ROUND(( 2.5 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'F' THEN ROUND(( 3 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'G' THEN ROUND(( 4 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'H' THEN ROUND(( 5 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'I' THEN ROUND(( 6 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'J' THEN ROUND(( 7 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'K' THEN ROUND(( 8 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'L' THEN ROUND(( 9 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'M' THEN ROUND(( 10 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'N' THEN ROUND(( 12 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'O' THEN ROUND(( 15 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'P' THEN ROUND(( 20 * 954 ) / ENEM.Q005)
           WHEN ENEM.Q006 = 'Q' THEN ROUND(( 50 * 954 ) / ENEM.Q005)
      END RENDA_PERCAPTA
    , ENEM.TP_LINGUA
    , (( ENEM.NU_NOTA_CN + ENEM.NU_NOTA_CH + ENEM.NU_NOTA_LC + ENEM.NU_NOTA_MT + ENEM.NU_NOTA_REDACAO ) / 5 ) AS MEDIA_GERAL
  FROM MICRODADOS_ENEM_2018 ENEM
  WHERE ENEM.TP_NACIONALIDADE IN (1,2) -- BRASILEIRO NATIVO E BRASILEIRO NATURALIZADO
  AND   ENEM.TP_COR_RACA <> 0 -- DADO INFORMADO
  AND   ENEM.TP_ESTADO_CIVIL IS NOT NULL  -- DADO INFORMADO
  AND   ( ENEM.NU_NOTA_CN IS NOT NULL AND ENEM.NU_NOTA_CN > 0 )
  AND   ( ENEM.NU_NOTA_CH IS NOT NULL AND ENEM.NU_NOTA_CH > 0 )
  AND   ( ENEM.NU_NOTA_LC IS NOT NULL AND ENEM.NU_NOTA_LC > 0 )
  AND   ( ENEM.NU_NOTA_MT IS NOT NULL AND ENEM.NU_NOTA_MT > 0 )
  AND   ( ENEM.NU_NOTA_REDACAO IS NOT NULL AND ENEM.NU_NOTA_REDACAO > 0 )
  AND   ENEM.TP_PRESENCA_CN = 1 
  AND   ENEM.TP_PRESENCA_CH = 1
  AND   ENEM.TP_PRESENCA_LC = 1
  AND   ENEM.TP_PRESENCA_MT = 1
  AND   ( ENEM.IN_TREINEIRO = 0 OR ENEM.IN_TREINEIRO IS NULL ) -- NAO ESTA FAZENDO A PROVA APENAS PARA TREINAR
  AND   ENEM.Q027 <> 'F' AND ENEM.Q026 <> 'D'
) SELECT
      V.SG_UF_RESIDENCIA                                                        AS UF_RESIDENCIA
    , CASE 
      WHEN V.SG_UF_RESIDENCIA 
           IN ('RO','AC','AM','RR','PA','AP','TO') THEN 'NORTE'
      WHEN V.SG_UF_RESIDENCIA
           IN ('MA','PI','CE','RN','PB','PE','AL','SE','BA') THEN 'NORDESTE'
           WHEN V.SG_UF_RESIDENCIA IN ('MG','ES','RJ','SP') THEN 'SUDESTE'
           WHEN V.SG_UF_RESIDENCIA IN ('PR','SC','RS') THEN 'SUL'
           WHEN V.SG_UF_RESIDENCIA IN ('MS','MT','GO','DF') THEN 'CENTRO-OESTE'
           END                                                                  AS REGIAO    
    , CASE WHEN V.NU_IDADE <= 14 THEN '0'
           WHEN V.NU_IDADE IN (15,16) THEN '1'
           WHEN V.NU_IDADE =  17 THEN '2'
           WHEN V.NU_IDADE =  18 THEN '3'
           WHEN V.NU_IDADE =  19 THEN '4'
           WHEN V.NU_IDADE =  20 THEN '5'
           WHEN V.NU_IDADE IN (21,22) THEN '6'
           WHEN V.NU_IDADE >= 23 THEN '7'
           END                                                                  AS FAIXA_ETARIA
    , CASE WHEN V.TP_SEXO = 'M' THEN 1 ELSE 0 END                               AS SEXO
    , CASE WHEN V.TP_ESTADO_CIVIL = 0 THEN 1 ELSE 0 END                         AS ESTADO_CIVIL
    , CASE WHEN V.TP_COR_RACA IN (1,4) THEN 0
          WHEN V.TP_COR_RACA IN (2,3) THEN 1
          WHEN V.TP_COR_RACA = 5      THEN 2
          END                                                                   AS COR_RACA
    , CASE WHEN V.TP_ST_CONCLUSAO = 1 THEN 1 ELSE 0 END                         AS ENSINO_CONCLUIDO
    , V.TP_LINGUA                                                               AS IDIOMA
    , V.TIPO_ENSINO                                                             AS ENSINO_REGULAR
    , CASE WHEN ( V.Q001 IN ('A','B','C','D','H')
            AND   V.Q002 IN ('A','B','C','D','H') ) THEN '0' -- FUNDAMENTAL
           WHEN ( V.Q001 IN ('F','G') OR V.Q002 IN ('F','G')) THEN '2' -- SUPERIOR
           ELSE '1' -- MEDIO
           END                                                                  AS ESCOLARIDADE_DOS_PAIS
    , CASE 
        WHEN RENDA_PERCAPTA <  250  THEN 0 -- 'ATE 249'
        WHEN RENDA_PERCAPTA BETWEEN 250 AND 499  THEN 1 -- 'ENTRE 250 E 499'
        WHEN RENDA_PERCAPTA BETWEEN 500 AND 749  THEN 2 -- 'ENTRE 500 E 999'
        WHEN RENDA_PERCAPTA BETWEEN 750 AND 999  THEN 3 -- 'ENTRE 500 E 999'
        WHEN RENDA_PERCAPTA BETWEEN 1000 AND 1499  THEN 4 -- 'ENTRE 1000 E 1499'
        WHEN RENDA_PERCAPTA BETWEEN 1500 AND 2499  THEN 5 -- 'ENTRE 1500 E 2499'
        WHEN RENDA_PERCAPTA BETWEEN 2500 AND 4999  THEN 6 -- 'ENTRE 2500 E 4999'
        WHEN RENDA_PERCAPTA >= 5000 THEN 7 -- 'MAIOR DE 2500'
      END                                                                       AS FAIXA_RENDA_PERCAPTA
    , CASE WHEN V.Q025 = 'A' THEN 0 ELSE 1 END                                  AS TEM_INTERNET
    , CASE WHEN ((V.Q026 = 'B' AND V.TP_ANO_CONCLUIU = 0 ) 
                 OR V.TP_ANO_CONCLUIU = 1 ) THEN 1 ELSE 0 END                   AS RECEM_FORMADO
    , CASE WHEN V.Q027 = 'A' THEN 0
           WHEN V.Q027 = 'B' THEN 1
		   ELSE 2
      END                                                                       AS ENSINO_PUBLICO
    , CASE 
        WHEN V.MEDIA_GERAL <  450  THEN 'INSUFICIENTE'
        WHEN V.MEDIA_GERAL >= 450 AND V.MEDIA_GERAL < 650  THEN 'REGULAR'
        WHEN V.MEDIA_GERAL >= 650 THEN 'EXCELENTE'
      END                                                                       AS RENDIMENTO_GERAL
FROM VISAO_GERAL V;