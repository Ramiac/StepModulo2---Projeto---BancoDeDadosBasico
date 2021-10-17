-- Projeto final materia Theoria de banco de dados
-- Criação dum BD por uma loja de Equipamento de escalada esportiva
-- Rami ACHCAR
/* DOCUMENTACAO:

##### PROCEDURES

novo_cliente(id, nome, cpf, cep, estado, endereco)
        -> Cria um novo cliente
alt_ender_cliente(id, cep, estado, endereco)
        -> o cliente tem novo endereco a cadastrar
deletar_cliente(id)
        -> desativa o cliente selecionado
novo_fabricante(id, nome, cnpj, estado, pais, tel)
        -> Cria um novo fabricante
deletar_fabricante(id)
        -> desativa o fabricante selecionado
alt_tel_fabricante(id, telefone)
        -> O Fabricante tem novo telefone a cadastrar
novo_produto(id, nome, categoria, valor_unit, id_fabricante)
        -> Cria novo produto
alt_valor_produto(id, valor 6.2)
        -> Alterar o valor de venda dum produto
deletar_produto(id)
        -> desativar um produto
novo_estoque(id_estoq, id_prod, quantidade)
        -> Criar um novo estoque dum produto (set produto ATIVO)
adic_quant(id, quant_adic)
        -> Adicionar quantidade dum produto (set produto ATIVO)
nova_venda(id, notaFiscal, id_produto, quantidade, id_cliente, dataVenda)
        -> Criar nova venda por produto (inclui atualizacao de quantiodade de produto na tablea do estoque)

###### FUNCTIONS
exibe_venda(num da nota fiscal)
        -> Mostra as vendas num nota fiscal
valor_nota(num da nota fiscal)
        -> Calcula valor total duma nota fiscal
estoque_prod(id do produto)
        -> mostra quantidade dum produto disponível no estoque
*/


CREATE DATABASE "rua do climb"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

-- ######### criação das tabelas e constraints

CREATE TABLE public.clientes
(
    id integer NOT NULL,
    nome character varying(40) NOT NULL,
    cpf character varying(11),
    cep character varying(9) NOT NULL,
    estado character varying(2) NOT NULL,
    endereco character varying(60) NOT NULL,
    ativo boolean DEFAULT False,
    PRIMARY KEY (id)
);

ALTER TABLE public.cliente
    OWNER to postgres;

CREATE TABLE public.vendas
(
    id integer NOT NULL,
    nota_fiscal character varying(6) NOT NULL,
    valor_total numeric(6, 2) NOT NULL,
    id_produto integer NOT NULL,
    quantidade integer NOT NULL,
    id_cliente integer NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE public.vendas
    OWNER to postgres;

CREATE TABLE public.produtos
(
    id integer NOT NULL,
    nome character varying(20) NOT NULL,
    categoria character varying(20) NOT NULL,
    valor_unit numeric(6, 2) NOT NULL,
    id_fabricante integer NOT NULL,
    ativo boolean DEFAULT True,
    PRIMARY KEY (id)
);

ALTER TABLE public.produtos
    OWNER to postgres;

CREATE TABLE public.fabricantes
(
    id integer NOT NULL,
    nome character varying(40) NOT NULL,
    cnpj character varying(18),
    estado character varying(2),
    pais character varying(20) NOT NULL,
    telefone character varying(25) NOT NULL,
    ativo boolean DEFAULT True,
    PRIMARY KEY (id)
);

ALTER TABLE public.fabricantes
    OWNER to postgres;

CREATE TABLE public.estoque
(
    id integer NOT NULL,
    id_produto integer NOT NULL,
    quantidade integer NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE public.estoque
    OWNER to postgres;

ALTER TABLE public.produtos
    ADD CONSTRAINT id_fabricante_fkey FOREIGN KEY (id_fabricante)
    REFERENCES public.fabricantes (id)
    ON UPDATE CASCADE


ALTER TABLE public.estoque
    ADD CONSTRAINT id_produto_fkey FOREIGN KEY (id_produto)
    REFERENCES public.produtos (id)
    ON UPDATE CASCADE


ALTER TABLE public.vendas
    ADD CONSTRAINT id_produto_fkey FOREIGN KEY (id_produto)
    REFERENCES public.produtos (id)
    ON UPDATE CASCADE

ALTER TABLE public.vendas
    ADD CONSTRAINT id_cliente_fkey FOREIGN KEY (id_cliente)
    REFERENCES public.clientes (id)
    ON UPDATE CASCADE

-- ######## criação dos procedures

-- Criar novo cliente
CREATE OR REPLACE PROCEDURE novo_cliente(
    IN id integer,
    IN nome character varying (40),
    IN cpf character varying (11),
    IN cep character varying (9),
    IN estado character varying (2),
    IN endereco character varying (60)
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    INSERT INTO public.clientes VALUES
    (id, nome, cpf, cep, estado, endereco);
END;
$BODY$;

-- Deletar cliente
CREATE OR REPLACE PROCEDURE deletar_cliente(
    IN cliente_id integer
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    UPDATE public.clientes
    SET ativo = False
    WHERE cliente_id = id;
END;
$BODY$

-- Alterar endereço dum cliente (cep, estado e endereço)
CREATE OR REPLACE PROCEDURE alt_ender_cliente(
    IN cliente_id integer,
    IN novo_cep character varying(9),
    IN novo_estado character varying(2),
    IN novo_ender character varying(60)
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    UPDATE public.clientes
    SET cep = novo_cep,
        estado = novo_estado,
        endereco = novo_ender
    WHERE id = cliente_id;

END;
$BODY$


-- Criar novo fabricante
CREATE OR REPLACE PROCEDURE novo_fabricante(
    IN id integer,
    IN nome character varying (40),
    IN cnpj character varying (18),
    IN estado character varying (2),
    IN pais character varying (20),
    IN telefone character varying(25)
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    INSERT INTO public.fabricantes VALUES
    (id, nome, cnpj, estado, pais, telefone);
END;
$BODY$;

-- Deletar fabricante
CREATE OR REPLACE PROCEDURE deletar_fabricante(
    IN fabr_id integer
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    UPDATE public.fabricantes
    SET ativo = False
    WHERE fabr_id = id;
END;
$BODY$

-- Alterar telefone dum fabricante
CREATE or REPLACE PROCEDURE alt_tel_fabricante(
    IN fabr_id integer,
    IN novo_tel character varying(25)
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    update public.fabricantes
    SET telefone = novo_tel
    WHERE id = fabr_id;
END;
$BODY$;

-- Criar novo produto
CREATE OR REPLACE PROCEDURE novo_produto(
    IN id integer,
    IN nome character varying (20),
    IN categoria character varying (20),
    IN valor_unit numeric (6, 2),
    IN id_fabricante integer
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    INSERT INTO public.produtos VALUES
    (id, nome, categoria, valor_unit, id_fabricante);
END;
$BODY$;

-- Aterar Valor unitario dum produto
CREATE or REPLACE PROCEDURE alt_valor_produto(
    IN prod_id integer,
    IN novo_valor numeric(6,2)
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    update public.produtos
    SET valor_unit = novo_valor
    WHERE id = prod_id;
END;
$BODY$;

-- Deletar produto
CREATE OR REPLACE PROCEDURE deletar_produto(
    IN prod_id integer
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    UPDATE public.produtos
    SET ativo = False
    WHERE prod_id = id;
END;
$BODY$

-- Criar novo estoque de produtos
CREATE OR REPLACE PROCEDURE novo_estoque(
    IN id_estoq integer,
    IN id_prod integer,
    IN quant integer
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    INSERT INTO public.estoque VALUES
    (id_estoq, id_prod, quant);

    UPDATE public.produtos
    SET ativo = True
    WHERE id_prod = id;
END;
$BODY$;

-- Adicionar quantidade dum produto no Estoque
CREATE OR REPLACE PROCEDURE adic_quant(
    IN id_prod integer,
    IN quant integer
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    UPDATE public.estoque
    SET quantidade = quantidade + quant
    WHERE id_produto = id_prod;

    UPDATE public.produtos
    SET ativo = True
    WHERE id_prod = id;
END;
$BODY$;

-- Criar uma nova venda
CREATE OR REPLACE PROCEDURE nova_venda(
    IN id_venda integer,
    IN nota_fiscal character varying(6),
    IN id_prod integer,
    IN quant_vendida integer,
    IN id_cliente integer,
    IN data date
)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
    INSERT INTO public.vendas VALUES
    (id_venda, nota_fiscal, id_prod, quant_vendida, id_cliente, data);

    UPDATE public.estoque
    SET quantidade = quantidade - quant_vendida
    WHERE id_produto = id_prod;

    UPDATE public.clientes
    SET ativo = True
    WHERE id_cliente = id;
END;
$BODY$;

-- Mostrar as vendas duma Nota Fiscal
CREATE OR REPLACE FUNCTION exibe_venda(
    IN nota_fisc character varying(6)
)
RETURNS table (
	"Nota Fiscal" Character Varying(6),
	"Produto" character varying(20),
	"Fabricante" character varying(40),
	"Quantidade vendida" integer,
    "Valor unitario" numeric (6,2),
	"Nome do cliente" character varying(40),
	"Data da venda" date
)
AS $$

BEGIN
RETURN QUERY
    SELECT 
        vendas.nota_fiscal,
        produtos.nome,
        fabricantes.nome,
        vendas.quantidade,
        produtos.valor_unit,
        clientes.nome,
        vendas.data
    FROM vendas 
    JOIN produtos ON produtos.id = vendas.id_produto
    JOIN clientes ON clientes.id = vendas.id_cliente
    JOIN fabricantes ON fabricantes.id = produtos.id_fabricante
    WHERE vendas.nota_fiscal = nota_fisc;

END;
$$ LANGUAGE 'plpgsql';

SELECT * from exibe_venda('222222')

-- valor total duma nota fiscal
CREATE OR REPLACE FUNCTION valor_nota(
    IN nota_fisc character varying(6)
)
RETURNS TABLE(
    "Nota Fiscal" Character Varying(6),
    "Nome do Cliente" character varying(40),
    "Valor Total" numeric (6, 2),
    "Data da venda" date
)

AS $$
BEGIN
RETURN QUERY
    SELECT
        vendas.nota_fiscal,
        clientes.nome,
        SUM(vendas.quantidade * produtos.valor_unit),
        vendas.data
    FROM vendas 
    JOIN produtos ON produtos.id = vendas.id_produto
    JOIN clientes ON clientes.id = vendas.id_cliente
    WHERE vendas.nota_fiscal = nota_fisc
	GROUP BY vendas.nota_fiscal, clientes.nome, vendas.data;
END;
$$ LANGUAGE 'plpgsql';

select * from valor_nota('222222')


-- mostrar situação de estoque dum produto
CREATE OR REPLACE FUNCTION estoque_prod(
    IN id_prod integer
)

RETURNS TABLE(
    "Produto" character varying(20),
    "Quantidade em estoque" integer
)

AS $$
BEGIN
RETURN QUERY
    SELECT
        produtos.nome,
        estoque.quantidade
    FROM estoque
    JOIN produtos ON produtos.id = estoque.id_produto
    WHERE produtos.id = id_prod;
END;
$$ language 'plpgsql';

select * from estoque_prod(2)


-- ######## inserção dos valores

INSERT INTO public.clientes VALUES
(1, 'Brucel Willis', '90267345238', '22640-344', 'RJ', 'rua do Pintinho Amarelinho, 5')
(2, 'Chuck Norris', '97862534834', '22890-344', 'RJ', 'rua Pereira da Silva, 222'),
(3, 'Tom Cruze', '23470987632', '22222-344', 'RJ', 'av. Prefeito Dulcidio Cardoso, 1555'),
(4, 'James Franco', '29038477234', '22111-455', 'RJ', 'rua do nao tem, 88'),
(5, 'Jean Dujardin', '98765213473', '22222-343', 'rua do nao tem, 88');

INSERT INTO public.fabricantes VALUES
(1, 'Petzl', null, null, 'França', '+33 1 4255-8919'),
(2, 'DMM', null, null, 'País de Gala', '+49 234 2340-2355'),
(3, 'Conquista', '19.393.858/0001-91', 'SP', 'Brasil', '+55 11 3455-5467');

INSERT INTO public.produtos VALUES
(1, 'Sonic', 'Mosquetões', 115.90, 2),
(2, 'Alpine 12cm', 'Costuras Expressa', 194.90, 1),
(3, 'Top D', 'Mosquetões', 104.55, 1),
(4, 'Big Wall', 'Caderinhas', 359.00, 3),
(5, 'Fita Daisy', 'Fitas', 59.90, 3),
(6, 'Sama', 'Caderinhas', 824.90, 1),
(7, 'Magic', 'Capacetes', 499.90, 2);

INSERT INTO public.estoque VALUES
(1, 1, 20),
(2,2,40),
(3,3,60),
(4,4,15),
(5,5,10),
(6,6,10),
(7,7,20);

INSERT INTO public.vendas VALUES
(1, '123456', 1, 2, 3, '2019-09-20'),
(2, '222222', 4, 1, 5, '2020-09-11'),
(3, '222222', 7, 1, 5, '2020-09-11');



