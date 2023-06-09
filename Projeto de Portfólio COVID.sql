/*
Explorando os dados do COVID 19 com SQL

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continente IS NOT NULL 
ORDER BY 3,4


-- Fazendo o primeiro SELECT

SELECT localização, data, total_casos, novos_casos, total_mortes, populacao
FROM PortfolioProject..CovidDeaths
WHERE continente is NOT NULL
ORDER BY 1,2


-- Fazendo a análise do total de casos versus o total de mortes e mostrando a probabilidade de morrer se você contrair covid no meu país (Brasil)

SELECT localização, data, total_casos, total_mortes, ROUND((total_mortes/total_casos)*100, 2) AS taxa de morte
FROM PortfolioProject..CovidDeaths
WHERE localização='Brazil'
ORDER BY 1,2


-- Total de casos vs populacao, mostrando o percentual da população no país que pegou COVID

SELECT localização, data, total_casos, populacao, ROUND((total_casos/populacao)*100, 5) AS Casos por populacao
FROM PortfolioProject..CovidDeaths
--WHERE localização='Brazil'
ORDER BY 1,2


-- Paises com maior taxa de contaminação em relação a sua população

SELECT localização, populacao, MAX(total_casos) AS Maior quantidade de infeccoes, ROUND(MAX((total_casos/populacao))*100,2) AS Perc populacao infectada
FROM PortfolioProject..CovidDeaths
--WHERE localização='Brazil'
GROUP BY localização, populacao
ORDER BY Perc populacao infectada DESC


-- Paises com maior taxa de morte em relação a sua população

SELECT localização, MAX(CAST(total_mortes AS int)) AS Total mortes
FROM PortfolioProject..CovidDeaths
WHERE continente IS NOT NULL
GROUP BY localização
ORDER BY Total mortes DESC


-- Análise por continente

-- continentes com maior número de mortes por população

SELECT continente, MAX(CAST(total_mortes AS int)) AS Total mortes
FROM PortfolioProject..CovidDeaths
WHERE continente IS NOT NULL
GROUP BY continente
ORDER BY Total mortes DESC



-- Dados globais e vacinacao

SELECT data, SUM(novos_casos) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, ROUND((SUM(cast(new_deaths AS int))/SUM(novos_casos))*100, 2) AS taxa de morte
FROM PortfolioProject..CovidDeaths
WHERE continente is NOT NULL
GROUP BY data
ORDER BY 1,2


-- Total populacao vs Vacinacao: Percentual da populacao que recebeu pelo menos 1 dose da vacina

SELECT dea.continente, dea.localização, dea.data, dea.populacao, vax.novas_vacinas
, SUM(CONVERT(int,vac.novas_vacinas)) OVER (Partition by dea.localização Order by dea.localização, dea.data) as Pessoas vacinadas
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinacao vax
	ON dea.localização = vax.localização
	AND dea.data = vax.data
WHERE dea.continente IS NOT NULL
ORDER BY 2,3



-- Usando CTE para realizar cálculo na partição por consulta

WITH populacaovsVacinacao (continente, localização, data, populacao, novas_vacinas, Pessoas vacinadas)
AS
(
SELECT dea.continente, dea.localização, dea.data, dea.populacao, vax.novas_vacinas, SUM(CONVERT(int,vax.novas_vacinas)) OVER (Partition by dea.localização ORDER BY dea.localização, dea.data) AS Pessoas vacinadas
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.localização = vax.localização
	and dea.data = vax.data
WHERE dea.continente is NOT NULL 
)
SELECT *, ROUND((Pessoas vacinadas/populacao)*100,2) AS Percentual
FROM populacaovsVacinacao


DROP Table if exists #Perc_populacao_vacinada
Create Table #Perc_populacao_vacinada
(
continente nvarchar(255),
localização nvarchar(255), 
data datatime, 
populacao numeric, 
novas_vacinas numeric, 
Pessoas vacinadas numeric
)

INSERT INTO #Perc_populacao_vacinada
SELECT dea.continente, dea.localização, dea.data, dea.populacao, vax.novas_vacinas, SUM(CONVERT(int,vax.novas_vacinas)) OVER (Partition by dea.localização ORDER BY dea.localização, dea.data) AS Pessoas vacinadas
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.localização = vax.localização
	and dea.data = vax.data
WHERE dea.continente is NOT NULL 

SELECT *, ROUND((Pessoas vacinadas/populacao)*100,2) AS Percentual
FROM #Perc_populacao_vacinada


-- Criando uma view

CREATE View Perc_populacao_vacinada as
SELECT dea.continente, dea.localização, dea.data, dea.populacao, vax.novas_vacinas, SUM(CONVERT(int,vax.novas_vacinas)) OVER (Partition by dea.localização ORDER BY dea.localização, dea.data) AS Pessoas vacinadas
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.localização = vax.localização
	and dea.data = vax.data
WHERE dea.continente is NOT NULL 
