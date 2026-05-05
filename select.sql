USE DB_INFINITY_SCHOOL;

-- SELECT SIMPLES --------INICIO--------

select pk_cpf, primeiro_nome, sobrenome from tb_pessoa;
select pk_fk_ra, data_matricula, status_matricula from tb_matricula;
select pk_fk_ra, data_matricula, status_matricula from tb_matricula where status_matricula = "Cursando";
select pk_fk_id_turma, pk_dia_semana, pk_hora_inicio, hora_fim from tb_grade_horaria where pk_dia_semana = "seg";
select pk_n_contratacao, dt_admissao, dt_desligamento, status_funcionario from tb_funcionario;
select pk_id_pagamento, valor_pago, data_pagamento, forma_pagamento from tb_pagamento;

-- SELECT SIMPLES --------FIM--------

-- SUBSELECT --------INICIO--------

select pk_cpf, primeiro_nome, sobrenome from tb_pessoa
where pk_cpf in (
  select fk_cpf from tb_aluno
);

SELECT a.pk_ra, ( 
	SELECT p.primeiro_nome FROM tb_pessoa AS p WHERE p.pk_cpf = a.fk_cpf 
) AS nome_aluno FROM tb_aluno AS a;

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

-- COMMIT --------FIM--------

-- JOIN --------INICIO--------

select p.pk_cpf, p.primeiro_nome, p.sobrenome, a.pk_ra from tb_pessoa as p 
join tb_aluno as a on pk_cpf = fk_cpf;

select p.pk_cpf, p.primeiro_nome, p.sobrenome, a.pk_ra, m.data_matricula, m.status_matricula from tb_pessoa as p 
join tb_aluno as a on pk_cpf = fk_cpf
join tb_matricula as m on pk_ra = pk_fk_ra;

select p.pk_cpf, p.primeiro_nome, p.sobrenome, f.pk_n_contratacao, f.dt_admissao, c.nome_cargo, d.departamento from tb_pessoa as p
join tb_funcionario as f on pk_cpf = fk_cpf
join tb_func_cargo on pk_n_contratacao = pk_fk_n_contratacao
join tb_cargo as c on pk_fk_id_cargo = pk_id_cargo
join tb_departamento as d on pk_id_departamento = pk_fk_id_departamento;

-- JOIN --------FIM--------
