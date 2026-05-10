USE DB_INFINITY_SCHOOL;

-- SELECT SIMPLES --------INICIO--------

select pk_cpf, primeiro_nome, sobrenome from tb_pessoa;
select pk_fk_ra, data_matricula, status_matricula from tb_matricula;
select pk_fk_ra, data_matricula, status_matricula from tb_matricula where status_matricula = "Cursando";
select pk_fk_id_turma, pk_dia_semana, pk_hora_inicio, hora_fim from tb_grade_horaria where pk_dia_semana = "seg";
select pk_n_contratacao, dt_admissao, dt_desligamento, status_funcionario from tb_funcionario;
select pk_id_pagamento, valor_pago, data_pagamento, forma_pagamento from tb_pagamento;

-- SELECT SIMPLES --------FIM-------------

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

-- Predição de Risco de Evasão Acadêmica por Curso
SELECT 
    da.nome_completo,
    dtur.nome_curso,
    AVG(fa.nota) AS media_final,
    SUM(fa.total_faltas) AS total_faltas,
    CASE 
        WHEN AVG(fa.nota) < 6.0 AND SUM(fa.total_faltas) > 10 THEN 'Risco Crítico'
        WHEN AVG(fa.nota) < 7.0 OR SUM(fa.total_faltas) > 5 THEN 'Atenção'
        ELSE 'Estável'
    END AS status_preditivo
FROM fato_academico fa
JOIN dim_aluno da ON fa.sk_aluno = da.sk_aluno
JOIN dim_turma dtur ON fa.sk_turma = dtur.sk_turma
GROUP BY da.sk_aluno, dtur.nome_curso;
    
-- Predição de Risco de Burnout e Sobrecarga de Funcionários
SELECT
    df.nome_completo,
    SUM(frh.horas_trabalhadas) AS total_horas,
    SUM(frh.horas_extra) AS horas_extras,
    SUM(frh.qtd_faltas_ponto) AS faltas,
    CASE
        WHEN SUM(frh.horas_extra) > 20
             AND SUM(frh.qtd_faltas_ponto) > 3
             THEN 'ALTO RISCO DE BURNOUT'
        WHEN SUM(frh.horas_extra) > 10
             THEN 'RISCO MODERADO'
        ELSE 'RISCO BAIXO'
    END AS previsao_rh
FROM fato_rh frh
JOIN dim_funcionario df
    ON df.sk_funcionario = frh.sk_funcionario
GROUP BY
    df.nome_completo
ORDER BY
    horas_extras DESC;

-- Predição de risco de evasão por curso
SELECT
    dtu.nome_curso,
    COUNT(*) AS total_registros,
    AVG(fa.nota) AS media_notas,
    AVG(fa.total_faltas) AS media_faltas,
    CASE
        WHEN AVG(fa.nota) < 5
             OR AVG(fa.total_faltas) > 12
             THEN 'CURSO COM FORTE RISCO DE EVASAO'
        WHEN AVG(fa.nota) < 7
             THEN 'CURSO EM OBSERVACAO'
        ELSE 'CURSO ESTAVEL'
    END AS previsao_curso
FROM fato_academico fa
JOIN dim_turma dtu
    ON dtu.sk_turma = fa.sk_turma
GROUP BY
    dtu.nome_curso
ORDER BY
    media_notas ASC;
    
-- Predição de necessidade de contratação por departamento
SELECT
    df.departamento,
    COUNT(*) AS total_funcionarios,
    AVG(frh.horas_extra) AS media_horas_extras,
    AVG(frh.qtd_faltas_ponto) AS media_faltas,
    CASE
        WHEN AVG(frh.horas_extra) > 15
            THEN 'NECESSIDADE ALTA DE CONTRATACAO'
        WHEN AVG(frh.horas_extra) > 8
            THEN 'POSSIVEL SOBRECARGA'
        ELSE 'QUADRO ESTAVEL'
    END AS previsao_departamento
FROM fato_rh frh
JOIN dim_funcionario df
    ON df.sk_funcionario = frh.sk_funcionario
GROUP BY
    df.departamento
ORDER BY
    media_horas_extras DESC;
    
-- Predição de retenção/permanência de alunos
SELECT
    da.nome_completo,
    AVG(fa.nota) AS media_notas,
    SUM(fa.total_faltas) AS total_faltas,
    CASE
        WHEN AVG(fa.nota) >= 8
             AND SUM(fa.total_faltas) < 5
             THEN 'ALTA CHANCE DE RETENCAO'
        WHEN AVG(fa.nota) >= 6
             THEN 'RETENCAO MODERADA'
        ELSE 'RISCO DE EVASAO'
    END AS previsao_permanencia
FROM fato_academico fa
JOIN dim_aluno da
    ON da.sk_aluno = fa.sk_aluno
GROUP BY
    da.nome_completo
ORDER BY
    media_notas DESC;
-- SELECTS (OLAP) --------FIM-----------
