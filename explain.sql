USE DB_INFINITY_SCHOOL;

-- 1. idx_funcionario_cpf
EXPLAIN
SELECT *
FROM tb_funcionario
WHERE fk_cpf = '66666666666';

CREATE INDEX idx_funcionario_cpf
ON tb_funcionario (fk_cpf);


-- 2. idx_ferias_n_contratacao
EXPLAIN
SELECT *
FROM tb_ferias
WHERE fk_n_contratacao = 1001;

CREATE INDEX idx_ferias_n_contratacao
ON tb_ferias (fk_n_contratacao);


-- 3. idx_ponto_n_contratacao
EXPLAIN
SELECT *
FROM tb_ponto
WHERE fk_n_contratacao = 1001;

CREATE INDEX idx_ponto_n_contratacao
ON tb_ponto (fk_n_contratacao);


-- 4. idx_folha_pagamento_n_contratacao
EXPLAIN
SELECT *
FROM tb_folha_pagamento
WHERE fk_n_contratacao = 1001;

CREATE INDEX idx_folha_pagamento_n_contratacao
ON tb_folha_pagamento (fk_n_contratacao);


-- 5. idx_historico_pagamento_n_contratacao
EXPLAIN
SELECT *
FROM tb_historico_pagamento
WHERE fk_n_contratacao = 1001;

CREATE INDEX idx_historico_pagamento_n_contratacao
ON tb_historico_pagamento (fk_n_contratacao);


-- 6. idx_provanto_id_folha
EXPLAIN
SELECT *
FROM tb_provento
WHERE fk_id_folha = 1;

CREATE INDEX idx_provanto_id_folha
ON tb_provento (fk_id_folha);


-- 7. idx_desconto_id_folha
EXPLAIN
SELECT *
FROM tb_desconto
WHERE fk_id_folha = 1;

CREATE INDEX idx_desconto_id_folha
ON tb_desconto (fk_id_folha);


-- 8. idx_afastamento_n_contratacao
EXPLAIN
SELECT *
FROM tb_afastamento
WHERE fk_n_contratacao = 1003;

CREATE INDEX idx_afastamento_n_contratacao
ON tb_afastamento (fk_n_contratacao);


-- 9. idk_treinamento_n_contratacao
EXPLAIN
SELECT *
FROM tb_treinamento
WHERE fk_n_contratacao = 1001;

CREATE INDEX idk_treinamento_n_contratacao
ON tb_treinamento (fk_n_contratacao);


-- 10. idk_aluno_cpf
EXPLAIN
SELECT *
FROM tb_aluno
WHERE fk_cpf = '11111111111';

CREATE INDEX idk_aluno_cpf
ON tb_aluno (fk_cpf);


-- 11. idk_turma_n_contratacao
EXPLAIN
SELECT *
FROM tb_turma
WHERE fk_n_contratacao = 1001;

CREATE INDEX idk_turma_n_contratacao
ON tb_turma (fk_n_contratacao);


-- 12. idk_turma_id_curso
EXPLAIN
SELECT *
FROM tb_turma
WHERE fk_id_curso = 1;

CREATE INDEX idk_turma_id_curso
ON tb_turma (fk_id_curso);


-- 13. idk_turma_id_disciplina
EXPLAIN
SELECT *
FROM tb_turma
WHERE fk_id_disciplina = 1;

CREATE INDEX idk_turma_id_disciplina
ON tb_turma (fk_id_disciplina);


-- 14. idk_turma_id_unidade
EXPLAIN
SELECT *
FROM tb_turma
WHERE fk_id_unidade = 1;

CREATE INDEX idk_turma_id_unidade
ON tb_turma (fk_id_unidade);


-- 15. idx_contrato_ra
EXPLAIN
SELECT *
FROM tb_contrato
WHERE fk_ra = 'RA0001';

CREATE INDEX idx_contrato_ra
ON tb_contrato (fk_ra);


-- 16. idx_contrato_id_turma
EXPLAIN
SELECT *
FROM tb_contrato
WHERE fk_id_turma = 1;

CREATE INDEX idx_contrato_id_turma
ON tb_contrato (fk_id_turma);


-- 17. idx_mensalidade_registro_nrcontrato
EXPLAIN
SELECT *
FROM tb_mensalidade
WHERE fk_registro_nrcontrato = 1;

CREATE INDEX idx_mensalidade_registro_nrcontrato
ON tb_mensalidade (fk_registro_nrcontrato);


-- 18. idx_inadimplencia_nsu
EXPLAIN
SELECT *
FROM tb_inadimplencia
WHERE fk_nsu = 3;

CREATE INDEX idx_inadimplencia_nsu
ON tb_inadimplencia (fk_nsu);


-- 19. idx_compra_cnpj
EXPLAIN
SELECT *
FROM tb_compra
WHERE fk_cnpj = '11111111000111';

CREATE INDEX idx_compra_cnpj
ON tb_compra (fk_cnpj);


-- 20. idx_servico_cpf
EXPLAIN
SELECT *
FROM tb_servico
WHERE fk_cpf = '88888888888';

CREATE INDEX idx_servico_cpf
ON tb_servico (fk_cpf);


-- 21. idx_conta_pagar_nfe
EXPLAIN
SELECT *
FROM tb_conta_pagar
WHERE fk_nfe = '11111111111111111111111111111111111111111111';

CREATE INDEX idx_conta_pagar_nfe
ON tb_conta_pagar (fk_nfe);


-- 22. idx_conta_id_servico
EXPLAIN
SELECT *
FROM tb_conta_pagar
WHERE fk_id_servico = 1;

CREATE INDEX idx_conta_id_servico
ON tb_conta_pagar (fk_id_servico);


-- 23. idx_conta_receber_nsu
EXPLAIN
SELECT *
FROM tb_conta_receber
WHERE fk_nsu = 1;

CREATE INDEX idx_conta_receber_nsu
ON tb_conta_receber (fk_nsu);


-- 24. idx_pagamento_id_contra_receber
EXPLAIN
SELECT *
FROM tb_pagamento
WHERE fk_id_conta_receber = 1;

CREATE INDEX idx_pagamento_id_contra_receber
ON tb_pagamento (fk_id_conta_receber);