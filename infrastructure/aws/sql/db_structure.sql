/********************************/
/*********Criar de Tabelas*******/
/********************************/
DROP VIEW IF EXISTS vw_movimento_flat;
DROP TABLE IF EXISTS movimento;
DROP TABLE IF EXISTS cartao;
DROP TABLE IF EXISTS conta;
DROP TABLE IF EXISTS associado;

CREATE TABLE associado(
	id INT NOT NULL,
	nome VARCHAR(20) NOT NULL,
	sobrenome VARCHAR(50) NOT NULL,
	idade INT NOT NULL,	
	email VARCHAR(50) NOT NULL,	
	CONSTRAINT associado_pkey PRIMARY KEY (id));

CREATE TABLE conta (
	id INT NOT NULL,
	tipo CHAR(2) NOT NULL COMMENT "CC = Conta Corrente, CP = Conta Poupança",
	data_criacao DATETIME NOT NULL,
    id_associado INT NOT NULL,
	CONSTRAINT conta_pkey PRIMARY KEY (id),
    CONSTRAINT conta_associado_fkey FOREIGN KEY (id_associado) REFERENCES associado (id),
    CONSTRAINT tipo_check CHECK (tipo IN ('CC', 'CP'))
);

CREATE TABLE cartao (
	id INT NOT NULL,
	num_cartao INT NOT NULL,
	nom_impresso VARCHAR(100) NOT NULL,
    id_conta INT NOT NULL,
    id_associado INT NOT NULL,
	data_criacao DATETIME DEFAULT NOW(),
	CONSTRAINT cartao_pkey PRIMARY KEY (id),
    CONSTRAINT cartao_conta_fkey FOREIGN KEY (id_conta) REFERENCES conta (id),
    CONSTRAINT cartao_associado_fkey FOREIGN KEY (id_associado) REFERENCES associado (id)
);

CREATE TABLE movimento (
	id INT NOT NULL,	
	valor_transacao NUMERIC (10,2) NOT NULL,
    des_transacao VARCHAR(255) NOT NULL,
	data_movimento DATETIME NOT NULL,
    id_cartao INT NOT NULL,    
	CONSTRAINT movimento_pkey PRIMARY KEY (id),
    CONSTRAINT movimento_cartao_fkey FOREIGN KEY (id_cartao) REFERENCES cartao (id)
);

/********************************/
/*******Inserir Registros*******/
/*******************************/

/**Associado**/
INSERT INTO associado values(1,'Jose','Santos Silva',45,'jose.santos@gmail.com');
INSERT INTO associado values(2,'Maria','Pereira',36,'maria_p@outlook.com');
INSERT INTO associado values(3,'Joao','Gomes Souza',25,'jgomes@techsystem.com,br');
INSERT INTO associado values(4,'William','Henry Gates',67,'bill@microsoft.com');
INSERT INTO associado values(5,'Jacques','Jobs Sicredi ',40,'jacques@sicredi.com.br');


/**Conta**/
INSERT INTO conta values(1,'CC','2022-02-28 09:00:00',1);
INSERT INTO conta values(2,'CP','2021-03-19 11:00:00',2);
INSERT INTO conta values(3,'CP','2020-04-20 15:00:00',3);
INSERT INTO conta values(4,'CC','2019-05-21 10:00:00',4);
INSERT INTO conta values(5,'CC','2018-06-23 13:00:00',5);


/**Cartão**/
INSERT INTO cartao (id,num_cartao, nom_impresso, id_conta, id_associado) values(1, 40778,'Jose S Silva',1,1);
INSERT INTO cartao (id,num_cartao, nom_impresso, id_conta, id_associado) values(2, 39505,'Maria Pereira',2,2);
INSERT INTO cartao (id,num_cartao, nom_impresso, id_conta, id_associado) values(3, 28403,'Joao Sousa',3,3);
INSERT INTO cartao (id,num_cartao, nom_impresso, id_conta, id_associado) values(4, 19999,'William H Gates',4,4);
INSERT INTO cartao (id,num_cartao, nom_impresso, id_conta, id_associado) values(5, 12493,'Jacques Jobs',5,5);


/**Movimento**/
INSERT INTO movimento values(1, 4499.50,'PS5', '2022-03-30  05:00:00', 1);
INSERT INTO movimento values(2, 14.99,'Cenoura Kg','2022-01-29  09:00:00',2);
INSERT INTO movimento values(3, 3499.00,'Curso Eng. de Dados','2021-11-19 13:00:00',3);
INSERT INTO movimento values(4, 10.00,'Pão Francês','2022-02-10  14:00:00',4);
INSERT INTO movimento values(5, 99.99,'Academia','2022-02-03  15:00:00',5);

/********************************/
/****Criar ou Modificar View****/
/*******************************/

create or replace view vw_movimento_flat as
select ass.nome as nome_associado,
	   ass.sobrenome as sobrenome_associado,
	   ass.idade  as idade_associado,
	   mov.valor_transacao  as vlr_tansacao_movimento,
	   mov.des_transacao as des_transacao_movimento,
	   DATE_FORMAT(mov.data_movimento, '%d/%m/%Y') as data_movimento,
	   car.num_cartao as numero_cartao,
	   car.nom_impresso as nome_impresso_cartao,
	   DATE_FORMAT(car.data_criacao, '%d/%m/%Y') as data_criacao_cartao,	   
	   con.tipo as tipo_conta,
	   DATE_FORMAT(con.data_criacao, '%d/%m/%Y') as data_criacao_conta	   
from associado ass
inner join conta con
	on ass.id = con.id_associado 
inner join cartao car
	on con.id  = car.id_conta 
	and ass.id  = car.id_associado 
inner join movimento mov
	on car.id  = mov.id_cartao 
;