-- Limpeza dos dados
-----------------------------------------------------------------------

SELECT *
FROM SQLPortfolio.dbo.habitacao_fortaleza


-----------------------------------------------------------------------
-- Padronizando o formato de data


ALTER TABLE SQLPortfolio.dbo.habitacao_fortaleza
ADD Data_atualizada Date;

Update SQLPortfolio.dbo.habitacao_fortaleza
SET Data_atualizada = CONVERT(Date,Data_venda)

SELECT Data_atualizada, Data_venda
FROM SQLPortfolio.dbo.habitacao_fortaleza


-----------------------------------------------------------------------
-- Dados de endereços


SELECT *
FROM SQLPortfolio.dbo.habitacao_fortaleza
ORDER BY ParcelID


SELECT a.ParcelID, a.Endereco, b.ParcelID, b.Endereco, ISNULL(a.Endereco,b.Endereco)
FROM SQLPortfolio.dbo.habitacao_fortaleza a
JOIN SQLPortfolio.dbo.habitacao_fortaleza b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.Endereco IS NULL

UPDATE a
SET Endereco = ISNULL(a.Endereco,b.Endereco)
FROM SQLPortfolio.dbo.habitacao_fortaleza a
JOIN SQLPortfolio.dbo.habitacao_fortaleza b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.Endereco is NULL

SELECT Endereco
FROM SQLPortfolio.dbo.habitacao_fortaleza
WHERE Endereco is NULL


-------------------------------------------------------------------------
-- Dividindo o endereço completo em colunas individuais (endereço, cidade, estado)


SELECT Endereco
FROM SQLPortfolio.dbo.habitacao_fortaleza


ALTER TABLE SQLPortfolio.dbo.habitacao_fortaleza
ADD rua NVARCHAR(255);

UPDATE SQLPortfolio.dbo.habitacao_fortaleza
SET rua = SUBSTRING(Endereco, 1, CHARINDEX(',', Endereco)-1) 


ALTER TABLE SQLPortfolio.dbo.habitacao_fortaleza
ADD Cidade NVARCHAR(255);

UPDATE SQLPortfolio.dbo.habitacao_fortaleza
SET Cidade = SUBSTRING(Endereco, CHARINDEX(',', Endereco) +1 , LEN(Endereco)) 

SELECT rua, Cidade
FROM SQLPortfolio.dbo.habitacao_fortaleza


-- Endereço do Proprietário

SELECT Endereco_proprietario
FROM SQLPortfolio.dbo.habitacao_fortaleza


ALTER TABLE SQLPortfolio.dbo.habitacao_fortaleza
ADD Endereco_proprietario_rua NVARCHAR(255);

UPDATE SQLPortfolio.dbo.habitacao_fortaleza
SET Endereco_proprietario_rua = PARSENAME(REPLACE(Endereco_proprietario, ',', '.') , 3)


ALTER TABLE SQLPortfolio.dbo.habitacao_fortaleza
ADD Endereco_proprietario_cidade NVARCHAR(255);

UPDATE SQLPortfolio.dbo.habitacao_fortaleza
SET Endereco_proprietario_cidade = PARSENAME(REPLACE(Endereco_proprietario, ',', '.') , 2)


ALTER TABLE SQLPortfolio.dbo.habitacao_fortaleza
ADD Endereco_proprietario_estado NVARCHAR(255);

UPDATE SQLPortfolio.dbo.habitacao_fortaleza
SET Endereco_proprietario_estado = PARSENAME(REPLACE(Endereco_proprietario, ',', '.') , 1)


------------------------------------------------------------------------------
-- Alterando "S" para "Sim" e "N" para "Não" no campo "Vendido como vago"

SELECT DISTINCT status_venda
FROM SQLPortfolio.dbo.habitacao_fortaleza


UPDATE SQLPortfolio.dbo.habitacao_fortaleza
SET status_venda = CASE WHEN status_venda = 'Y' THEN 'Yes'
	WHEN status_venda = 'N' THEN 'No'
	ELSE status_venda
	END


	
-------------------------------------------------------------------------------
-- Removendo itens duplicados

WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                Endereco,
				Preco,
				Data_venda,
				Referencia
				ORDER BY
				   ID
				   ) row_num

FROM SQLPortfolio.dbo.habitacao_fortaleza
)
--SELECT *
DELETE
FROM RowNUMCTE
WHERE row_num > 1
--ORDER BY Endereco

----------------------------------------------------------------
-- Deletando colunas não utilizadas


SELECT *
FROM SQLPortfolio.dbo.habitacao_fortaleza

ALTER TABLE SQLPortfolio.dbo.habitacao_fortaleza
DROP COLUMN Data_venda, Endereco_proprietario, TaxDistrict, Endereco
