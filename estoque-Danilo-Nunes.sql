DROP DATABASE IF EXISTS estoque;

CREATE DATABASE estoque;

USE estoque;

CREATE TABLE produtos (
	id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    quantidade INT
);

CREATE TABLE log_estoque (
	id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT,
    quantidade_antiga INT,
    quantidade_nova INT,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* Trigger que cria um log da movimentacao da quantidade em estoque */
DELIMITER $$
CREATE TRIGGER after_log_estoque
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
	IF OLD.quantidade != NEW.quantidade THEN
		INSERT INTO log_estoque (id_produto, quantidade_antiga, quantidade_nova, data_alteracao) VALUES (OLD.id, OLD.quantidade, NEW.quantidade, NOW());
	END IF;
END $$
DELIMITER ;

INSERT INTO produtos VALUES (1, "Geladeira", 4);
UPDATE produtos SET quantidade = 10 WHERE id = 1;
SELECT * FROM log_estoque;

/* Funcao que resgata a quantidade em estoque de um determinado produto */
DELIMITER $$
CREATE FUNCTION get_quantidade_produto (id_produto INT)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE busca INT;
    SELECT quantidade FROM produtos WHERE id = id_produto INTO busca;
    RETURN busca;
END $$
DELIMITER ;

SELECT get_quantidade_produto(1) AS quantidade_estoque;

/* Procedure que atualiza o valor da quantidade de produto em estoque */
DELIMITER $$
CREATE PROCEDURE atualiza_quantidade (
	IN p_id INT, 
	IN p_nova_quantidade INT
)
BEGIN
	UPDATE produtos SET quantidade = p_nova_quantidade WHERE id = p_id;
    SELECT "Produto atualizado com sucesso" AS msg;
END $$
DELIMITER ;

CALL atualiza_quantidade(1, 12);
SELECT get_quantidade_produto(1);