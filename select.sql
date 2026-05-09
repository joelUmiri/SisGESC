USE DB_INFINITY_SCHOOL;

-- SELECT SIMPLES --------INICIO--------
select pk_cpf, primeiro_nome, sobrenome from tb_pessoa;
select pk_fk_ra, data_matricula, status_matricula from tb_matricula;
select pk_fk_ra, data_matricula, status_matricula from tb_matricula where status_matricula = "Cursando";
select pk_fk_id_turma, pk_dia_semana, pk_hora_inicio, hora_fim from tb_grade_horaria where pk_dia_semana = "seg";
select pk_n_contratacao, dt_admissao, dt_desligamento, status_funcionario from tb_funcionario;
select pk_id_pagamento, valor_pago, data_pagamento, forma_pagamento from tb_pagamento;

-- SELECT SIMPLES --------FIM--------

-- SUBSELECT (OLTP) --------INICIO--------

-- SUBSELECT QUE RETORNA CPF E NOME DOS ALUNOS CADASTRADOS
SELECT 
    pk_cpf, 
    CONCAT(primeiro_nome, ' ', sobrenome) AS 'Nome do Aluno'
FROM tb_pessoa
WHERE pk_cpf IN (
    SELECT fk_cpf 
    FROM tb_aluno
);

-- SUBSELECT QUE RETORNA NOME E RA DOS ALUNOS
SELECT 
    a.pk_ra AS 'RA', 
    (
        SELECT CONCAT(p.primeiro_nome, ' ', p.sobrenome)
        FROM tb_pessoa AS p 
        WHERE p.pk_cpf = a.fk_cpf
    ) AS 'Nome do Aluno'
FROM tb_aluno AS a;

--  SUBSELECT QUE RETORNA O NOME COMPLETO DOS ALUNOS CUJA SOMA DAS FALTAS TOTAIS É MAIOR QUE 15.
SELECT 
    CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS 'Aluno com Alto Absenteísmo'
FROM tb_pessoa p
JOIN tb_aluno a ON p.pk_cpf = a.fk_cpf
WHERE a.pk_ra IN (
    SELECT pk_fk_ra
    FROM tb_matricula
    GROUP BY pk_fk_ra
    HAVING SUM(total_faltas) > 15
);

-- SUBSELECT QUE RETORNA OS ALUNOS CUJA MENOR NOTA É 8 OU MAIOR
SELECT CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS Aluno_Destaque
FROM tb_pessoa p
JOIN tb_aluno a ON p.pk_cpf = a.fk_cpf
WHERE a.pk_ra IN (
    SELECT pk_fk_ra
    FROM tb_matricula
    GROUP BY pk_fk_ra
    HAVING MIN(nota1) >= 8.0
);

-- SELECT QUE FALA AS TURMAS QUE TEM AO MENOS UM ALUNO QUE EVADIU OU TRANCOU
SELECT t.pk_id_turma
FROM tb_turma t
WHERE t.pk_id_turma IN (
    SELECT pk_fk_id_turma
    FROM tb_matricula
    WHERE status_matricula IN ('Evadido', 'Trancado')
    GROUP BY pk_fk_id_turma
    HAVING COUNT(*) >= 1
);

-- SUBSELECT QUE MOSTRA OS FUNCIONÁRIOS QUE GANHAM UM SALÁRIO BRUTO DE MAIS DE 5 MIL REAIS
SELECT 
    CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS 'Funcionario_Alto_Custo'
FROM tb_pessoa p
JOIN tb_funcionario f ON p.pk_cpf = f.fk_cpf
WHERE f.pk_n_contratacao IN (
    SELECT fk_n_contratacao
    FROM tb_folha_pagamento
    GROUP BY fk_n_contratacao
    HAVING SUM(salario_base) > 5000
);

-- SUBSELECT QUE MOSTRA OS FUNCIONÁRIOS QUE TEM MAIS DE 20 HORAS REGISTRADAS DE TREINO
SELECT 
    CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS 'Funcionario_Qualificado'
FROM tb_pessoa p
JOIN tb_funcionario f ON p.pk_cpf = f.fk_cpf
WHERE f.pk_n_contratacao IN (
    SELECT fk_n_contratacao
    FROM tb_treinamento
    GROUP BY fk_n_contratacao
    HAVING SUM(carga_horaria) > 20
);

-- SUBSELECT QUE RETORNA OS FORNECEDORES QUE POSSUEM UM ALTO VOLUME DE ITENS VENDIDOS PARA A ESCOLA
SELECT 
    f.nome_fantasia AS 'Fornecedor Estratégico',
    f.pk_cnpj AS 'CNPJ'
FROM tb_fornecedor f
WHERE f.pk_cnpj IN (
    SELECT c.fk_cnpj
    FROM tb_item_compra ic
    JOIN tb_compra c ON ic.pk_fk_nfe = c.pk_nfe
    GROUP BY c.fk_cnpj
    HAVING SUM(ic.qtd) > 10
);

-- SUBSELECT --------FIM--------

-- ROLLBACK --------INICIO--------

START TRANSACTION;
INSERT INTO tb_pessoa (pk_cpf, primeiro_nome, sobrenome, data_nasc, genero, deficiencia, etnia)
values ('94857230192', 'Ana2', 'Silva', '2005-03-12', 'Feminino', 'Nenhuma', 'Parda');
UPDATE tb_pessoa
SET primeiro_nome = 'João'
WHERE pk_cpf = '94857230192';

select * from tb_pessoa where pk_cpf='94857230192';

ROLLBACK;

-- ROLLBACK --------FIM--------

-- COMMIT --------INICIO--------

select * from tb_pessoa where pk_cpf='94857230192';

START TRANSACTION;
INSERT INTO tb_pessoa (pk_cpf, primeiro_nome, sobrenome, data_nasc, genero, deficiencia, etnia) values
('94857230192', 'Ana2', 'Silva', '2005-03-12', 'Feminino', 'Nenhuma', 'Parda');
COMMIT;

-- COMMIT --------FIM-------------------

-- SELECTS (OLAP) --------INICIO--------

-- SELECTS (OLAP) --------FIM-----------
