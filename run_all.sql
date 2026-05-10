DROP DATABASE IF EXISTS DB_INFINITY_SCHOOL;
CREATE DATABASE DB_INFINITY_SCHOOL;
USE DB_INFINITY_SCHOOL;

-- TABELAS CENTRAIS --------INICIO--------
CREATE TABLE `tb_pessoa` (
  `pk_cpf` char(11) PRIMARY KEY NOT NULL,
  `primeiro_nome` varchar(15) NOT NULL,
  `sobrenome` varchar(30) NOT NULL,
  `data_nasc` date NOT NULL,
  `genero` enum('Masculino','Feminino','Outro') not null,
  `deficiencia` enum('Visual','Auditiva','Motora','Intelectual','Multipla','Nenhuma') DEFAULT 'Nenhuma' not null,
  `etnia` enum('Branca','Preta','Parda','Amarela','Indígena','Outro/Prefiro não responder') not null,

  -- CHECA, COM O OPERADOR REGEXP, SE, DO INICIO AO FIM DO VALOR, TEM SOMENTE DIGITOS DO 0-9  E SE SÃO EXATOS 11 DIGITOS
  CHECK (pk_cpf REGEXP '^[0-9]{11}$')
);

CREATE TABLE `tb_email` (
  `pk_email` varchar(40) PRIMARY KEY NOT NULL,
  -- RESTRIÇÃO QUE CHECA SE O EMAIL ESTÁ NO MODELO: <ALGO ANTES DO '@'> <@> <ALGO DEPOIS DO '@'> <.> <ALGO DEPOIS DO '.'> 
  CHECK (pk_email REGEXP '^[^@]+@[^@]+\\.[^@]+$')
);

CREATE TABLE `tb_telefone` (
  `pk_num_pais` char(3) NOT NULL DEFAULT '55',
  `pk_ddd` char(2) NOT NULL,
  `pk_numero` char(9) NOT NULL,
  PRIMARY KEY (`pk_num_pais`, `pk_ddd`, `pk_numero`),
  CHECK (pk_num_pais REGEXP '^[0-9]{1,3}$'),
  CHECK (pk_ddd REGEXP '^[0-9]{2}$'),
  CHECK (pk_numero REGEXP '^[0-9]{8,9}$')
);

CREATE TABLE `tb_endereco` (
	`pk_cep` char(8) NOT NULL,
	`pk_numero` int NOT NULL,
	`complemento` varchar(20),
    
    PRIMARY KEY (`pk_cep`, `pk_numero`),
  -- GARANTE QUE O CEP É UM VALOR DE 8 DIGITOS COMPOSTO APENAS POR NÚMEROS
  CHECK (pk_cep REGEXP '^[0-9]{8}$'),
  -- GARANTE QUE O NÚMERO RESIDENCIAL NÃO É NEGATIVO
  CHECK (pk_numero >= 0)
);

CREATE TABLE `tb_pessoa_email` (
  `pk_fk_cpf` char(11) NOT NULL,
  `pk_fk_email` varchar(100) NOT NULL,
  PRIMARY KEY (`pk_fk_cpf`, `pk_fk_email`),
  UNIQUE (`pk_fk_email`), 
  FOREIGN KEY (`pk_fk_cpf`) REFERENCES tb_pessoa(`pk_cpf`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_email`) REFERENCES tb_email(`pk_email`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_pessoa_telefone` (
  `pk_fk_cpf` char(11) NOT NULL,
  `pk_fk_num_pais` char(3) NOT NULL,
  `pk_fk_ddd` char(2) NOT NULL,
  `pk_fk_numero` char(9) NOT NULL,
  PRIMARY KEY (`pk_fk_cpf`, `pk_fk_num_pais`, `pk_fk_ddd`, `pk_fk_numero`),
  UNIQUE (`pk_fk_num_pais`, `pk_fk_ddd`, `pk_fk_numero`),
  FOREIGN KEY (`pk_fk_cpf`) REFERENCES tb_pessoa(`pk_cpf`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_num_pais`, `pk_fk_ddd`, `pk_fk_numero`) 
    REFERENCES tb_telefone(`pk_num_pais`, `pk_ddd`, `pk_numero`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_pessoa_endereco` (
	`pk_fk_cpf` char(11) NOT NULL,
	`pk_fk_cep` char(8) NOT NULL,
	`pk_fk_numero` int NOT NULL,
  
  -- CHAVE PRIMÁRIA COMPOSTA DO CPF E DO ENDEREÇO DA PESSOA
  PRIMARY KEY (`pk_fk_cpf`, `pk_fk_cep`, `pk_fk_numero`),
  
  -- CHAVES ESTRANGEIRAS QUE APONTAM PARA O ENDEREÇO E A PESSOA
  FOREIGN KEY (`pk_fk_cpf`) REFERENCES tb_pessoa(`pk_cpf`)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_cep`, `pk_fk_numero`) REFERENCES tb_endereco(`pk_cep`, `pk_numero`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- TABELAS CENTRAIS --------FIM--------

-- TABELAS RH --------INICIO--------

CREATE TABLE `tb_formacao` (
  `pk_id_formacao` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_formacao` varchar(255) NOT NULL UNIQUE
);

CREATE TABLE `tb_departamento` (
  `pk_id_departamento` int PRIMARY KEY NOT NULL,
  `departamento` enum('Direção','Coordenação','Secretaria_ADM','Financeiro','Zeladoria','Inspetoria_Segurança','Biblioteca','Recursos_Humanos') not null
);

CREATE TABLE `tb_cargo` (
  `pk_id_cargo` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_cargo` varchar(255) NOT NULL UNIQUE
);

CREATE TABLE `tb_cargo_departamento` (
  `pk_fk_id_cargo` int NOT NULL,
  `pk_fk_id_departamento` int NOT NULL,
  PRIMARY KEY (`pk_fk_id_cargo`, `pk_fk_id_departamento`),
  
  -- FKs QUE REFERENCIAM O CARGO E SEU DEPARTAMENTO
  FOREIGN KEY (pk_fk_id_cargo)
  REFERENCES tb_cargo(pk_id_cargo)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (pk_fk_id_departamento)
  REFERENCES tb_departamento(pk_id_departamento)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_funcionario` (
  `pk_n_contratacao` int PRIMARY KEY NOT NULL,
  `fk_cpf` char(11) UNIQUE NOT NULL,
  `status_funcionario` enum('Ativado','Desativado') NOT NULL,
  `dt_admissao` date NOT NULL,
  `dt_desligamento` date,
  
  -- DECLARA FK
  FOREIGN KEY (fk_cpf)
  REFERENCES tb_pessoa(pk_cpf)ON DELETE CASCADE ON UPDATE CASCADE,
  -- GARANTE QUE, SE OCORRER DESLIGAMENTO, ELE É DEPOIS DA DATA DE ADMISSÃO, SE NÃO, PERMANECER NULO
  CHECK (dt_desligamento IS NULL OR dt_desligamento >= dt_admissao),
  
  -- SE O FUNCIONÁRIO ESTÁ ATIVO, SUA DATA DE DESLIGAMENTO NÃO EXISTE, SE SIM, ELA É OBRIGATÓRIA
  CHECK(
    (status_funcionario = 'Ativado' AND dt_desligamento IS NULL)
    OR
    (status_funcionario = 'Desativado' AND dt_desligamento IS NOT NULL)
  )
);

CREATE TABLE `tb_func_cargo` (
  `pk_fk_n_contratacao` int NOT NULL,
  `pk_fk_id_cargo` int NOT NULL,
  `pk_fk_id_departamento` int NOT NULL,
  `pk_data_inicio` date NOT NULL,
  `data_fim` date,
  PRIMARY KEY (`pk_fk_n_contratacao`, `pk_fk_id_cargo`, `pk_fk_id_departamento`, `pk_data_inicio`),
  
  -- INDICAM AS FKs, pois é uma tabela com chave composta.
  FOREIGN KEY (pk_fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (pk_fk_id_cargo, pk_fk_id_departamento)
  REFERENCES tb_cargo_departamento(pk_fk_id_cargo, pk_fk_id_departamento)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- GARANTE QUE OU O CARGO ESTÁ ATIVO, OU ELE TEM UMA DATA DE FIM
  CHECK (
  data_fim IS NULL 
  OR data_fim >= pk_data_inicio
  )
);

CREATE TABLE `tb_funcionario_formacao` (
  `pk_fk_n_contratacao` int NOT NULL,
  `pk_fk_id_formacao` int NOT NULL,
  `dt_conclusao` date, -- Informação importante para o RH
  `instituicao` varchar(100),
  
  PRIMARY KEY (`pk_fk_n_contratacao`, `pk_fk_id_formacao`),
  
  FOREIGN KEY (`pk_fk_n_contratacao`) 
    REFERENCES tb_funcionario(`pk_n_contratacao`) ON DELETE CASCADE ON UPDATE CASCADE,
    
  FOREIGN KEY (`pk_fk_id_formacao`) 
    REFERENCES tb_formacao(`pk_id_formacao`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_ferias` (
  `pk_id_ferias` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `dias_ferias` int NOT NULL DEFAULT 30,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `status_ferias` enum('Agendada','Em_Andamento','Concluida','Cancelada') not null,
  
  -- DECLARA A FK ASSOCIANDO AS FÉRIAS A UM FUNCIONÁRIO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  -- CHECA SE A DATA DE FIM É MAIOR QUE A DE INÍCIO
  CHECK (data_fim >= data_inicio),
  
  -- GARANTE QUE AS FÉRIAS DUREM AO MENOS UM DIA
  CHECK (dias_ferias > 0),
  
  UNIQUE (data_inicio, fk_n_contratacao)
);
CREATE TABLE `tb_ponto` (
  `pk_id_ponto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `data` date NOT NULL,
  `hora_entrada` time NOT NULL,
  `hora_saida` time,
  
  -- DECLARA A FK DO PONTO AO FUNCIONÁRIO RELACIONADO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE RESTRICT ON UPDATE CASCADE,
  -- CHECA SE O HORARIO SE SAIDA FOI GERADO, SE SIM, O PONTO DEVE SER DEPOIS DA ENTRADA
  CHECK (
  hora_saida IS NULL 
  OR hora_saida > hora_entrada
  ),
  
  UNIQUE(fk_n_contratacao,hora_entrada,`data`) 
);

CREATE TABLE `tb_folha_pagamento` (
  `pk_id_folha` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `salario_base` decimal(10,2) NOT NULL,
  `data_pagamento` date NOT NULL,
  
  -- FKs QUE INDICAM O FUNCIONÁRIO DA FOLHA
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE RESTRICT ON UPDATE CASCADE,
  -- CHECA QUE NENHUM SALÁRIO É MENOR QUE ZERO
  CHECK (salario_base >= 0),
  
  -- IMPEDE QUE UM FUNCIONÁRIO RECEBA UM PAGAMENTO NO MESMO DIA, EVITANDO ERROS
  UNIQUE (fk_n_contratacao, data_pagamento)
);

CREATE TABLE `tb_historico_pagamento` (
  `pk_id_historico` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `salario_atual` decimal(10,2) NOT NULL,
  `data_alteracao` date NOT NULL,
  
  -- INDICA O FUNCIONÁRIO CUJO SALÁRIO FOI ALTERADO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  -- CHECA SE O SALÁRIO ATUAL É MAIOR OU IGUAL A ZERO. AFINAL, NÃO DEVE SER MENOR.
  CHECK (salario_atual >= 0),
  
  UNIQUE(fk_n_contratacao, data_alteracao)
);

CREATE TABLE `tb_provento` (
  `pk_id_provento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_id_folha` int NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  
  -- INDICA A QUAL FOLHA ESSE PROVENTO PERTENCE
  FOREIGN KEY (fk_id_folha)
  REFERENCES tb_folha_pagamento(pk_id_folha)ON DELETE CASCADE ON UPDATE CASCADE,
  -- GARANTE QUE O VALOR DO PROVENTO NÃO SEJA NEGATIVO
  CHECK (valor >= 0),
  
  UNIQUE (fk_id_folha, tipo)
);

CREATE TABLE `tb_desconto` (
  `pk_id_desconto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_id_folha` int NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  
  -- INDICA A QUAL FOLHA ESSE DESCONTO PERTENCE
  FOREIGN KEY (fk_id_folha)
  REFERENCES tb_folha_pagamento(pk_id_folha)ON DELETE CASCADE ON UPDATE CASCADE,
  -- GARANTE QUE O VALOR DO DESCONTO NÃO SEJA NEGATIVO
  CHECK (valor >= 0),
  
  UNIQUE (fk_id_folha, tipo)
);

CREATE TABLE `tb_afastamento` (
  `pk_id_afastamento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `motivo` text NOT NULL,
  `status` enum('Em_Andamento','Concluído'),
  `data_inicio` date NOT NULL,
  `data_fim` date COMMENT 'check',
  
  -- INDICA AS FKs QUE ASSOCIAM OS AFASTAMENTOS AO FUNCIONÁRIO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  -- CONFERE QUE A DATA DE FIM É OU VAZIO, OU MAIOR QUE A DE INÍCIO
  CHECK (
    data_fim IS NULL 
    OR data_fim >= data_inicio
  ),
  UNIQUE (fk_n_contratacao, data_inicio)
);

CREATE TABLE `tb_treinamento` (
  `pk_id_treinamento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `tipo_treinamento` varchar(255) NOT NULL,
  `carga_horaria` int NOT NULL,
  `data_inicio` date NOT NULL,
  `data_conclusao` date,
  
  -- FKs QUE INDICAM O FUNCIONÁRIO RECEBENDO O TREINAMENTO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  -- GARANTIA DE QUE A CARGA HORÁRIO É VÁLIDA, SENDO MAIOR QUE 0
  CHECK (carga_horaria > 0),
  
  -- DEFINE QUE, QUANDO NÃO NULA, A DATA DE CONCLUSÃO DO TREINAMENTO DEVE SER MAIOR QUE A DE INÍCIO
  CHECK (
    data_conclusao IS NULL 
    OR data_conclusao >= data_inicio
  ),
  UNIQUE(fk_n_contratacao, data_inicio)
);

-- TABELAS RH --------FIM--------

-- TABELAS ACADEMICO --------INICIO--------

CREATE TABLE `tb_unidade` (
  `pk_id_unidade` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_unidade` varchar(50) UNIQUE NOT NULL,
  `logradouro` varchar(100) NOT NULL,
  `num_logradouro` varchar(10) NOT NULL,
  `complemento` varchar(70)
);

CREATE TABLE `tb_curso` (
  `pk_id_curso` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_curso` varchar(50) UNIQUE NOT NULL,
  `duracao_meses` int NOT NULL,
  `idade_min` int NOT NULL,
  `idade_max` int,
  
  -- GARANTE QUE O CURSO DURA AO MENOS UM MES
  CHECK (duracao_meses > 0),
  -- GARANTE QUE A IDADE MÍNIMA PARA CURSAR É VÁLIDA
  CHECK (idade_min >= 0),
  -- GARANTE QUE A IDADE MÁXIMA, CASO NÃO FOR NULA, FOR MAIOR QUE A MÍNIMA
  CHECK (idade_max IS NULL OR idade_max >= idade_min)
);

CREATE TABLE `tb_aluno` (
  `pk_ra` varchar(10) PRIMARY KEY NOT NULL,
  `fk_cpf` char(11) UNIQUE NOT NULL,
  
  -- FK QUE LIGA O ALUNO AO SEU VÍNCULO ACADÊMICO
  FOREIGN KEY (fk_cpf)
  REFERENCES tb_pessoa(pk_cpf)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_disciplina` (
  pk_fk_id_curso int NOT NULL,
  pk_id_disciplina int NOT NULL,
  disciplina varchar(50) NOT NULL,
  
  -- CHAVE COMPOSTA DO CURSO E DA DISCIPLINA, AFINAL, UMA DISCIPLINA PERTENCE APENAS À UM CURSO
  PRIMARY KEY (pk_fk_id_curso, pk_id_disciplina),
  
  -- ESTRANGEIRA QUE APONTA PARA O DITO CURSO
  FOREIGN KEY (pk_fk_id_curso)
  REFERENCES tb_curso(pk_id_curso)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_turma` (
  pk_id_turma INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  fk_n_contratacao INT NOT NULL,
  fk_id_curso INT NOT NULL,
  fk_id_disciplina INT NOT NULL,
  fk_id_unidade INT NOT NULL,
  data_inicio DATE NOT NULL,
  turno ENUM('Matutino','Vespertino','Noturno') NOT NULL,
  
  -- FK QUE APONTA PARA UMA PK COMPOSTA, NA TABELA DISCIPLINA
  FOREIGN KEY (fk_id_curso, fk_id_disciplina)
  REFERENCES tb_disciplina(pk_fk_id_curso, pk_id_disciplina)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (fk_id_unidade)
  REFERENCES tb_unidade(pk_id_unidade)ON DELETE CASCADE ON UPDATE CASCADE,
  
  UNIQUE (fk_id_curso, fk_id_unidade, data_inicio)
);

CREATE TABLE `tb_matricula` (
  pk_fk_ra VARCHAR(10) NOT NULL,
  pk_fk_id_turma INT NOT NULL,
  data_matricula DATE NOT NULL,
  status_matricula ENUM('Cursando','Aprovado','Reprovado','Trancado','Evadido') NOT NULL DEFAULT 'Cursando',
  nota1 DECIMAL(4,2),
  nota2 DECIMAL(4,2),
  nota3 DECIMAL(4,2),
  nota4 DECIMAL(4,2),
  total_faltas INT DEFAULT 0,
  
  -- CHAVE COMPOSTA DO ALUNO E DA TURMA EM QUE ELE SE ENCONTRA
  PRIMARY KEY (pk_fk_ra, pk_fk_id_turma),
  
  -- CHAVES ESTRANGEIRAS QUE ASSOCIAM O ALUNO E A TURMA NO BANCO
  FOREIGN KEY (pk_fk_ra)
  REFERENCES tb_aluno(pk_ra)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (pk_fk_id_turma)
  REFERENCES tb_turma(pk_id_turma)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- GARANTE QUE A NOTA FINAL É UM NÚMERO ENTRE 0 E 10
	check ((nota1 BETWEEN 0 AND 10 OR nota1 IS NULL) AND
    (nota2 BETWEEN 0 AND 10 OR nota2 IS NULL) AND
    (nota3 BETWEEN 0 AND 10 OR nota3 IS NULL) AND
    (nota4 BETWEEN 0 AND 10 OR nota4 IS NULL))
);

CREATE TABLE `tb_grade_horaria` (
  pk_fk_id_turma INT NOT NULL,
  pk_dia_semana ENUM('seg','ter','qua','qui','sex') NOT NULL,
  pk_hora_inicio TIME NOT NULL,
  hora_fim TIME NOT NULL,
  
  -- CHAVE ESTRANGEIRA QUE GARANTO QUE UMA TURMA NÃO TENHA DUAS AULAS AO MESMO TEMPO
  PRIMARY KEY (pk_fk_id_turma, pk_dia_semana, pk_hora_inicio),
  
  -- IDENTIFICA A TURMA POR MEIO DE UMA CHAVE ESTRANGEIRA
  FOREIGN KEY (pk_fk_id_turma)
  REFERENCES tb_turma(pk_id_turma)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- CHECA SE A HORA DE FIM DA AULA É DEPOIS DA DE INÍCIO
  CHECK (hora_fim > pk_hora_inicio)
);

-- TABELAS ACADEMICO --------FIM--------

-- TABELAS FINANCEIRO --------INICIO--------

CREATE TABLE `tb_contrato` (
  `pk_registro_nrcontrato` int PRIMARY KEY AUTO_INCREMENT,
  `fk_ra` varchar(10) NOT NULL,
  `fk_id_turma` int NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `status_contrato` enum('Ativo','Bloqueado','Trancado') NOT NULL DEFAULT 'Ativo',
  
  -- FKs QUE ASSOCIAM O CONTRATO AO ALUNO E A TURMA EM QUE ELE ESTÁ
  FOREIGN KEY (`fk_ra`)
  REFERENCES tb_aluno(`pk_ra`)ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (`fk_id_turma`)
  REFERENCES tb_turma(`pk_id_turma`)ON DELETE RESTRICT ON UPDATE CASCADE,
  -- GARANTE QUE A DATA DE FIM NÃO É MENOR QUE A DE INÍCIO
  CHECK (`data_fim` >= `data_inicio`),
  
  UNIQUE (fk_ra, fk_id_turma, data_inicio)
);

CREATE TABLE `tb_mensalidade` (
  `pk_nsu` int PRIMARY KEY AUTO_INCREMENT,
  `fk_registro_nrcontrato` int NOT NULL,
  `data_emissao` date NOT NULL,
  `data_vencimento` date NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `status_mensalidade` enum('Pendente','Pago','Atrasado') NOT NULL DEFAULT 'Pendente',
  
  -- CHAVE ESTRANGEIRA QUE LIGA A MENSALIDADE AO REGISTRO DE CONTRATO
  FOREIGN KEY (`fk_registro_nrcontrato`)
  REFERENCES tb_contrato(`pk_registro_nrcontrato`)ON DELETE CASCADE ON UPDATE CASCADE,
  -- RESTRIÇÃO QUE GARANTE QUE A DATA DE VENCIMENTO É DEPOIS DA EMISSÃO
  CHECK (`data_vencimento` >= `data_emissao`),
  -- GARANTTE QUE O VALOR DE UMA MENSALIDADE É MAIOR QUE 0
  CHECK (`valor` > 0),
  
  UNIQUE (fk_registro_nrcontrato, data_emissao)
);

CREATE TABLE `tb_inadimplencia` (
  `pk_id_inadimplencia` int PRIMARY KEY AUTO_INCREMENT,
  `fk_nsu` int UNIQUE NOT NULL,
  `data_registro` date NOT NULL,
  `multa` decimal(10,2) NOT NULL DEFAULT 0,
  `juros` decimal(10,2) NOT NULL DEFAULT 0,
  
  -- FK QUE LIGA A INADIMPLENCIA À MENSALIDADE
  FOREIGN KEY (`fk_nsu`)
  REFERENCES tb_mensalidade(`pk_nsu`)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_produto` (
  `pk_id_produto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_produto` varchar(45) NOT NULL UNIQUE
);

CREATE TABLE `tb_fornecedor` (
  `pk_cnpj` char(14) PRIMARY KEY,
  `razao_social` varchar(100) NOT NULL,
  `nome_fantasia` varchar(45) NOT NULL,
  -- GARANTE QUE O CNPJ SEJA UM VALOR DE 14 DIGITOS DE 0 A 9
  CHECK (pk_cnpj REGEXP '^[0-9]{14}$')
);

CREATE TABLE `tb_fornecedor_email` (
  `pk_fk_cnpj` char(14) NOT NULL,
  `pk_fk_email` varchar(100) NOT NULL,
  PRIMARY KEY (`pk_fk_cnpj`, `pk_fk_email`),
  UNIQUE (`pk_fk_email`), 
  FOREIGN KEY (`pk_fk_cnpj`) REFERENCES tb_fornecedor(`pk_cnpj`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_email`) REFERENCES tb_email(`pk_email`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_fornecedor_telefone` (
  `pk_fk_cnpj` char(14) NOT NULL,
  `pk_fk_num_pais` char(3) NOT NULL,
  `pk_fk_ddd` char(2) NOT NULL,
  `pk_fk_numero` char(9) NOT NULL,
  PRIMARY KEY (`pk_fk_cnpj`, `pk_fk_num_pais`, `pk_fk_ddd`, `pk_fk_numero`),
  UNIQUE (`pk_fk_num_pais`, `pk_fk_ddd`, `pk_fk_numero`),
  FOREIGN KEY (`pk_fk_cnpj`) REFERENCES tb_fornecedor(`pk_cnpj`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_num_pais`, `pk_fk_ddd`, `pk_fk_numero`) 
  REFERENCES tb_telefone(`pk_num_pais`, `pk_ddd`, `pk_numero`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_compra` (
  `pk_nfe` char(44) PRIMARY KEY,
  `fk_cnpj` char(14) NOT NULL,
  
  -- CHAVE ESTRANGEIRA QUE CONECTA UMA COMPRA À UMA EMPRESA
  FOREIGN KEY (`fk_cnpj`)
  REFERENCES tb_fornecedor(`pk_cnpj`)ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `tb_servico` (
  `pk_id_servico` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `desc_servico` varchar(45) NOT NULL,
  `valor_servico` decimal(10,2) NOT NULL,
  `fk_cpf` char(11) NOT NULL,
  `data_hora` datetime NOT NULL,
  
  -- LIGA O SERVIÇO A UM PRESTADOR
  FOREIGN KEY (fk_cpf)
  REFERENCES tb_pessoa(pk_cpf)ON DELETE RESTRICT ON UPDATE CASCADE,
 
  -- GARANTE QUE O VALOR DO SERVIÇO NÃO É NEGATIVO
  CHECK (valor_servico >= 0),
  
  UNIQUE (fk_cpf, data_hora)
);

CREATE TABLE `tb_conta_pagar` (
  `pk_cod_despesa` int PRIMARY KEY AUTO_INCREMENT,
  `fk_nfe` char(44),
  `fk_id_servico` int,
  `data_pagamento` date NOT NULL,
  `data_vencimento` date NOT NULL,
  
  FOREIGN KEY (`fk_nfe`)
  REFERENCES tb_compra(`pk_nfe`)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT,

  FOREIGN KEY (`fk_id_servico`)
  REFERENCES tb_servico(`pk_id_servico`)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT,
  
  CHECK (
    (fk_nfe IS NOT NULL AND fk_id_servico IS NULL)
    OR
    (fk_nfe IS NULL AND fk_id_servico IS NOT NULL)
  ),
    UNIQUE (fk_nfe, data_pagamento),
    UNIQUE (fk_id_servico, data_pagamento)
);

CREATE TABLE `tb_item_compra` (
  `pk_fk_nfe` char(44) NOT NULL,
  `pk_fk_id_produto` int NOT NULL,
  `valor_unitario` decimal(10,2) NOT NULL,
  `qtd` int NOT NULL,
  
  -- INDICA A CHAVE PRIMÁRIA, QUE É COMPOSTA DO IDENTIFICADOR DE UM ITEM E DE UMA COMPRA
  PRIMARY KEY (`pk_fk_nfe`, `pk_fk_id_produto`),
  
  -- IDENTIFICA TANTO O ITEM, QUANTO A COMPRA, EM SUAS RESPECTIVAS TABELAS
  FOREIGN KEY (`pk_fk_nfe`)
  REFERENCES tb_compra(`pk_nfe`)ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_id_produto`)
  REFERENCES tb_produto(`pk_id_produto`)ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `tb_conta_receber` (
  `pk_id_conta_receber` int PRIMARY KEY AUTO_INCREMENT,
  `fk_nsu` int NOT NULL UNIQUE,
  `data_prevista` date NOT NULL,
  `data_recebimento` date,
  
  -- FK QUE FAZ TB_CONTA_RECEBER SE LIGAR COM SUA RESPECTIVA MENSALIDADE
  FOREIGN KEY (`fk_nsu`)
  REFERENCES tb_mensalidade(`pk_nsu`)ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `tb_pagamento` (
  `pk_id_pagamento` int PRIMARY KEY AUTO_INCREMENT NOT NULL,
  `fk_id_conta_receber` int NOT NULL,
  `valor_pago` decimal(10,2) NOT NULL,
  `data_pagamento` date NOT NULL,
  `forma_pagamento` ENUM('pix','dinheiro', 'debito', 'credito', 'boleto') NOT NULL,
  
  -- CHAVE ESTRANGEIRA QUE LIGA O PAGAMENTO COM A CONTA A RECEBER
  FOREIGN KEY (`fk_id_conta_receber`)
  REFERENCES tb_conta_receber(`pk_id_conta_receber`)ON DELETE RESTRICT ON UPDATE CASCADE,
 
  CHECK (`valor_pago` > 0),
  UNIQUE (fk_id_conta_receber, data_pagamento)
);

-- TABELAS FINANCEIRO --------FIM--------

USE DB_INFINITY_SCHOOL;

-- ============================================================
-- 1. PESSOA
-- ============================================================

select count(*) from tb_pessoa;

INSERT INTO tb_pessoa 
(pk_cpf, primeiro_nome, sobrenome, data_nasc, genero, deficiencia, etnia)
VALUES
('11111111111', 'Ana', 'Silva', '2005-03-12', 'Feminino', 'Nenhuma', 'Parda'),
('22222222222', 'Bruno', 'Souza', '2004-07-25', 'Masculino', 'Nenhuma', 'Branca'),
('33333333333', 'Carla', 'Oliveira', '2006-01-18', 'Feminino', 'Nenhuma', 'Preta'),
('44444444444', 'Diego', 'Santos', '2003-11-09', 'Masculino', 'Nenhuma', 'Parda'),
('55555555555', 'Eduarda', 'Lima', '2005-05-30', 'Feminino', 'Nenhuma', 'Branca'),
('66666666666', 'Felipe', 'Costa', '1985-02-14', 'Masculino', 'Nenhuma', 'Parda'),
('77777777777', 'Gabriela', 'Mendes', '1990-08-21', 'Feminino', 'Nenhuma', 'Branca'),
('88888888888', 'Henrique', 'Rocha', '1982-12-03', 'Masculino', 'Nenhuma', 'Preta'),
('99999999999', 'Isabela', 'Ferreira', '1995-04-19', 'Feminino', 'Nenhuma', 'Parda'),
('10101010101', 'Joao', 'Almeida', '1988-09-10', 'Masculino', 'Nenhuma', 'Branca'),
('12121212121', 'Lucas', 'Pereira', '1997-06-15', 'Masculino', 'Nenhuma', 'Parda'),
('13131313131', 'Mariana', 'Gomes', '1993-10-22', 'Feminino', 'Nenhuma', 'Branca'),

('14141414141', 'Rafael', 'Martins', '2002-02-11', 'Masculino', 'Nenhuma', 'Branca'),
('15151515151', 'Beatriz', 'Nunes', '2007-09-05', 'Feminino', 'Visual', 'Parda'),
('16161616161', 'Caio', 'Ribeiro', '2001-12-20', 'Masculino', 'Nenhuma', 'Preta'),
('17171717171', 'Larissa', 'Cardoso', '2006-04-14', 'Feminino', 'Nenhuma', 'Branca'),
('18181818181', 'Pedro', 'Moraes', '2004-08-30', 'Masculino', 'Auditiva', 'Parda'),
('19191919191', 'Camila', 'Barbosa', '1987-06-18', 'Feminino', 'Nenhuma', 'Branca'),
('20202020202', 'Ricardo', 'Teixeira', '1981-01-25', 'Masculino', 'Nenhuma', 'Parda'),
('21212121212', 'Patricia', 'Lopes', '1992-03-09', 'Feminino', 'Nenhuma', 'Preta'),
('23232323232', 'Sofia', 'Araujo', '2005-11-11', 'Feminino', 'Nenhuma', 'Amarela'),
('24242424242', 'Gustavo', 'Melo', '2003-07-07', 'Masculino', 'Nenhuma', 'Branca'),
('25252525252', 'Helena', 'Dias', '2008-01-19', 'Feminino', 'Nenhuma', 'Parda'),
('26262626262', 'Murilo', 'Castro', '2002-10-28', 'Masculino', 'Nenhuma', 'Branca'),
('27272727272', 'Vitoria', 'Campos', '2006-12-02', 'Feminino', 'Motora', 'Preta'),
('28282828282', 'Marcelo', 'Freitas', '1984-05-03', 'Masculino', 'Nenhuma', 'Branca'),
('29292929292', 'Renata', 'Moreira', '1991-08-17', 'Feminino', 'Nenhuma', 'Parda'),
('30303030303', 'Andre', 'Batista', '1989-09-23', 'Masculino', 'Nenhuma', 'Preta'),
('31313131313', 'Vanessa', 'Pinto', '1986-02-27', 'Feminino', 'Nenhuma', 'Branca'),
('32323232323', 'Marcos', 'Vieira', '1979-07-12', 'Masculino', 'Nenhuma', 'Parda'),
('34343434343', 'Tatiane', 'Correia', '1994-03-16', 'Feminino', 'Nenhuma', 'Branca');

-- ============================================================
-- 2. EMAIL
-- ============================================================

select count(*) from tb_email;

INSERT INTO tb_email (pk_email) VALUES
('ana.silva@email.com'), ('bruno.souza@email.com'), ('carla.oliveira@email.com'),
('diego.santos@email.com'), ('eduarda.lima@email.com'), ('felipe.costa@email.com'),
('gabriela.mendes@email.com'), ('henrique.rocha@email.com'), ('isabela.ferreira@email.com'),
('joao.almeida@email.com'), ('lucas.pereira@email.com'), ('mariana.gomes@email.com'),
('rafael.martins@email.com'), ('beatriz.nunes@email.com'), ('caio.ribeiro@email.com'),
('larissa.cardoso@email.com'), ('pedro.moraes@email.com'), ('camila.barbosa@infinity.com'),
('ricardo.teixeira@infinity.com'), ('patricia.lopes@infinity.com'), ('sofia.araujo@email.com'),
('gustavo.melo@email.com'), ('helena.dias@email.com'), ('murilo.castro@email.com'),
('vitoria.campos@email.com'), ('marcelo.freitas@infinity.com'), ('renata.moreira@infinity.com'),
('andre.batista@infinity.com'), ('vanessa.pinto@servicos.com'), ('marcos.vieira@servicos.com'),
('tatiane.correia@servicos.com'),

('contato@techsolucoes.com'),
('vendas@moveisescola.com'),
('atendimento@infobrasil.com'),
('financeiro@softwareprime.com'),
('vendas@escritoriototal.com'),
('contato@graficarapida.com');

-- ============================================================
-- 3. TELEFONE
-- ============================================================

select count(*) from tb_telefone;

INSERT INTO tb_telefone (pk_num_pais, pk_ddd, pk_numero) VALUES
('55', '11', '999991111'), ('55', '11', '999992222'), ('55', '11', '999993333'),
('55', '11', '999994444'), ('55', '11', '999995555'), ('55', '11', '988886666'),
('55', '11', '988887777'), ('55', '11', '988888888'), ('55', '11', '988889999'),
('55', '11', '977771010'), ('55', '11', '966661414'), ('55', '11', '966661515'),
('55', '11', '966661616'), ('55', '11', '966661717'), ('55', '11', '966661818'),
('55', '11', '955551919'), ('55', '11', '955552020'), ('55', '11', '955552121'),
('55', '11', '944442323'), ('55', '11', '944442424'), ('55', '11', '933332525'),
('55', '11', '933332626'), ('55', '11', '933332727'), ('55', '11', '922222828'),
('55', '11', '922222929'), ('55', '11', '922223030'), ('55', '11', '911113131'),
('55', '11', '911113232'), ('55', '11', '911113434'),

('55', '11', '999990000'),
('55', '11', '988880000'),
('55', '11', '977770000'),
('55', '11', '966660000'),
('55', '11', '955550000'),
('55', '11', '944440000');

-- ============================================================
-- 4. ENDERECO
-- ============================================================

select count(*) from tb_endereco;

INSERT INTO tb_endereco
(pk_cep, pk_numero, complemento)
VALUES
('08710000', 100, 'Casa'),
('08720000', 250, 'Apto 12'),
('08730000', 300, NULL),
('08740000', 450, 'Fundos'),
('08750000', 520, NULL),
('08760000', 80, 'Bloco B'),
('08770000', 700, 'Casa'),
('08780000', 810, 'Apto 21'),
('08790000', 920, NULL),
('08800000', 150, 'Bloco C'),
('08810000', 75, NULL),
('08820000', 640, 'Casa 2'),
('08830000', 330, 'Apto 31'),
('08840000', 410, NULL),
('08850000', 999, 'Fundos');

-- ============================================================
-- 5. PESSOA_EMAIL
-- ============================================================

select count(*) from tb_pessoa_email;

INSERT INTO tb_pessoa_email (pk_fk_email, pk_fk_cpf) VALUES
('ana.silva@email.com', '11111111111'),
('bruno.souza@email.com', '22222222222'),
('carla.oliveira@email.com', '33333333333'),
('diego.santos@email.com', '44444444444'),
('eduarda.lima@email.com', '55555555555'),
('felipe.costa@email.com', '66666666666'),
('gabriela.mendes@email.com', '77777777777'),
('henrique.rocha@email.com', '88888888888'),
('isabela.ferreira@email.com', '99999999999'),
('joao.almeida@email.com', '10101010101'),
('lucas.pereira@email.com', '12121212121'),
('mariana.gomes@email.com', '13131313131'),
('rafael.martins@email.com', '14141414141'),
('beatriz.nunes@email.com', '15151515151'),
('caio.ribeiro@email.com', '16161616161'),
('larissa.cardoso@email.com', '17171717171'),
('pedro.moraes@email.com', '18181818181'),
('camila.barbosa@infinity.com', '19191919191'),
('ricardo.teixeira@infinity.com', '20202020202'),
('patricia.lopes@infinity.com', '21212121212'),
('sofia.araujo@email.com', '23232323232'),
('gustavo.melo@email.com', '24242424242'),
('helena.dias@email.com', '25252525252'),
('murilo.castro@email.com', '26262626262'),
('vitoria.campos@email.com', '27272727272'),
('marcelo.freitas@infinity.com', '28282828282'),
('renata.moreira@infinity.com', '29292929292'),
('andre.batista@infinity.com', '30303030303'),
('vanessa.pinto@servicos.com', '31313131313'),
('marcos.vieira@servicos.com', '32323232323'),
('tatiane.correia@servicos.com', '34343434343');

-- ============================================================
-- 6. PESSOA_TELEFONE
-- ============================================================

select count(*) from tb_pessoa_telefone;

INSERT INTO tb_pessoa_telefone (pk_fk_cpf, pk_fk_num_pais, pk_fk_ddd, pk_fk_numero) VALUES
('11111111111', '55', '11', '999991111'),
('22222222222', '55', '11', '999992222'),
('33333333333', '55', '11', '999993333'),
('44444444444', '55', '11', '999994444'),
('55555555555', '55', '11', '999995555'),
('66666666666', '55', '11', '988886666'),
('77777777777', '55', '11', '988887777'),
('88888888888', '55', '11', '988888888'),
('99999999999', '55', '11', '988889999'),
('10101010101', '55', '11', '977771010'),
('14141414141', '55', '11', '966661414'),
('15151515151', '55', '11', '966661515'),
('16161616161', '55', '11', '966661616'),
('17171717171', '55', '11', '966661717'),
('18181818181', '55', '11', '966661818'),
('19191919191', '55', '11', '955551919'),
('20202020202', '55', '11', '955552020'),
('21212121212', '55', '11', '955552121'),
('23232323232', '55', '11', '944442323'),
('24242424242', '55', '11', '944442424'),
('25252525252', '55', '11', '933332525'),
('26262626262', '55', '11', '933332626'),
('27272727272', '55', '11', '933332727'),
('28282828282', '55', '11', '922222828'),
('29292929292', '55', '11', '922222929'),
('30303030303', '55', '11', '922223030'),
('31313131313', '55', '11', '911113131'),
('32323232323', '55', '11', '911113232'),
('34343434343', '55', '11', '911113434');

-- ============================================================
-- 7. PESSOA_ENDERECO
-- ============================================================

select count(*) from tb_pessoa_endereco;

INSERT INTO tb_pessoa_endereco
(pk_fk_cpf, pk_fk_cep, pk_fk_numero)
VALUES
('11111111111', '08710000', 100),
('22222222222', '08720000', 250),
('33333333333', '08730000', 300),
('44444444444', '08740000', 450),
('55555555555', '08750000', 520),
('66666666666', '08760000', 80),
('77777777777', '08710000', 100),
('88888888888', '08720000', 250),
('99999999999', '08730000', 300),
('10101010101', '08740000', 450),

('14141414141', '08770000', 700),
('15151515151', '08780000', 810),
('16161616161', '08790000', 920),
('17171717171', '08800000', 150),
('18181818181', '08810000', 75),
('19191919191', '08780000', 810),
('20202020202', '08790000', 920),
('21212121212', '08800000', 150),
('23232323232', '08820000', 640),
('24242424242', '08830000', 330),
('25252525252', '08840000', 410),
('26262626262', '08850000', 999),
('27272727272', '08770000', 700),
('28282828282', '08810000', 75),
('29292929292', '08820000', 640),
('30303030303', '08830000', 330),
('31313131313', '08840000', 410),
('32323232323', '08850000', 999),
('34343434343', '08770000', 700);

-- ============================================================
-- 8. FORMACAO
-- ============================================================

select count(*) from tb_formacao;

INSERT INTO tb_formacao
(nome_formacao)
VALUES
('Analise e Desenvolvimento de Sistemas'),
('Ciencia da Computacao'),
('Pedagogia'),
('Administracao'),
('Sistemas de Informacao'),
('Engenharia de Software'),
('Banco de Dados'),
('Design Instrucional'),
('Marketing e Comunicacao'),
('Gestao Financeira');

-- ============================================================
-- 9. DEPARTAMENTO
-- ============================================================

select count(*) from tb_departamento;

INSERT INTO tb_departamento
(pk_id_departamento, departamento)
VALUES
(1, 'Direção'),
(2, 'Coordenação'),
(3, 'Secretaria_ADM'),
(4, 'Financeiro'),
(5, 'Zeladoria'),
(6, 'Inspetoria_Segurança'),
(7, 'Biblioteca'),
(8, 'Recursos_Humanos');

-- ============================================================
-- 10. CARGO
-- ============================================================

select count(*) from tb_cargo;

INSERT INTO tb_cargo
(nome_cargo)
VALUES
('Professor'),
('Coordenador'),
('Secretario'),
('Analista Financeiro'),
('Auxiliar de Limpeza'),
('Inspetor'),
('Bibliotecario'),
('Analista de RH');

-- ============================================================
-- 11. CARGO_DEPARTAMENTO
-- ============================================================

select count(*) from tb_cargo_departamento;

INSERT INTO tb_cargo_departamento
(pk_fk_id_cargo, pk_fk_id_departamento)
VALUES
(1, 2),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8);

-- ============================================================
-- 12. FUNCIONARIO
-- ============================================================

select count(*) from tb_funcionario;

INSERT INTO tb_funcionario
(pk_n_contratacao, fk_cpf, status_funcionario, dt_admissao, dt_desligamento)
VALUES
(1001, '66666666666', 'Ativado', '2022-02-01', NULL),
(1002, '77777777777', 'Ativado', '2021-08-10', NULL),
(1003, '88888888888', 'Ativado', '2020-03-15', NULL),
(1004, '99999999999', 'Ativado', '2023-01-20', NULL),
(1005, '10101010101', 'Desativado', '2019-05-05', '2024-12-20'),
(1006, '12121212121', 'Ativado', '2024-02-12', NULL),
(1007, '13131313131', 'Ativado', '2022-09-01', NULL),
(1008, '19191919191', 'Ativado', '2023-07-01', NULL),
(1009, '20202020202', 'Ativado', '2022-04-11', NULL),
(1010, '21212121212', 'Ativado', '2024-01-08', NULL),
(1011, '28282828282', 'Ativado', '2021-03-14', NULL),
(1012, '29292929292', 'Ativado', '2023-10-02', NULL),
(1013, '30303030303', 'Desativado', '2020-02-01', '2025-02-15');

-- ============================================================
-- 13. FUNC_CARGO
-- ============================================================

select count(*) from tb_func_cargo;

INSERT INTO tb_func_cargo
(pk_fk_n_contratacao, pk_fk_id_cargo, pk_fk_id_departamento, pk_data_inicio, data_fim)
VALUES
(1001, 1, 2, '2022-02-01', NULL),
(1002, 2, 2, '2021-08-10', NULL),
(1003, 4, 4, '2020-03-15', NULL),
(1004, 3, 3, '2023-01-20', NULL),
(1005, 6, 6, '2019-05-05', '2024-12-20'),
(1006, 7, 7, '2024-02-12', NULL),
(1007, 8, 8, '2022-09-01', NULL),
(1008, 1, 2, '2023-07-01', NULL),
(1009, 1, 2, '2022-04-11', NULL),
(1010, 4, 4, '2024-01-08', NULL),
(1011, 1, 2, '2021-03-14', NULL),
(1012, 3, 3, '2023-10-02', NULL),
(1013, 5, 5, '2020-02-01', '2025-02-15');

-- ============================================================
-- 14. FUNCIONARIO_FORMACAO
-- ============================================================

select count(*) from tb_funcionario_formacao;

INSERT INTO tb_funcionario_formacao 
(pk_fk_n_contratacao, pk_fk_id_formacao, dt_conclusao, instituicao)
VALUES

(1001, 1, '2020-12-15', 'FIAP'),
(1008, 2, '2021-06-30', 'USP'),
(1009, 5, '2019-11-20', 'Mackenzie'),
(1011, 6, '2022-01-10', 'PUC'),

(1002, 4, '2018-05-20', 'FGV'),          -- Administrador
(1003, 10, '2015-12-01', 'FATEC'),       -- Gestão Financeira
(1004, 9, '2022-12-18', 'Anhembi'),      -- Marketing
(1005, 3, '2010-07-15', 'Unicamp'),      -- Pedagogia
(1006, 7, '2023-12-01', 'Impacta'),      -- Banco de Dados
(1007, 8, '2021-02-10', 'Senac'),        -- Design Instrucional
(1010, 1, '2023-06-15', 'Infinity School'), 
(1012, 4, '2020-01-20', 'UFRJ'),
(1013, 2, '2017-08-30', 'UFMG');

-- ============================================================
-- 15. FERIAS
-- ============================================================

select count(*) from tb_ferias;

INSERT INTO tb_ferias
(fk_n_contratacao, dias_ferias, data_inicio, data_fim, status_ferias)
VALUES
(1001, 30, '2025-01-10', '2025-02-08', 'Concluida'),
(1002, 15, '2025-07-01', '2025-07-15', 'Agendada'),
(1003, 20, '2025-03-05', '2025-03-24', 'Concluida'),
(1004, 10, '2025-09-10', '2025-09-19', 'Agendada'),
(1006, 30, '2025-12-01', '2025-12-30', 'Agendada'),
(1008, 15, '2025-08-01', '2025-08-15', 'Agendada'),
(1009, 20, '2025-10-05', '2025-10-24', 'Agendada'),
(1010, 10, '2025-06-10', '2025-06-19', 'Concluida'),
(1011, 30, '2025-11-01', '2025-11-30', 'Agendada'),
(1012, 15, '2025-12-05', '2025-12-19', 'Agendada'),
(1013, 20, '2024-08-01', '2024-08-20', 'Concluida');

-- ============================================================
-- 16. PONTO
-- ============================================================

select count(*) from tb_ponto;

INSERT INTO tb_ponto
(fk_n_contratacao, `data`, hora_entrada, hora_saida)
VALUES
(1001, '2025-05-01', '08:00:00', '17:00:00'),
(1002, '2025-05-01', '08:30:00', '17:30:00'),
(1003, '2025-05-01', '09:00:00', '18:00:00'),
(1004, '2025-05-01', '08:00:00', '17:00:00'),
(1006, '2025-05-01', '10:00:00', '19:00:00'),
(1007, '2025-05-01', '08:00:00', NULL),

(1001, '2025-05-02', '08:00:00', '17:00:00'),
(1002, '2025-05-02', '08:30:00', '17:30:00'),
(1003, '2025-05-02', '09:00:00', '18:00:00'),
(1004, '2025-05-02', '08:00:00', '17:00:00'),
(1006, '2025-05-02', '10:00:00', '19:00:00'),
(1007, '2025-05-02', '08:00:00', NULL),
(1008, '2025-05-02', '13:00:00', '22:00:00'),
(1009, '2025-05-02', '18:00:00', '22:00:00'),
(1010, '2025-05-02', '09:00:00', NULL),
(1011, '2025-05-02', '07:30:00', '16:30:00'),
(1012, '2025-05-02', '08:15:00', '17:15:00'),

(1001, '2025-05-03', '08:00:00', '17:00:00'),
(1002, '2025-05-03', '08:30:00', '17:30:00'),
(1008, '2025-05-03', '13:00:00', '22:00:00'),
(1009, '2025-05-03', '18:00:00', '22:00:00'),
(1011, '2025-05-03', '07:30:00', '16:30:00');

-- ============================================================
-- 17. FOLHA_PAGAMENTO
-- ============================================================

select count(*) from tb_folha_pagamento;

INSERT INTO tb_folha_pagamento
(pk_id_folha, fk_n_contratacao, salario_base, data_pagamento)
VALUES
(1, 1001, 4500.00, '2025-05-05'),
(2, 1002, 5200.00, '2025-05-05'),
(3, 1003, 3800.00, '2025-05-05'),
(4, 1004, 3000.00, '2025-05-05'),
(5, 1006, 2800.00, '2025-05-05'),
(6, 1007, 3500.00, '2025-05-05'),
(7, 1008, 4200.00, '2025-05-05'),
(8, 1009, 6100.00, '2025-05-05'),
(9, 1010, 3900.00, '2025-05-05'),
(10, 1011, 5800.00, '2025-05-05'),
(11, 1012, 3100.00, '2025-05-05'),

(12, 1001, 4600.00, '2025-06-05'),
(13, 1002, 5300.00, '2025-06-05'),
(14, 1008, 4200.00, '2025-06-05'),
(15, 1009, 6100.00, '2025-06-05'),
(16, 1011, 5800.00, '2025-06-05'),
(17, 1012, 3100.00, '2025-06-05');

-- ============================================================
-- 18. HISTORICO_PAGAMENTO
-- ============================================================

select count(*) from tb_historico_pagamento;

INSERT INTO tb_historico_pagamento
(fk_n_contratacao, salario_atual, data_alteracao)
VALUES
(1001, 4500.00, '2025-01-01'),
(1002, 5200.00, '2025-01-01'),
(1003, 3800.00, '2025-01-01'),
(1004, 3000.00, '2025-01-01'),
(1006, 2800.00, '2025-01-01'),
(1007, 3500.00, '2025-01-01'),
(1001, 4600.00, '2025-06-01'),
(1002, 5300.00, '2025-06-01'),
(1008, 4200.00, '2025-05-01'),
(1009, 6100.00, '2025-05-01'),
(1010, 3900.00, '2025-05-01'),
(1011, 5800.00, '2025-05-01'),
(1012, 3100.00, '2025-05-01'),
(1013, 2900.00, '2024-01-01');

-- ============================================================
-- 19. PROVENTO
-- ============================================================

select count(*) from tb_provento;

INSERT INTO tb_provento
(fk_id_folha, tipo, valor)
VALUES
(1, 'Vale Alimentacao', 500.00),
(2, 'Bonus Coordenacao', 800.00),
(3, 'Hora Extra', 300.00),
(4, 'Vale Transporte', 250.00),
(5, 'Auxilio Biblioteca', 150.00),
(6, 'Bonus RH', 200.00),
(7, 'Hora Extra', 350.00),
(8, 'Bonus Performance', 900.00),
(9, 'Vale Alimentacao', 500.00),
(10, 'Bonus Docente', 750.00),
(11, 'Vale Transporte', 250.00),
(12, 'Vale Alimentacao', 500.00),
(13, 'Bonus Coordenacao', 850.00),
(14, 'Auxilio Docente', 300.00),
(15, 'Bonus Performance', 1000.00),
(16, 'Hora Extra', 400.00),
(17, 'Vale Transporte', 250.00);

-- ============================================================
-- 20. DESCONTO
-- ============================================================

select count(*) from tb_desconto;

INSERT INTO tb_desconto
(fk_id_folha, tipo, valor)
VALUES
(1, 'INSS', 450.00),
(2, 'INSS', 520.00),
(3, 'INSS', 380.00),
(4, 'INSS', 300.00),
(5, 'INSS', 280.00),
(6, 'INSS', 350.00),
(7, 'INSS', 420.00),
(8, 'INSS', 610.00),
(9, 'INSS', 390.00),
(10, 'INSS', 580.00),
(11, 'INSS', 310.00),
(12, 'INSS', 460.00),
(13, 'INSS', 530.00),
(14, 'INSS', 420.00),
(15, 'INSS', 610.00),
(16, 'INSS', 580.00),
(17, 'INSS', 310.00);

-- ============================================================
-- 21. AFASTAMENTO
-- ============================================================

select count(*) from tb_afastamento;

INSERT INTO tb_afastamento
(fk_n_contratacao, motivo, status, data_inicio, data_fim)
VALUES
(1003, 'Licenca medica', 'Concluído', '2024-10-01', '2024-10-15'),
(1004, 'Afastamento administrativo', 'Concluído', '2024-11-05', '2024-11-10'),
(1006, 'Licenca familiar', 'Em_Andamento', '2025-04-01', NULL),
(1008, 'Licenca medica curta', 'Concluído', '2025-03-10', '2025-03-12'),
(1009, 'Afastamento por evento academico', 'Concluído', '2025-04-20', '2025-04-25'),
(1011, 'Licenca medica', 'Em_Andamento', '2025-05-15', NULL),
(1012, 'Afastamento administrativo', 'Concluído', '2025-02-01', '2025-02-05');

-- ============================================================
-- 22. TREINAMENTO
-- ============================================================

select count(*) from tb_treinamento;

INSERT INTO tb_treinamento
(fk_n_contratacao, tipo_treinamento, carga_horaria, data_inicio, data_conclusao)
VALUES
(1001, 'Metodologias Ativas', 20, '2025-02-01', '2025-02-10'),
(1002, 'Gestao Escolar', 30, '2025-03-01', '2025-03-20'),
(1003, 'Excel Financeiro', 15, '2025-01-15', '2025-01-25'),
(1004, 'Atendimento ao Aluno', 10, '2025-04-05', '2025-04-06'),
(1007, 'Recrutamento e Selecao', 25, '2025-05-10', NULL),
(1008, 'Didatica para Tecnologia', 18, '2025-06-01', '2025-06-10'),
(1009, 'Power BI Avancado', 24, '2025-06-15', NULL),
(1010, 'Gestao Financeira Escolar', 20, '2025-07-01', '2025-07-12'),
(1011, 'Arquitetura de Software', 30, '2025-05-20', NULL),
(1012, 'Atendimento e Secretaria Escolar', 12, '2025-03-15', '2025-03-20');

-- ============================================================
-- 23. UNIDADE
-- ============================================================

select count(*) from tb_unidade;

INSERT INTO tb_unidade
(pk_id_unidade, nome_unidade, logradouro, num_logradouro, complemento)
VALUES
(1, 'Infinity Salvador', 'Alameda Salvador', '1057', 'Edf. Salvador Shopping Business, Torre Europa, Sala 310'),
(2, 'Infinity Fortaleza', 'Avenida Santos Dumont', 'S/N', 'Aldeota'),
(3, 'Infinity Belo Horizonte', 'Avenida do Contorno', '6480', 'Loja 01, Savassi'),
(4, 'Infinity Recife', 'Avenida República do Líbano', '256', 'Pina'),
(5, 'Infinity São Paulo', 'Avenida Paulista', '777', 'Edf. Viking, Sala 12');

-- ============================================================
-- 24. CURSO
-- ============================================================

select count(*) from tb_curso;

INSERT INTO tb_curso
(pk_id_curso, nome_curso, duracao_meses, idade_min, idade_max)
VALUES
(1, 'Programacao Full Stack', 24, 14, NULL),
(2, 'Design Digital', 18, 12, NULL),
(3, 'Marketing Digital', 12, 14, NULL),
(4, 'Data Analytics', 18, 16, NULL),
(5, 'Cybersecurity', 18, 16, NULL),
(6, 'Inteligencia Artificial', 24, 16, NULL),
(7, 'Games e Criacao Digital', 20, 12, NULL);

-- ============================================================
-- 25. ALUNO
-- ============================================================

select count(*) from tb_aluno;

INSERT INTO tb_aluno
(pk_ra, fk_cpf)
VALUES
('RA0001', '11111111111'),
('RA0002', '22222222222'),
('RA0003', '33333333333'),
('RA0004', '44444444444'),
('RA0005', '55555555555'),
('RA0006', '14141414141'),
('RA0007', '15151515151'),
('RA0008', '16161616161'),
('RA0009', '17171717171'),
('RA0010', '18181818181'),
('RA0011', '23232323232'),
('RA0012', '24242424242'),
('RA0013', '25252525252'),
('RA0014', '26262626262'),
('RA0015', '27272727272');

-- ============================================================
-- 26. DISCIPLINA
-- ============================================================

select count(*) from tb_disciplina;

INSERT INTO tb_disciplina
(pk_fk_id_curso, pk_id_disciplina, disciplina)
VALUES
(1, 1, 'Logica de Programacao'),
(1, 2, 'Banco de Dados'),
(1, 3, 'Desenvolvimento Web'),
(2, 1, 'Design Grafico'),
(2, 2, 'UX UI'),
(3, 1, 'Midias Sociais'),
(3, 2, 'Copywriting'),
(3, 3, 'Trafego Pago'),
(4, 1, 'Excel para Dados'),
(4, 2, 'SQL para Dados'),
(5, 1, 'Fundamentos de Redes'),
(5, 2, 'Seguranca da Informacao'),
(5, 3, 'Pentest Basico'),
(6, 1, 'Python para IA'),
(6, 2, 'Machine Learning'),
(6, 3, 'Etica em IA'),
(7, 1, 'Game Design'),
(7, 2, 'Unity Basico'),
(7, 3, 'Arte para Games');

-- ============================================================
-- 27. TURMA
-- ============================================================

select count(*) from tb_turma;

INSERT INTO tb_turma
(pk_id_turma, fk_n_contratacao, fk_id_curso, fk_id_disciplina, fk_id_unidade, data_inicio, turno)
VALUES
(1, 1001, 1, 1, 1, '2025-02-01', 'Matutino'),
(2, 1001, 1, 2, 1, '2025-03-01', 'Vespertino'),
(3, 1001, 4, 1, 2, '2025-02-10', 'Noturno'),
(4, 1001, 4, 2, 2, '2025-03-10', 'Noturno'),
(5, 1001, 2, 1, 3, '2025-04-01', 'Matutino'),
(6, 1008, 1, 3, 1, '2025-04-15', 'Noturno'),
(7, 1008, 2, 2, 3, '2025-05-01', 'Vespertino'),
(8, 1009, 3, 1, 1, '2025-06-01', 'Matutino'),
(9, 1009, 4, 2, 2, '2025-06-15', 'Noturno'),
(10, 1001, 1, 2, 3, '2025-07-01', 'Matutino'),
(11, 1011, 5, 1, 4, '2025-08-01', 'Noturno'),
(12, 1011, 5, 2, 5, '2025-08-10', 'Vespertino'),
(13, 1009, 6, 1, 2, '2025-09-01', 'Noturno'),
(14, 1009, 6, 2, 4, '2025-09-15', 'Matutino'),
(15, 1008, 7, 1, 5, '2025-10-01', 'Vespertino');

-- ============================================================
-- 28. MATRICULA
-- ============================================================

select count(*) from tb_matricula;

INSERT INTO tb_matricula 
(pk_fk_ra, pk_fk_id_turma, data_matricula, status_matricula, nota1, nota2, nota3, nota4, total_faltas) 
VALUES
('RA0001', 1, '2025-01-10', 'Aprovado', 8.50, 9.00, 9.50, 9.00, 2),
('RA0003', 2, '2025-01-12', 'Aprovado', 7.00, 7.50, 8.00, 8.50, 5),
('RA0005', 3, '2025-01-15', 'Aprovado', 9.50, 10.0, 9.00, 9.50, 1),
('RA0002', 1, '2025-01-10', 'Reprovado', 4.50, 5.00, 3.00, 4.00, 18),
('RA0010', 4, '2025-01-20', 'Reprovado', 5.50, 4.00, 6.00, 5.00, 22),
('RA0007', 5, '2025-01-15', 'Evadido', 3.00, 2.50, NULL, NULL, 35),
('RA0015', 6, '2025-02-01', 'Evadido', 6.00, NULL, NULL, NULL, 40),
('RA0004', 2, '2025-01-18', 'Aprovado', 6.50, 6.00, 7.00, 6.50, 8),
('RA0001', 7, '2026-01-15', 'Cursando', 9.00, NULL, NULL, NULL, 0),
('RA0002', 7, '2026-01-15', 'Cursando', 4.00, NULL, NULL, NULL, 10),
('RA0006', 8, '2026-01-20', 'Cursando', 5.50, NULL, NULL, NULL, 15),
('RA0008', 9, '2026-01-22', 'Cursando', 8.50, NULL, NULL, NULL, 2),
('RA0013', 10, '2026-02-05', 'Trancado', 6.00, NULL, NULL, NULL, 5),
('RA0009', 11, '2026-02-10', 'Cursando', 7.00, NULL, NULL, NULL, 3),
('RA0014', 12, '2026-02-15', 'Cursando', 2.50, NULL, NULL, NULL, 28);

-- ============================================================
-- 29. GRADE_HORARIA
-- ============================================================

select count(*) from tb_grade_horaria;

INSERT INTO tb_grade_horaria
(pk_fk_id_turma, pk_dia_semana, pk_hora_inicio, hora_fim)
VALUES
(1, 'seg', '08:00:00', '10:00:00'),
(1, 'qua', '08:00:00', '10:00:00'),
(2, 'ter', '14:00:00', '16:00:00'),
(2, 'qui', '14:00:00', '16:00:00'),
(3, 'seg', '19:00:00', '21:00:00'),
(4, 'qua', '19:00:00', '21:00:00'),
(5, 'sex', '08:00:00', '11:00:00'),
(6, 'seg', '19:00:00', '21:00:00'),
(6, 'qua', '19:00:00', '21:00:00'),
(7, 'ter', '15:00:00', '17:00:00'),
(7, 'qui', '15:00:00', '17:00:00'),
(8, 'seg', '08:00:00', '10:00:00'),
(8, 'qua', '08:00:00', '10:00:00'),
(9, 'ter', '19:00:00', '21:00:00'),
(9, 'qui', '19:00:00', '21:00:00'),
(10, 'sex', '08:00:00', '11:00:00'),
(11, 'seg', '19:00:00', '21:00:00'),
(11, 'qua', '19:00:00', '21:00:00'),
(12, 'ter', '15:00:00', '17:00:00'),
(12, 'qui', '15:00:00', '17:00:00'),
(13, 'seg', '19:00:00', '21:00:00'),
(13, 'qua', '19:00:00', '21:00:00'),
(14, 'ter', '08:00:00', '10:00:00'),
(14, 'qui', '08:00:00', '10:00:00'),
(15, 'sex', '15:00:00', '18:00:00');

-- ============================================================
-- 30. CONTRATO
-- ============================================================

select count(*) from tb_contrato;

INSERT INTO tb_contrato
(pk_registro_nrcontrato, fk_ra, fk_id_turma, data_inicio, data_fim, status_contrato)
VALUES
(1, 'RA0001', 1, '2025-02-01', '2027-02-01', 'Ativo'),
(2, 'RA0002', 1, '2025-02-01', '2027-02-01', 'Ativo'),
(3, 'RA0003', 2, '2025-03-01', '2027-03-01', 'Ativo'),
(4, 'RA0004', 3, '2025-02-10', '2026-08-10', 'Ativo'),
(5, 'RA0005', 4, '2025-03-10', '2026-09-10', 'Ativo'),
(6, 'RA0001', 2, '2025-03-01', '2027-03-01', 'Ativo'),
(7, 'RA0002', 2, '2025-03-01', '2027-03-01', 'Bloqueado'),
(8, 'RA0003', 6, '2025-04-15', '2027-04-15', 'Ativo'),
(9, 'RA0004', 6, '2025-04-15', '2027-04-15', 'Trancado'),
(10, 'RA0005', 7, '2025-05-01', '2026-11-01', 'Ativo'),
(11, 'RA0006', 6, '2025-04-15', '2027-04-15', 'Ativo'),
(12, 'RA0007', 7, '2025-05-01', '2026-11-01', 'Bloqueado'),
(13, 'RA0008', 8, '2025-06-01', '2026-06-01', 'Ativo'),
(14, 'RA0009', 9, '2025-06-15', '2026-12-15', 'Ativo'),
(15, 'RA0010', 9, '2025-06-15', '2026-12-15', 'Bloqueado'),
(16, 'RA0011', 10, '2025-07-01', '2027-07-01', 'Ativo'),
(17, 'RA0012', 10, '2025-07-01', '2027-07-01', 'Ativo'),
(18, 'RA0013', 11, '2025-08-01', '2027-02-01', 'Ativo'),
(19, 'RA0014', 12, '2025-08-10', '2027-02-10', 'Ativo'),
(20, 'RA0015', 13, '2025-09-01', '2027-09-01', 'Trancado');

-- ============================================================
-- 31. MENSALIDADE
-- ============================================================

select count(*) from tb_mensalidade;

INSERT INTO tb_mensalidade
(pk_nsu, fk_registro_nrcontrato, data_emissao, data_vencimento, valor, status_mensalidade)
VALUES
(1, 1, '2025-05-01', '2025-05-10', 450.00, 'Pago'),
(2, 2, '2025-05-01', '2025-05-10', 450.00, 'Pendente'),
(3, 3, '2025-05-01', '2025-05-10', 500.00, 'Atrasado'),
(4, 4, '2025-05-01', '2025-05-10', 600.00, 'Pago'),
(5, 5, '2025-05-01', '2025-05-10', 600.00, 'Pendente'),

(6, 1, '2025-06-01', '2025-06-10', 450.00, 'Pago'),
(7, 2, '2025-06-01', '2025-06-10', 450.00, 'Atrasado'),
(8, 3, '2025-06-01', '2025-06-10', 500.00, 'Pago'),
(9, 4, '2025-06-01', '2025-06-10', 600.00, 'Pago'),
(10, 5, '2025-06-01', '2025-06-10', 600.00, 'Pendente'),
(11, 6, '2025-06-01', '2025-06-10', 450.00, 'Pago'),
(12, 7, '2025-06-01', '2025-06-10', 450.00, 'Atrasado'),
(13, 8, '2025-06-01', '2025-06-10', 520.00, 'Pago'),
(14, 9, '2025-06-01', '2025-06-10', 520.00, 'Pendente'),
(15, 10, '2025-06-01', '2025-06-10', 480.00, 'Pago'),
(16, 11, '2025-06-01', '2025-06-10', 520.00, 'Pago'),
(17, 12, '2025-06-01', '2025-06-10', 480.00, 'Atrasado'),

(18, 13, '2025-07-01', '2025-07-10', 500.00, 'Pago'),
(19, 14, '2025-07-01', '2025-07-10', 600.00, 'Pendente'),
(20, 15, '2025-07-01', '2025-07-10', 600.00, 'Atrasado'),
(21, 16, '2025-07-01', '2025-07-10', 450.00, 'Pago'),
(22, 17, '2025-07-01', '2025-07-10', 450.00, 'Pago'),
(23, 1, '2025-07-01', '2025-07-10', 450.00, 'Pago'),
(24, 2, '2025-07-01', '2025-07-10', 450.00, 'Atrasado'),
(25, 3, '2025-07-01', '2025-07-10', 500.00, 'Pendente'),
(26, 8, '2025-07-01', '2025-07-10', 520.00, 'Pago'),
(27, 11, '2025-07-01', '2025-07-10', 520.00, 'Pago'),
(28, 12, '2025-07-01', '2025-07-10', 480.00, 'Atrasado'),

(29, 18, '2025-08-01', '2025-08-10', 700.00, 'Pago'),
(30, 19, '2025-08-01', '2025-08-10', 700.00, 'Pendente'),
(31, 20, '2025-08-01', '2025-08-10', 750.00, 'Atrasado');

-- ============================================================
-- 32. INADIMPLENCIA
-- ============================================================

select count(*) from tb_inadimplencia;

INSERT INTO tb_inadimplencia
(fk_nsu, data_registro, multa, juros)
VALUES
(3, '2025-05-15', 20.00, 5.00),
(7, '2025-06-15', 18.00, 6.00),
(12, '2025-06-15', 18.00, 6.00),
(17, '2025-06-15', 19.20, 7.00),
(20, '2025-07-15', 24.00, 8.00),
(24, '2025-07-15', 18.00, 6.50),
(28, '2025-07-15', 19.20, 7.20),
(31, '2025-08-15', 30.00, 10.00);

-- ============================================================
-- 33. PRODUTO
-- ============================================================

select count(*) from tb_produto;

INSERT INTO tb_produto
(pk_id_produto, nome_produto)
VALUES
(1, 'Notebook'),
(2, 'Mouse'),
(3, 'Teclado'),
(4, 'Monitor'),
(5, 'Cadeira'),
(6, 'Mesa'),
(7, 'Projetor'),
(8, 'Headset'),
(9, 'Licenca Software'),
(10, 'Roteador'),
(11, 'Quadro Branco'),
(12, 'Webcam'),
(13, 'HD Externo'),
(14, 'Cabo HDMI'),
(15, 'Material Grafico');

-- ============================================================
-- 34. FORNECEDOR
-- ============================================================

select count(*) from tb_fornecedor;

INSERT INTO tb_fornecedor (pk_cnpj, razao_social, nome_fantasia)
VALUES
('11111111000111', 'Tech Solucoes LTDA', 'Tech Solucoes'),
('22222222000122', 'Moveis Escola LTDA', 'Moveis Escola'),
('33333333000133', 'Info Brasil LTDA', 'Info Brasil'),
('44444444000144', 'Software Prime LTDA', 'Software Prime'),
('55555555000155', 'Escritorio Total LTDA', 'Escritorio Total'),
('66666666000166', 'Grafica Rapida LTDA', 'Grafica Rapida');

-- ============================================================
-- 35. FORNECEDOR_EMAIL
-- ============================================================

select count(*) from tb_fornecedor_email;

INSERT INTO tb_fornecedor_email (pk_fk_email, pk_fk_cnpj)
VALUES
('contato@techsolucoes.com', '11111111000111'),
('vendas@moveisescola.com', '22222222000122'),
('atendimento@infobrasil.com', '33333333000133'),
('financeiro@softwareprime.com', '44444444000144'),
('vendas@escritoriototal.com', '55555555000155'),
('contato@graficarapida.com', '66666666000166');

-- ============================================================
-- 36. FORNECEDOR_TELEFONE
-- ============================================================

select count(*) from tb_fornecedor_telefone;

INSERT INTO tb_fornecedor_telefone (pk_fk_num_pais,pk_fk_ddd, pk_fk_numero, pk_fk_cnpj)
VALUES
('55', '11', '999990000', '11111111000111'),
('55', '11', '988880000', '22222222000122'),
('55', '11', '977770000', '33333333000133'),
('55', '11', '966660000', '44444444000144'),
('55', '11', '955550000', '55555555000155'),
('55', '11', '944440000', '66666666000166');

-- ============================================================
-- 37. COMPRA
-- ============================================================

select count(*) from tb_compra;

INSERT INTO tb_compra
(pk_nfe, fk_cnpj)
VALUES
('11111111111111111111111111111111111111111111', '11111111000111'),
('22222222222222222222222222222222222222222222', '22222222000122'),
('33333333333333333333333333333333333333333333', '33333333000133'),
('44444444444444444444444444444444444444444444', '44444444000144'),
('55555555555555555555555555555555555555555555', '55555555000155'),
('66666666666666666666666666666666666666666666', '66666666000166');

-- ============================================================
-- 38. SERVICO
-- ============================================================

select count(*) from tb_servico;

INSERT INTO tb_servico
(pk_id_servico, desc_servico, valor_servico, fk_cpf, data_hora)
VALUES
(1, 'Manutencao eletrica', 800.00, '88888888888', '2025-05-07 09:00:00'),
(2, 'Consultoria pedagogica', 1200.00, '77777777777', '2025-05-08 14:30:00'),
(3, 'Limpeza especializada', 600.00, '10101010101', '2025-05-09 08:00:00'),
(4, 'Treinamento corporativo', 2500.00, '19191919191', '2025-06-12 10:00:00'),
(5, 'Manutencao de rede', 950.00, '20202020202', '2025-06-18 09:30:00'),
(6, 'Consultoria financeira', 1800.00, '21212121212', '2025-07-03 15:00:00'),
(7, 'Manutencao predial', 1300.00, '31313131313', '2025-07-08 08:00:00'),
(8, 'Suporte audiovisual', 700.00, '32323232323', '2025-07-18 13:30:00'),
(9, 'Palestra de carreira', 1600.00, '34343434343', '2025-08-05 19:00:00');

-- ============================================================
-- 39. CONTA_PAGAR
-- ============================================================

select count(*) from tb_conta_pagar;

INSERT INTO tb_conta_pagar
(fk_nfe, fk_id_servico, data_pagamento, data_vencimento)
VALUES
('11111111111111111111111111111111111111111111', NULL, '2025-05-05', '2025-05-15'),
('22222222222222222222222222222222222222222222', NULL, '2025-05-06', '2025-05-16'),
(NULL, 1, '2025-05-07', '2025-05-17'),
(NULL, 2, '2025-05-08', '2025-05-18'),
('33333333333333333333333333333333333333333333', NULL, '2025-05-10', '2025-05-20'),
('44444444444444444444444444444444444444444444', NULL, '2025-06-15', '2025-06-25'),
('55555555555555555555555555555555555555555555', NULL, '2025-06-20', '2025-06-30'),
('66666666666666666666666666666666666666666666', NULL, '2025-07-02', '2025-07-12'),
(NULL, 4, '2025-06-12', '2025-06-22'),
(NULL, 5, '2025-06-18', '2025-06-28'),
(NULL, 6, '2025-07-03', '2025-07-13'),
(NULL, 7, '2025-07-08', '2025-07-18'),
(NULL, 8, '2025-07-18', '2025-07-28'),
(NULL, 9, '2025-08-05', '2025-08-15');

-- ============================================================
-- 40. ITEM_COMPRA
-- ============================================================

select count(*) from tb_item_compra;

INSERT INTO tb_item_compra
(pk_fk_nfe, pk_fk_id_produto, valor_unitario, qtd)
VALUES
('11111111111111111111111111111111111111111111', 1, 3500.00, 5),
('11111111111111111111111111111111111111111111', 2, 80.00, 10),
('11111111111111111111111111111111111111111111', 3, 120.00, 10),
('22222222222222222222222222222222222222222222', 5, 700.00, 15),
('22222222222222222222222222222222222222222222', 6, 900.00, 10),
('33333333333333333333333333333333333333333333', 4, 1200.00, 6),
('33333333333333333333333333333333333333333333', 7, 2500.00, 2),
('44444444444444444444444444444444444444444444', 9, 1200.00, 20),
('44444444444444444444444444444444444444444444', 10, 350.00, 6),
('44444444444444444444444444444444444444444444', 12, 220.00, 10),
('55555555555555555555555555555555555555555555', 8, 180.00, 25),
('55555555555555555555555555555555555555555555', 11, 450.00, 8),
('55555555555555555555555555555555555555555555', 13, 390.00, 5),
('66666666666666666666666666666666666666666666', 14, 35.00, 30),
('66666666666666666666666666666666666666666666', 15, 120.00, 50);

-- ============================================================
-- 41. CONTA_RECEBER
-- ============================================================

select count(*) from tb_conta_receber;

INSERT INTO tb_conta_receber
(pk_id_conta_receber, fk_nsu, data_prevista, data_recebimento)
VALUES
(1, 1, '2025-05-10', '2025-05-09'),
(2, 2, '2025-05-10', NULL),
(3, 3, '2025-05-10', NULL),
(4, 4, '2025-05-10', '2025-05-10'),
(5, 5, '2025-05-10', NULL),

(6, 6, '2025-06-10', '2025-06-09'),
(7, 7, '2025-06-10', NULL),
(8, 8, '2025-06-10', '2025-06-10'),
(9, 9, '2025-06-10', '2025-06-08'),
(10, 10, '2025-06-10', NULL),
(11, 11, '2025-06-10', '2025-06-09'),
(12, 12, '2025-06-10', NULL),
(13, 13, '2025-06-10', '2025-06-10'),
(14, 14, '2025-06-10', NULL),
(15, 15, '2025-06-10', '2025-06-07'),
(16, 16, '2025-06-10', '2025-06-10'),
(17, 17, '2025-06-10', NULL),

(18, 18, '2025-07-10', '2025-07-09'),
(19, 19, '2025-07-10', NULL),
(20, 20, '2025-07-10', NULL),
(21, 21, '2025-07-10', '2025-07-08'),
(22, 22, '2025-07-10', '2025-07-10'),
(23, 23, '2025-07-10', '2025-07-09'),
(24, 24, '2025-07-10', NULL),
(25, 25, '2025-07-10', NULL),
(26, 26, '2025-07-10', '2025-07-10'),
(27, 27, '2025-07-10', '2025-07-09'),
(28, 28, '2025-07-10', NULL),

(29, 29, '2025-08-10', '2025-08-09'),
(30, 30, '2025-08-10', NULL),
(31, 31, '2025-08-10', NULL);

-- ============================================================
-- 42. PAGAMENTO
-- ============================================================

select count(*) from tb_pagamento;

INSERT INTO tb_pagamento
(fk_id_conta_receber, valor_pago, data_pagamento, forma_pagamento)
VALUES
(1, 450.00, '2025-05-09', 'pix'),
(4, 600.00, '2025-05-10', 'credito'),

(6, 450.00, '2025-06-09', 'pix'),
(8, 500.00, '2025-06-10', 'boleto'),
(9, 600.00, '2025-06-08', 'credito'),
(11, 450.00, '2025-06-09', 'pix'),
(13, 520.00, '2025-06-10', 'debito'),
(15, 480.00, '2025-06-07', 'pix'),
(16, 520.00, '2025-06-10', 'credito'),

(18, 500.00, '2025-07-09', 'pix'),
(21, 450.00, '2025-07-08', 'dinheiro'),
(22, 450.00, '2025-07-10', 'credito'),
(23, 450.00, '2025-07-09', 'boleto'),
(26, 520.00, '2025-07-10', 'pix'),
(27, 520.00, '2025-07-09', 'debito'),

(29, 700.00, '2025-08-09', 'pix');

-- -----------------------------------------------
use DB_INFINITY_SCHOOL;

-- TABELAS DE DIMENSÃO --------INICIO--------

CREATE TABLE dim_aluno (
    sk_aluno INT PRIMARY KEY AUTO_INCREMENT,
    ra VARCHAR(10) NOT NULL,
    cpf CHAR(11) NOT NULL unique,
    nome_completo VARCHAR(150) NOT NULL,
    genero varchar(10),
    etnia varchar(50),
    deficiencia varchar(20),
    data_nascimento DATE NOT NULL
);

CREATE TABLE dim_funcionario (
	sk_funcionario int PRIMARY KEY AUTO_INCREMENT,
	n_contratacao INT NOT NULL,
	cpf CHAR(11) NOT NULL UNIQUE,
	nome_completo VARCHAR(150) NOT NULL,
    genero varchar(10),
    etnia varchar(50),
    deficiencia varchar(20),
    data_nascimento DATE NOT NULL,
	status_funcionario VARCHAR(20),
	cargo VARCHAR(50),
	departamento varchar(50),
	formacao VARCHAR(255)
);

CREATE TABLE dim_unidade (
	sk_unidade INT PRIMARY KEY AUTO_INCREMENT,
    id_unidade INT UNIQUE,
	nome_unidade varchar(50),
	logradouro varchar(100),
	num_logradouro varchar(10),
	complemento varchar(50)
);

CREATE TABLE dim_turma (
    sk_turma INT PRIMARY KEY AUTO_INCREMENT,
    id_turma int unique,
    cod_turma_operacional VARCHAR(120), -- Ex: 'ADS-101-2026'
    nome_disciplina VARCHAR(50),       -- Atributo da disciplina
    nome_curso VARCHAR(50),            -- Atributo do curso
    turno varchar(20),
    nome_professor_titular varchar(150),
    data_inicio_turma DATE,
    duracao_meses_curso INT,
    carga_horaria_disciplina INT
);

CREATE TABLE dim_forma_pagamento (
    sk_forma_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    forma_pagamento VARCHAR(30) NOT NULL unique -- Ex: 'Cartão de Crédito', 'Pix'
);

CREATE TABLE dim_fornecedor (
    sk_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    cnpj CHAR(14) NOT NULL unique,
    razao_social VARCHAR(100),
    nome_fantasia VARCHAR(45)
);

CREATE TABLE dim_status (
    sk_status INT PRIMARY KEY AUTO_INCREMENT,
    status_nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dim_natureza_financeira (
    sk_natureza INT AUTO_INCREMENT PRIMARY KEY,
    codigo_operacional INT, -- 1 para Receita, 2 para Encargo, 3 para Despesa
    nome_natureza VARCHAR(50) UNIQUE,
    tipo_movimentacao ENUM('ENTRADA', 'SAÍDA')
);

CREATE TABLE dim_tempo (
    sk_tempo INT PRIMARY KEY, -- Formato YYYYMMDD (Ex: 20260506)
    data_completa DATE NOT NULL,
    dia INT,
    mes INT,
    nome_mes VARCHAR(15),
    trimestre INT,
    ano INT,
    dia_semana VARCHAR(15),
    semestre INT,
    flag_feriado TINYINT(1) DEFAULT 0, -- 1 para Sim, 0 para Não
    nome_feriado VARCHAR(50)
);
-- TABELAS DE DIMENSÃO --------FIM--------

-- TABELAS FATO --------INICIO--------

-- 1. Fato Acadêmico-> Granularidade: Um registro por aluno, por turma e por trimestre.
CREATE TABLE fato_academico (
    sk_aluno INT NOT NULL,
    sk_turma INT NOT NULL,
    sk_unidade INT NOT NULL,
    sk_tempo INT NOT NULL,
    sk_status INT NOT NULL,
    num_trimestre INT NOT NULL, -- <--- NOVA COLUNA
    
    nota DECIMAL(4,2),
    total_faltas INT DEFAULT 0,
    qtd_matricula DECIMAL(4,2) DEFAULT 1.00, -- Mudei para DECIMAL para aceitar o 0.25
    
    FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (sk_turma) REFERENCES dim_turma(sk_turma),
    FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade),
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo),
    FOREIGN KEY (sk_status) REFERENCES dim_status(sk_status),
    
    -- A PRIMARY KEY agora inclui o trimestre para evitar o erro 1062
    PRIMARY KEY (
        sk_aluno,
        sk_turma,
        sk_tempo,
        num_trimestre
    )
);

-- 2. Fato Financeiro-> Granularidade: Uma linha por transação financeira (seja entrada de mensalidade
-- ou saída para compra de material/serviço) por unidade e por data.
CREATE TABLE fato_financeiro (
    sk_tempo INT NOT NULL,
    sk_unidade INT NOT NULL,
    sk_forma_pagamento INT NOT NULL,
    sk_natureza INT NOT NULL, -- 1=Mensalidade, 2=Encargo, 3=Compra
    sk_aluno INT NOT NULL,    -- SK explícito para Aluno
    sk_fornecedor INT NOT NULL, -- SK explícito para Fornecedor
    
    valor_total DECIMAL(10,2) NOT NULL,
    quantidade INT DEFAULT 1,
    num_documento VARCHAR(50) NOT NULL, -- NSU ou Número da Nota
    
    PRIMARY KEY (
        sk_tempo, 
        sk_unidade, 
        sk_forma_pagamento, 
        sk_natureza, 
        sk_aluno, 
        sk_fornecedor, 
        num_documento
    ),
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo),
    FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade),
    FOREIGN KEY (sk_forma_pagamento) REFERENCES dim_forma_pagamento(sk_forma_pagamento),
    FOREIGN KEY (sk_natureza) REFERENCES dim_natureza_financeira(sk_natureza),
    FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (sk_fornecedor) REFERENCES dim_fornecedor(sk_fornecedor)
);

-- 3. Fato RH-> Granularidade: Um registro por funcionário, por unidade e por mês de referência.
-- socorro
CREATE TABLE fato_rh (
    sk_funcionario INT NOT NULL,
    sk_unidade INT NOT NULL,
    sk_tempo INT NOT NULL,
    
    -- Métricas Financeiras de RH
    salario_base DECIMAL(10,2),  -- Métrica semi-aditiva
    total_proventos DECIMAL(10,2), -- Métrica aditiva
    total_descontos DECIMAL(10,2), -- Métrica aditiva
    salario_liquido DECIMAL(10,2), -- Métrica semi-aditiva
    
    -- Métrica de Contagem Técnica
    count_funcionario INT DEFAULT 1,
    
    -- Métricas de Frequência e Horas
    horas_trabalhadas DECIMAL(6,2),  -- Métrica aditiva
    horas_extra DECIMAL(6,2), -- Métrica aditiva
    qtd_faltas_ponto INT DEFAULT 0, -- Métrica aditiva
    
    -- Flags de Status no Período
    flag_ferias TINYINT(1) DEFAULT 0, -- Métrica não-aditiva
    flag_afastamento TINYINT(1) DEFAULT 0, -- Métrica não-aditiva
    
    -- Métricas de Desenvolvimento
    qtd_treinamentos INT DEFAULT 0, -- Métrica aditiva
    horas_treinamento DECIMAL(6,2) DEFAULT 0.00, -- Métrica aditiva

    FOREIGN KEY (sk_funcionario) REFERENCES dim_funcionario(sk_funcionario),
    FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade),
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo),
    
    PRIMARY KEY (
    sk_funcionario,
    sk_unidade,
    sk_tempo
)
);

-- TABELAS FATO --------FIM--------

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

-- -----------------------------------------

-- INSERTS DO ETL (DIMENSOES) --------INICIO--------

-- ============================================================
-- 1. ALUNO
-- ============================================================
select count(*) from dim_aluno;

-- Inserção do dummy de aluno
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
INSERT INTO dim_aluno (sk_aluno, ra, cpf, nome_completo, genero, etnia, deficiencia, data_nascimento)
VALUES (0, '0', '00000000000', 'NÃO CADASTRADO / N/A', 'N/A', 'N/A', 'N/A', '1900-01-01');
SET SESSION sql_mode='';

-- Carga dos alunos reais
INSERT INTO dim_aluno (ra, cpf, nome_completo, genero, etnia, deficiencia, data_nascimento)
SELECT 
    a.pk_ra, 
    p.pk_cpf, 
    CONCAT(p.primeiro_nome, ' ', p.sobrenome),
    p.genero, 
    p.etnia, 
    p.deficiencia, 
    p.data_nasc
FROM tb_pessoa p
JOIN tb_aluno a ON p.pk_cpf = a.fk_cpf
ON DUPLICATE KEY UPDATE
    nome_completo = VALUES(nome_completo),
    genero = VALUES(genero),
    etnia = VALUES(etnia),
    deficiencia = VALUES(deficiencia),
    ra = VALUES(ra);

-- ============================================================
-- 2. FUNCIONARIO
-- ============================================================
select count(*) from dim_funcionario;

-- Insercao do dummy funcionario (Caso nao tenha rodado antes)
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
INSERT INTO dim_funcionario (sk_funcionario, n_contratacao, cpf, nome_completo, genero, etnia, deficiencia, data_nascimento, status_funcionario, cargo, departamento, formacao)
VALUES (0, 0, '00000000000', 'NÃO CADASTRADO / N/A', 'N/A', 'N/A', 'N/A', '1900-01-01', 'N/A', 'N/A', 'N/A', 'N/A')
ON DUPLICATE KEY UPDATE sk_funcionario = 0;
SET SESSION sql_mode='';

-- Carga dos Funcionários Reais
INSERT INTO dim_funcionario (n_contratacao, cpf, nome_completo, genero, etnia, deficiencia, data_nascimento, status_funcionario, cargo, departamento, formacao)
SELECT 
    f.pk_n_contratacao,
    p.pk_cpf,
    CONCAT(p.primeiro_nome, ' ', p.sobrenome),
    p.genero,
    p.etnia,
    p.deficiencia,
    p.data_nasc,
    f.status_funcionario,
    c.nome_cargo,
    d.departamento,
    IFNULL(
        (SELECT GROUP_CONCAT(tf.nome_formacao SEPARATOR ', ') 
         FROM tb_funcionario_formacao tff 
         JOIN tb_formacao tf ON tff.pk_fk_id_formacao = tf.pk_id_formacao 
         WHERE tff.pk_fk_n_contratacao = f.pk_n_contratacao), 
    'N/A') AS formacao 
FROM tb_pessoa p
JOIN tb_funcionario f ON p.pk_cpf = f.fk_cpf
JOIN tb_func_cargo fc ON f.pk_n_contratacao = fc.pk_fk_n_contratacao
JOIN tb_cargo c ON fc.pk_fk_id_cargo = c.pk_id_cargo
JOIN tb_departamento d ON fc.pk_fk_id_departamento = d.pk_id_departamento
WHERE fc.data_fim IS NULL
ON DUPLICATE KEY UPDATE
    nome_completo = VALUES(nome_completo),
    status_funcionario = VALUES(status_funcionario),
    cargo = VALUES(cargo),
    departamento = VALUES(departamento),
    formacao = VALUES(formacao);

-- ============================================================
-- 3. UNIDADE
-- ============================================================
select count(*) from dim_unidade;

-- Inserção do dummy unidade (Unidade Zero)
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
INSERT INTO dim_unidade (sk_unidade, nome_unidade, logradouro, num_logradouro, complemento)
VALUES (0, 'UNIDADE NÃO ESPECIFICADA', 'N/A', '0', 'N/A')
ON DUPLICATE KEY UPDATE sk_unidade = 0;
SET SESSION sql_mode='';

-- Carga das unidades reais
INSERT INTO dim_unidade (
    id_unidade,
    nome_unidade,
    logradouro,
    num_logradouro,
    complemento
)
SELECT
    pk_id_unidade,
    nome_unidade,
    logradouro,
    num_logradouro,
    complemento
FROM tb_unidade
ON DUPLICATE KEY UPDATE
    nome_unidade = VALUES(nome_unidade),
    logradouro = VALUES(logradouro),
    num_logradouro = VALUES(num_logradouro),
    complemento = VALUES(complemento);

-- ============================================================
-- 4. TURMA
-- ============================================================
select count(*) from dim_turma;

-- Inserção do dummy turma (Turma Zero)
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
INSERT INTO dim_turma (sk_turma, id_turma, cod_turma_operacional, nome_disciplina, nome_curso, turno, nome_professor_titular, data_inicio_turma, duracao_meses_curso)
VALUES (0, 0, 'N/A', 'NÃO CADASTRADA', 'NÃO CADASTRADO', 'N/A', 'N/A', '1900-01-01', 0)
ON DUPLICATE KEY UPDATE sk_turma = 0;
SET SESSION sql_mode='';

-- Carga das turmas reais
INSERT INTO dim_turma (
    id_turma,
    cod_turma_operacional, 
    nome_disciplina, 
    nome_curso, 
    turno, 
    nome_professor_titular, 
    data_inicio_turma, 
    duracao_meses_curso
)
SELECT 
    t.pk_id_turma,
    -- Criamos um código legível para o usuário final
    CONCAT(c.nome_curso, ' - ', d.disciplina, ' (', t.turno, ')') AS cod_legivel,
    d.disciplina, 
    c.nome_curso, 
    t.turno,
    CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS professor,
    t.data_inicio,
    c.duracao_meses
FROM tb_turma t
JOIN tb_disciplina d ON t.fk_id_curso = d.pk_fk_id_curso AND t.fk_id_disciplina = d.pk_id_disciplina
JOIN tb_curso c ON d.pk_fk_id_curso = c.pk_id_curso
LEFT JOIN tb_funcionario f ON t.fk_n_contratacao = f.pk_n_contratacao
LEFT JOIN tb_pessoa p ON f.fk_cpf = p.pk_cpf
ON DUPLICATE KEY UPDATE
    cod_turma_operacional = VALUES(cod_turma_operacional),
    nome_disciplina = VALUES(nome_disciplina),
    nome_curso = VALUES(nome_curso),
    turno = VALUES(turno),
    nome_professor_titular = VALUES(nome_professor_titular),
    data_inicio_turma = VALUES(data_inicio_turma),
    duracao_meses_curso = VALUES(duracao_meses_curso);

-- ============================================================
-- 5. FORMA DE PAGAMENTO
-- ============================================================
select count(*) from dim_forma_pagamento;

-- Inserção do dummy forma de pagamento (Forma de Pagamento Zero)
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
INSERT INTO dim_forma_pagamento (sk_forma_pagamento, forma_pagamento)
VALUES (0, 'NÃO INFORMADO')
ON DUPLICATE KEY UPDATE sk_forma_pagamento = 0;
SET SESSION sql_mode='';

-- Carga das formas de pagamento reais
INSERT INTO dim_forma_pagamento (forma_pagamento)
SELECT forma_pagamento
FROM tb_pagamento
ON DUPLICATE KEY UPDATE forma_pagamento = VALUES(forma_pagamento);

-- ============================================================
-- 6. FORNECEDOR
-- ============================================================
select count(*) from dim_fornecedor;

-- Inserção do dummy fornecedor (Fornecedor Zero)
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
INSERT INTO dim_fornecedor (sk_fornecedor, cnpj, razao_social, nome_fantasia)
VALUES (0, '00000000000000', 'NÃO APLICÁVEL / INTERNO', 'N/A')
ON DUPLICATE KEY UPDATE sk_fornecedor = 0;
SET SESSION sql_mode='';

-- Carga dos fornecedores reais
INSERT INTO dim_fornecedor (cnpj, razao_social, nome_fantasia)
SELECT 
    pk_cnpj, 
    razao_social, 
    nome_fantasia
FROM tb_fornecedor
ON DUPLICATE KEY UPDATE
    razao_social = VALUES(razao_social),
    nome_fantasia = VALUES(nome_fantasia);

-- ============================================================
-- 7. STATUS
-- ============================================================
select count(*) from dim_status;

INSERT INTO dim_status (sk_status, status_nome) VALUES 
(1, 'Aprovado'),
(2, 'Reprovado'),
(3, 'Cursando'),
(4, 'Trancado'),
(5, 'Evadido'),
(6, 'N/A')
ON DUPLICATE KEY UPDATE 
status_nome = VALUES(status_nome);

-- ============================================================
-- 8. NATUREZA FINANCEIRA
-- ============================================================
select count(*) from dim_natureza_financeira;

INSERT INTO dim_natureza_financeira (codigo_operacional, nome_natureza, tipo_movimentacao) VALUES
(1, 'Mensalidade', 'ENTRADA'),
(2, 'Encargos (Multas/Juros)', 'ENTRADA'),
(3, 'Compra de Material/Produto', 'SAÍDA')
on duplicate key update
codigo_operacional=values(codigo_operacional),
tipo_movimentacao=values(tipo_movimentacao);

-- ============================================================
-- 9. TEMPO
-- ============================================================
select count(*) from dim_tempo;

INSERT INTO dim_tempo (
    sk_tempo,
    data_completa,
    dia,
    mes,
    nome_mes,
    trimestre,
    ano,
    dia_semana,
    semestre,
    flag_feriado,
    nome_feriado
)
VALUES
(20250101, '2025-01-01', 1, 1, 'Janeiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250102, '2025-01-02', 2, 1, 'Janeiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250103, '2025-01-03', 3, 1, 'Janeiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250104, '2025-01-04', 4, 1, 'Janeiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250105, '2025-01-05', 5, 1, 'Janeiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250106, '2025-01-06', 6, 1, 'Janeiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250107, '2025-01-07', 7, 1, 'Janeiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250108, '2025-01-08', 8, 1, 'Janeiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250109, '2025-01-09', 9, 1, 'Janeiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250110, '2025-01-10', 10, 1, 'Janeiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250111, '2025-01-11', 11, 1, 'Janeiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250112, '2025-01-12', 12, 1, 'Janeiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250113, '2025-01-13', 13, 1, 'Janeiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250114, '2025-01-14', 14, 1, 'Janeiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250115, '2025-01-15', 15, 1, 'Janeiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250116, '2025-01-16', 16, 1, 'Janeiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250117, '2025-01-17', 17, 1, 'Janeiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250118, '2025-01-18', 18, 1, 'Janeiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250119, '2025-01-19', 19, 1, 'Janeiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250120, '2025-01-20', 20, 1, 'Janeiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250121, '2025-01-21', 21, 1, 'Janeiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250122, '2025-01-22', 22, 1, 'Janeiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250123, '2025-01-23', 23, 1, 'Janeiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250124, '2025-01-24', 24, 1, 'Janeiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250125, '2025-01-25', 25, 1, 'Janeiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250126, '2025-01-26', 26, 1, 'Janeiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250127, '2025-01-27', 27, 1, 'Janeiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250128, '2025-01-28', 28, 1, 'Janeiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250129, '2025-01-29', 29, 1, 'Janeiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250130, '2025-01-30', 30, 1, 'Janeiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250131, '2025-01-31', 31, 1, 'Janeiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250201, '2025-02-01', 1, 2, 'Fevereiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250202, '2025-02-02', 2, 2, 'Fevereiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250203, '2025-02-03', 3, 2, 'Fevereiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250204, '2025-02-04', 4, 2, 'Fevereiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250205, '2025-02-05', 5, 2, 'Fevereiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250206, '2025-02-06', 6, 2, 'Fevereiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250207, '2025-02-07', 7, 2, 'Fevereiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250208, '2025-02-08', 8, 2, 'Fevereiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250209, '2025-02-09', 9, 2, 'Fevereiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250210, '2025-02-10', 10, 2, 'Fevereiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250211, '2025-02-11', 11, 2, 'Fevereiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250212, '2025-02-12', 12, 2, 'Fevereiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250213, '2025-02-13', 13, 2, 'Fevereiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250214, '2025-02-14', 14, 2, 'Fevereiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250215, '2025-02-15', 15, 2, 'Fevereiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250216, '2025-02-16', 16, 2, 'Fevereiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250217, '2025-02-17', 17, 2, 'Fevereiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250218, '2025-02-18', 18, 2, 'Fevereiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250219, '2025-02-19', 19, 2, 'Fevereiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250220, '2025-02-20', 20, 2, 'Fevereiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250221, '2025-02-21', 21, 2, 'Fevereiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250222, '2025-02-22', 22, 2, 'Fevereiro', 1, 2025, 'Sábado', 1, 0, NULL),
(20250223, '2025-02-23', 23, 2, 'Fevereiro', 1, 2025, 'Domingo', 1, 0, NULL),
(20250224, '2025-02-24', 24, 2, 'Fevereiro', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250225, '2025-02-25', 25, 2, 'Fevereiro', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250226, '2025-02-26', 26, 2, 'Fevereiro', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250227, '2025-02-27', 27, 2, 'Fevereiro', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250228, '2025-02-28', 28, 2, 'Fevereiro', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250301, '2025-03-01', 1, 3, 'Março', 1, 2025, 'Sábado', 1, 0, NULL),
(20250302, '2025-03-02', 2, 3, 'Março', 1, 2025, 'Domingo', 1, 0, NULL),
(20250303, '2025-03-03', 3, 3, 'Março', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250304, '2025-03-04', 4, 3, 'Março', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250305, '2025-03-05', 5, 3, 'Março', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250306, '2025-03-06', 6, 3, 'Março', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250307, '2025-03-07', 7, 3, 'Março', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250308, '2025-03-08', 8, 3, 'Março', 1, 2025, 'Sábado', 1, 0, NULL),
(20250309, '2025-03-09', 9, 3, 'Março', 1, 2025, 'Domingo', 1, 0, NULL),
(20250310, '2025-03-10', 10, 3, 'Março', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250311, '2025-03-11', 11, 3, 'Março', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250312, '2025-03-12', 12, 3, 'Março', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250313, '2025-03-13', 13, 3, 'Março', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250314, '2025-03-14', 14, 3, 'Março', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250315, '2025-03-15', 15, 3, 'Março', 1, 2025, 'Sábado', 1, 0, NULL),
(20250316, '2025-03-16', 16, 3, 'Março', 1, 2025, 'Domingo', 1, 0, NULL),
(20250317, '2025-03-17', 17, 3, 'Março', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250318, '2025-03-18', 18, 3, 'Março', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250319, '2025-03-19', 19, 3, 'Março', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250320, '2025-03-20', 20, 3, 'Março', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250321, '2025-03-21', 21, 3, 'Março', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250322, '2025-03-22', 22, 3, 'Março', 1, 2025, 'Sábado', 1, 0, NULL),
(20250323, '2025-03-23', 23, 3, 'Março', 1, 2025, 'Domingo', 1, 0, NULL),
(20250324, '2025-03-24', 24, 3, 'Março', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250325, '2025-03-25', 25, 3, 'Março', 1, 2025, 'Terça-feira', 1, 0, NULL),
(20250326, '2025-03-26', 26, 3, 'Março', 1, 2025, 'Quarta-feira', 1, 0, NULL),
(20250327, '2025-03-27', 27, 3, 'Março', 1, 2025, 'Quinta-feira', 1, 0, NULL),
(20250328, '2025-03-28', 28, 3, 'Março', 1, 2025, 'Sexta-feira', 1, 0, NULL),
(20250329, '2025-03-29', 29, 3, 'Março', 1, 2025, 'Sábado', 1, 0, NULL),
(20250330, '2025-03-30', 30, 3, 'Março', 1, 2025, 'Domingo', 1, 0, NULL),
(20250331, '2025-03-31', 31, 3, 'Março', 1, 2025, 'Segunda-feira', 1, 0, NULL),
(20250401, '2025-04-01', 1, 4, 'Abril', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250402, '2025-04-02', 2, 4, 'Abril', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250403, '2025-04-03', 3, 4, 'Abril', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250404, '2025-04-04', 4, 4, 'Abril', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250405, '2025-04-05', 5, 4, 'Abril', 2, 2025, 'Sábado', 1, 0, NULL),
(20250406, '2025-04-06', 6, 4, 'Abril', 2, 2025, 'Domingo', 1, 0, NULL),
(20250407, '2025-04-07', 7, 4, 'Abril', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250408, '2025-04-08', 8, 4, 'Abril', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250409, '2025-04-09', 9, 4, 'Abril', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250410, '2025-04-10', 10, 4, 'Abril', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250411, '2025-04-11', 11, 4, 'Abril', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250412, '2025-04-12', 12, 4, 'Abril', 2, 2025, 'Sábado', 1, 0, NULL),
(20250413, '2025-04-13', 13, 4, 'Abril', 2, 2025, 'Domingo', 1, 0, NULL),
(20250414, '2025-04-14', 14, 4, 'Abril', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250415, '2025-04-15', 15, 4, 'Abril', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250416, '2025-04-16', 16, 4, 'Abril', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250417, '2025-04-17', 17, 4, 'Abril', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250418, '2025-04-18', 18, 4, 'Abril', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250419, '2025-04-19', 19, 4, 'Abril', 2, 2025, 'Sábado', 1, 0, NULL),
(20250420, '2025-04-20', 20, 4, 'Abril', 2, 2025, 'Domingo', 1, 0, NULL),
(20250421, '2025-04-21', 21, 4, 'Abril', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250422, '2025-04-22', 22, 4, 'Abril', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250423, '2025-04-23', 23, 4, 'Abril', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250424, '2025-04-24', 24, 4, 'Abril', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250425, '2025-04-25', 25, 4, 'Abril', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250426, '2025-04-26', 26, 4, 'Abril', 2, 2025, 'Sábado', 1, 0, NULL),
(20250427, '2025-04-27', 27, 4, 'Abril', 2, 2025, 'Domingo', 1, 0, NULL),
(20250428, '2025-04-28', 28, 4, 'Abril', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250429, '2025-04-29', 29, 4, 'Abril', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250430, '2025-04-30', 30, 4, 'Abril', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250501, '2025-05-01', 1, 5, 'Maio', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250502, '2025-05-02', 2, 5, 'Maio', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250503, '2025-05-03', 3, 5, 'Maio', 2, 2025, 'Sábado', 1, 0, NULL),
(20250504, '2025-05-04', 4, 5, 'Maio', 2, 2025, 'Domingo', 1, 0, NULL),
(20250505, '2025-05-05', 5, 5, 'Maio', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250506, '2025-05-06', 6, 5, 'Maio', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250507, '2025-05-07', 7, 5, 'Maio', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250508, '2025-05-08', 8, 5, 'Maio', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250509, '2025-05-09', 9, 5, 'Maio', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250510, '2025-05-10', 10, 5, 'Maio', 2, 2025, 'Sábado', 1, 0, NULL),
(20250511, '2025-05-11', 11, 5, 'Maio', 2, 2025, 'Domingo', 1, 0, NULL),
(20250512, '2025-05-12', 12, 5, 'Maio', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250513, '2025-05-13', 13, 5, 'Maio', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250514, '2025-05-14', 14, 5, 'Maio', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250515, '2025-05-15', 15, 5, 'Maio', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250516, '2025-05-16', 16, 5, 'Maio', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250517, '2025-05-17', 17, 5, 'Maio', 2, 2025, 'Sábado', 1, 0, NULL),
(20250518, '2025-05-18', 18, 5, 'Maio', 2, 2025, 'Domingo', 1, 0, NULL),
(20250519, '2025-05-19', 19, 5, 'Maio', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250520, '2025-05-20', 20, 5, 'Maio', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250521, '2025-05-21', 21, 5, 'Maio', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250522, '2025-05-22', 22, 5, 'Maio', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250523, '2025-05-23', 23, 5, 'Maio', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250524, '2025-05-24', 24, 5, 'Maio', 2, 2025, 'Sábado', 1, 0, NULL),
(20250525, '2025-05-25', 25, 5, 'Maio', 2, 2025, 'Domingo', 1, 0, NULL),
(20250526, '2025-05-26', 26, 5, 'Maio', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250527, '2025-05-27', 27, 5, 'Maio', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250528, '2025-05-28', 28, 5, 'Maio', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250529, '2025-05-29', 29, 5, 'Maio', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250530, '2025-05-30', 30, 5, 'Maio', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250531, '2025-05-31', 31, 5, 'Maio', 2, 2025, 'Sábado', 1, 0, NULL),
(20250601, '2025-06-01', 1, 6, 'Junho', 2, 2025, 'Domingo', 1, 0, NULL),
(20250602, '2025-06-02', 2, 6, 'Junho', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250603, '2025-06-03', 3, 6, 'Junho', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250604, '2025-06-04', 4, 6, 'Junho', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250605, '2025-06-05', 5, 6, 'Junho', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250606, '2025-06-06', 6, 6, 'Junho', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250607, '2025-06-07', 7, 6, 'Junho', 2, 2025, 'Sábado', 1, 0, NULL),
(20250608, '2025-06-08', 8, 6, 'Junho', 2, 2025, 'Domingo', 1, 0, NULL),
(20250609, '2025-06-09', 9, 6, 'Junho', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250610, '2025-06-10', 10, 6, 'Junho', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250611, '2025-06-11', 11, 6, 'Junho', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250612, '2025-06-12', 12, 6, 'Junho', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250613, '2025-06-13', 13, 6, 'Junho', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250614, '2025-06-14', 14, 6, 'Junho', 2, 2025, 'Sábado', 1, 0, NULL),
(20250615, '2025-06-15', 15, 6, 'Junho', 2, 2025, 'Domingo', 1, 0, NULL),
(20250616, '2025-06-16', 16, 6, 'Junho', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250617, '2025-06-17', 17, 6, 'Junho', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250618, '2025-06-18', 18, 6, 'Junho', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250619, '2025-06-19', 19, 6, 'Junho', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250620, '2025-06-20', 20, 6, 'Junho', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250621, '2025-06-21', 21, 6, 'Junho', 2, 2025, 'Sábado', 1, 0, NULL),
(20250622, '2025-06-22', 22, 6, 'Junho', 2, 2025, 'Domingo', 1, 0, NULL),
(20250623, '2025-06-23', 23, 6, 'Junho', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250624, '2025-06-24', 24, 6, 'Junho', 2, 2025, 'Terça-feira', 1, 0, NULL),
(20250625, '2025-06-25', 25, 6, 'Junho', 2, 2025, 'Quarta-feira', 1, 0, NULL),
(20250626, '2025-06-26', 26, 6, 'Junho', 2, 2025, 'Quinta-feira', 1, 0, NULL),
(20250627, '2025-06-27', 27, 6, 'Junho', 2, 2025, 'Sexta-feira', 1, 0, NULL),
(20250628, '2025-06-28', 28, 6, 'Junho', 2, 2025, 'Sábado', 1, 0, NULL),
(20250629, '2025-06-29', 29, 6, 'Junho', 2, 2025, 'Domingo', 1, 0, NULL),
(20250630, '2025-06-30', 30, 6, 'Junho', 2, 2025, 'Segunda-feira', 1, 0, NULL),
(20250701, '2025-07-01', 1, 7, 'Julho', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250702, '2025-07-02', 2, 7, 'Julho', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250703, '2025-07-03', 3, 7, 'Julho', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250704, '2025-07-04', 4, 7, 'Julho', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250705, '2025-07-05', 5, 7, 'Julho', 3, 2025, 'Sábado', 2, 0, NULL),
(20250706, '2025-07-06', 6, 7, 'Julho', 3, 2025, 'Domingo', 2, 0, NULL),
(20250707, '2025-07-07', 7, 7, 'Julho', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250708, '2025-07-08', 8, 7, 'Julho', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250709, '2025-07-09', 9, 7, 'Julho', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250710, '2025-07-10', 10, 7, 'Julho', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250711, '2025-07-11', 11, 7, 'Julho', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250712, '2025-07-12', 12, 7, 'Julho', 3, 2025, 'Sábado', 2, 0, NULL),
(20250713, '2025-07-13', 13, 7, 'Julho', 3, 2025, 'Domingo', 2, 0, NULL),
(20250714, '2025-07-14', 14, 7, 'Julho', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250715, '2025-07-15', 15, 7, 'Julho', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250716, '2025-07-16', 16, 7, 'Julho', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250717, '2025-07-17', 17, 7, 'Julho', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250718, '2025-07-18', 18, 7, 'Julho', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250719, '2025-07-19', 19, 7, 'Julho', 3, 2025, 'Sábado', 2, 0, NULL),
(20250720, '2025-07-20', 20, 7, 'Julho', 3, 2025, 'Domingo', 2, 0, NULL),
(20250721, '2025-07-21', 21, 7, 'Julho', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250722, '2025-07-22', 22, 7, 'Julho', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250723, '2025-07-23', 23, 7, 'Julho', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250724, '2025-07-24', 24, 7, 'Julho', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250725, '2025-07-25', 25, 7, 'Julho', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250726, '2025-07-26', 26, 7, 'Julho', 3, 2025, 'Sábado', 2, 0, NULL),
(20250727, '2025-07-27', 27, 7, 'Julho', 3, 2025, 'Domingo', 2, 0, NULL),
(20250728, '2025-07-28', 28, 7, 'Julho', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250729, '2025-07-29', 29, 7, 'Julho', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250730, '2025-07-30', 30, 7, 'Julho', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250731, '2025-07-31', 31, 7, 'Julho', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250801, '2025-08-01', 1, 8, 'Agosto', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250802, '2025-08-02', 2, 8, 'Agosto', 3, 2025, 'Sábado', 2, 0, NULL),
(20250803, '2025-08-03', 3, 8, 'Agosto', 3, 2025, 'Domingo', 2, 0, NULL),
(20250804, '2025-08-04', 4, 8, 'Agosto', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250805, '2025-08-05', 5, 8, 'Agosto', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250806, '2025-08-06', 6, 8, 'Agosto', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250807, '2025-08-07', 7, 8, 'Agosto', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250808, '2025-08-08', 8, 8, 'Agosto', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250809, '2025-08-09', 9, 8, 'Agosto', 3, 2025, 'Sábado', 2, 0, NULL),
(20250810, '2025-08-10', 10, 8, 'Agosto', 3, 2025, 'Domingo', 2, 0, NULL),
(20250811, '2025-08-11', 11, 8, 'Agosto', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250812, '2025-08-12', 12, 8, 'Agosto', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250813, '2025-08-13', 13, 8, 'Agosto', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250814, '2025-08-14', 14, 8, 'Agosto', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250815, '2025-08-15', 15, 8, 'Agosto', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250816, '2025-08-16', 16, 8, 'Agosto', 3, 2025, 'Sábado', 2, 0, NULL),
(20250817, '2025-08-17', 17, 8, 'Agosto', 3, 2025, 'Domingo', 2, 0, NULL),
(20250818, '2025-08-18', 18, 8, 'Agosto', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250819, '2025-08-19', 19, 8, 'Agosto', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250820, '2025-08-20', 20, 8, 'Agosto', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250821, '2025-08-21', 21, 8, 'Agosto', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250822, '2025-08-22', 22, 8, 'Agosto', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250823, '2025-08-23', 23, 8, 'Agosto', 3, 2025, 'Sábado', 2, 0, NULL),
(20250824, '2025-08-24', 24, 8, 'Agosto', 3, 2025, 'Domingo', 2, 0, NULL),
(20250825, '2025-08-25', 25, 8, 'Agosto', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250826, '2025-08-26', 26, 8, 'Agosto', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250827, '2025-08-27', 27, 8, 'Agosto', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250828, '2025-08-28', 28, 8, 'Agosto', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250829, '2025-08-29', 29, 8, 'Agosto', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250830, '2025-08-30', 30, 8, 'Agosto', 3, 2025, 'Sábado', 2, 0, NULL),
(20250831, '2025-08-31', 31, 8, 'Agosto', 3, 2025, 'Domingo', 2, 0, NULL),
(20250901, '2025-09-01', 1, 9, 'Setembro', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250902, '2025-09-02', 2, 9, 'Setembro', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250903, '2025-09-03', 3, 9, 'Setembro', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250904, '2025-09-04', 4, 9, 'Setembro', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250905, '2025-09-05', 5, 9, 'Setembro', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250906, '2025-09-06', 6, 9, 'Setembro', 3, 2025, 'Sábado', 2, 0, NULL),
(20250907, '2025-09-07', 7, 9, 'Setembro', 3, 2025, 'Domingo', 2, 0, NULL),
(20250908, '2025-09-08', 8, 9, 'Setembro', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250909, '2025-09-09', 9, 9, 'Setembro', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250910, '2025-09-10', 10, 9, 'Setembro', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250911, '2025-09-11', 11, 9, 'Setembro', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250912, '2025-09-12', 12, 9, 'Setembro', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250913, '2025-09-13', 13, 9, 'Setembro', 3, 2025, 'Sábado', 2, 0, NULL),
(20250914, '2025-09-14', 14, 9, 'Setembro', 3, 2025, 'Domingo', 2, 0, NULL),
(20250915, '2025-09-15', 15, 9, 'Setembro', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250916, '2025-09-16', 16, 9, 'Setembro', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250917, '2025-09-17', 17, 9, 'Setembro', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250918, '2025-09-18', 18, 9, 'Setembro', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250919, '2025-09-19', 19, 9, 'Setembro', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250920, '2025-09-20', 20, 9, 'Setembro', 3, 2025, 'Sábado', 2, 0, NULL),
(20250921, '2025-09-21', 21, 9, 'Setembro', 3, 2025, 'Domingo', 2, 0, NULL),
(20250922, '2025-09-22', 22, 9, 'Setembro', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250923, '2025-09-23', 23, 9, 'Setembro', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20250924, '2025-09-24', 24, 9, 'Setembro', 3, 2025, 'Quarta-feira', 2, 0, NULL),
(20250925, '2025-09-25', 25, 9, 'Setembro', 3, 2025, 'Quinta-feira', 2, 0, NULL),
(20250926, '2025-09-26', 26, 9, 'Setembro', 3, 2025, 'Sexta-feira', 2, 0, NULL),
(20250927, '2025-09-27', 27, 9, 'Setembro', 3, 2025, 'Sábado', 2, 0, NULL),
(20250928, '2025-09-28', 28, 9, 'Setembro', 3, 2025, 'Domingo', 2, 0, NULL),
(20250929, '2025-09-29', 29, 9, 'Setembro', 3, 2025, 'Segunda-feira', 2, 0, NULL),
(20250930, '2025-09-30', 30, 9, 'Setembro', 3, 2025, 'Terça-feira', 2, 0, NULL),
(20251001, '2025-10-01', 1, 10, 'Outubro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251002, '2025-10-02', 2, 10, 'Outubro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251003, '2025-10-03', 3, 10, 'Outubro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251004, '2025-10-04', 4, 10, 'Outubro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251005, '2025-10-05', 5, 10, 'Outubro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251006, '2025-10-06', 6, 10, 'Outubro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251007, '2025-10-07', 7, 10, 'Outubro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251008, '2025-10-08', 8, 10, 'Outubro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251009, '2025-10-09', 9, 10, 'Outubro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251010, '2025-10-10', 10, 10, 'Outubro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251011, '2025-10-11', 11, 10, 'Outubro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251012, '2025-10-12', 12, 10, 'Outubro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251013, '2025-10-13', 13, 10, 'Outubro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251014, '2025-10-14', 14, 10, 'Outubro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251015, '2025-10-15', 15, 10, 'Outubro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251016, '2025-10-16', 16, 10, 'Outubro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251017, '2025-10-17', 17, 10, 'Outubro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251018, '2025-10-18', 18, 10, 'Outubro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251019, '2025-10-19', 19, 10, 'Outubro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251020, '2025-10-20', 20, 10, 'Outubro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251021, '2025-10-21', 21, 10, 'Outubro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251022, '2025-10-22', 22, 10, 'Outubro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251023, '2025-10-23', 23, 10, 'Outubro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251024, '2025-10-24', 24, 10, 'Outubro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251025, '2025-10-25', 25, 10, 'Outubro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251026, '2025-10-26', 26, 10, 'Outubro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251027, '2025-10-27', 27, 10, 'Outubro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251028, '2025-10-28', 28, 10, 'Outubro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251029, '2025-10-29', 29, 10, 'Outubro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251030, '2025-10-30', 30, 10, 'Outubro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251031, '2025-10-31', 31, 10, 'Outubro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251101, '2025-11-01', 1, 11, 'Novembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251102, '2025-11-02', 2, 11, 'Novembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251103, '2025-11-03', 3, 11, 'Novembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251104, '2025-11-04', 4, 11, 'Novembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251105, '2025-11-05', 5, 11, 'Novembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251106, '2025-11-06', 6, 11, 'Novembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251107, '2025-11-07', 7, 11, 'Novembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251108, '2025-11-08', 8, 11, 'Novembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251109, '2025-11-09', 9, 11, 'Novembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251110, '2025-11-10', 10, 11, 'Novembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251111, '2025-11-11', 11, 11, 'Novembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251112, '2025-11-12', 12, 11, 'Novembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251113, '2025-11-13', 13, 11, 'Novembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251114, '2025-11-14', 14, 11, 'Novembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251115, '2025-11-15', 15, 11, 'Novembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251116, '2025-11-16', 16, 11, 'Novembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251117, '2025-11-17', 17, 11, 'Novembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251118, '2025-11-18', 18, 11, 'Novembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251119, '2025-11-19', 19, 11, 'Novembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251120, '2025-11-20', 20, 11, 'Novembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251121, '2025-11-21', 21, 11, 'Novembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251122, '2025-11-22', 22, 11, 'Novembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251123, '2025-11-23', 23, 11, 'Novembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251124, '2025-11-24', 24, 11, 'Novembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251125, '2025-11-25', 25, 11, 'Novembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251126, '2025-11-26', 26, 11, 'Novembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251127, '2025-11-27', 27, 11, 'Novembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251128, '2025-11-28', 28, 11, 'Novembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251129, '2025-11-29', 29, 11, 'Novembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251130, '2025-11-30', 30, 11, 'Novembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251201, '2025-12-01', 1, 12, 'Dezembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251202, '2025-12-02', 2, 12, 'Dezembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251203, '2025-12-03', 3, 12, 'Dezembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251204, '2025-12-04', 4, 12, 'Dezembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251205, '2025-12-05', 5, 12, 'Dezembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251206, '2025-12-06', 6, 12, 'Dezembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251207, '2025-12-07', 7, 12, 'Dezembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251208, '2025-12-08', 8, 12, 'Dezembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251209, '2025-12-09', 9, 12, 'Dezembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251210, '2025-12-10', 10, 12, 'Dezembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251211, '2025-12-11', 11, 12, 'Dezembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251212, '2025-12-12', 12, 12, 'Dezembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251213, '2025-12-13', 13, 12, 'Dezembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251214, '2025-12-14', 14, 12, 'Dezembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251215, '2025-12-15', 15, 12, 'Dezembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251216, '2025-12-16', 16, 12, 'Dezembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251217, '2025-12-17', 17, 12, 'Dezembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251218, '2025-12-18', 18, 12, 'Dezembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251219, '2025-12-19', 19, 12, 'Dezembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251220, '2025-12-20', 20, 12, 'Dezembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251221, '2025-12-21', 21, 12, 'Dezembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251222, '2025-12-22', 22, 12, 'Dezembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251223, '2025-12-23', 23, 12, 'Dezembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251224, '2025-12-24', 24, 12, 'Dezembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20251225, '2025-12-25', 25, 12, 'Dezembro', 4, 2025, 'Quinta-feira', 2, 0, NULL),
(20251226, '2025-12-26', 26, 12, 'Dezembro', 4, 2025, 'Sexta-feira', 2, 0, NULL),
(20251227, '2025-12-27', 27, 12, 'Dezembro', 4, 2025, 'Sábado', 2, 0, NULL),
(20251228, '2025-12-28', 28, 12, 'Dezembro', 4, 2025, 'Domingo', 2, 0, NULL),
(20251229, '2025-12-29', 29, 12, 'Dezembro', 4, 2025, 'Segunda-feira', 2, 0, NULL),
(20251230, '2025-12-30', 30, 12, 'Dezembro', 4, 2025, 'Terça-feira', 2, 0, NULL),
(20251231, '2025-12-31', 31, 12, 'Dezembro', 4, 2025, 'Quarta-feira', 2, 0, NULL),
(20260101, '2026-01-01', 1, 1, 'Janeiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260102, '2026-01-02', 2, 1, 'Janeiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260103, '2026-01-03', 3, 1, 'Janeiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260104, '2026-01-04', 4, 1, 'Janeiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260105, '2026-01-05', 5, 1, 'Janeiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260106, '2026-01-06', 6, 1, 'Janeiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260107, '2026-01-07', 7, 1, 'Janeiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260108, '2026-01-08', 8, 1, 'Janeiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260109, '2026-01-09', 9, 1, 'Janeiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260110, '2026-01-10', 10, 1, 'Janeiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260111, '2026-01-11', 11, 1, 'Janeiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260112, '2026-01-12', 12, 1, 'Janeiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260113, '2026-01-13', 13, 1, 'Janeiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260114, '2026-01-14', 14, 1, 'Janeiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260115, '2026-01-15', 15, 1, 'Janeiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260116, '2026-01-16', 16, 1, 'Janeiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260117, '2026-01-17', 17, 1, 'Janeiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260118, '2026-01-18', 18, 1, 'Janeiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260119, '2026-01-19', 19, 1, 'Janeiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260120, '2026-01-20', 20, 1, 'Janeiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260121, '2026-01-21', 21, 1, 'Janeiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260122, '2026-01-22', 22, 1, 'Janeiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260123, '2026-01-23', 23, 1, 'Janeiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260124, '2026-01-24', 24, 1, 'Janeiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260125, '2026-01-25', 25, 1, 'Janeiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260126, '2026-01-26', 26, 1, 'Janeiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260127, '2026-01-27', 27, 1, 'Janeiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260128, '2026-01-28', 28, 1, 'Janeiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260129, '2026-01-29', 29, 1, 'Janeiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260130, '2026-01-30', 30, 1, 'Janeiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260131, '2026-01-31', 31, 1, 'Janeiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260201, '2026-02-01', 1, 2, 'Fevereiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260202, '2026-02-02', 2, 2, 'Fevereiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260203, '2026-02-03', 3, 2, 'Fevereiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260204, '2026-02-04', 4, 2, 'Fevereiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260205, '2026-02-05', 5, 2, 'Fevereiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260206, '2026-02-06', 6, 2, 'Fevereiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260207, '2026-02-07', 7, 2, 'Fevereiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260208, '2026-02-08', 8, 2, 'Fevereiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260209, '2026-02-09', 9, 2, 'Fevereiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260210, '2026-02-10', 10, 2, 'Fevereiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260211, '2026-02-11', 11, 2, 'Fevereiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260212, '2026-02-12', 12, 2, 'Fevereiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260213, '2026-02-13', 13, 2, 'Fevereiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260214, '2026-02-14', 14, 2, 'Fevereiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260215, '2026-02-15', 15, 2, 'Fevereiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260216, '2026-02-16', 16, 2, 'Fevereiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260217, '2026-02-17', 17, 2, 'Fevereiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260218, '2026-02-18', 18, 2, 'Fevereiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260219, '2026-02-19', 19, 2, 'Fevereiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260220, '2026-02-20', 20, 2, 'Fevereiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260221, '2026-02-21', 21, 2, 'Fevereiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260222, '2026-02-22', 22, 2, 'Fevereiro', 1, 2026, 'Domingo', 1, 0, NULL),
(20260223, '2026-02-23', 23, 2, 'Fevereiro', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260224, '2026-02-24', 24, 2, 'Fevereiro', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260225, '2026-02-25', 25, 2, 'Fevereiro', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260226, '2026-02-26', 26, 2, 'Fevereiro', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260227, '2026-02-27', 27, 2, 'Fevereiro', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260228, '2026-02-28', 28, 2, 'Fevereiro', 1, 2026, 'Sábado', 1, 0, NULL),
(20260301, '2026-03-01', 1, 3, 'Março', 1, 2026, 'Domingo', 1, 0, NULL),
(20260302, '2026-03-02', 2, 3, 'Março', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260303, '2026-03-03', 3, 3, 'Março', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260304, '2026-03-04', 4, 3, 'Março', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260305, '2026-03-05', 5, 3, 'Março', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260306, '2026-03-06', 6, 3, 'Março', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260307, '2026-03-07', 7, 3, 'Março', 1, 2026, 'Sábado', 1, 0, NULL),
(20260308, '2026-03-08', 8, 3, 'Março', 1, 2026, 'Domingo', 1, 0, NULL),
(20260309, '2026-03-09', 9, 3, 'Março', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260310, '2026-03-10', 10, 3, 'Março', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260311, '2026-03-11', 11, 3, 'Março', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260312, '2026-03-12', 12, 3, 'Março', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260313, '2026-03-13', 13, 3, 'Março', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260314, '2026-03-14', 14, 3, 'Março', 1, 2026, 'Sábado', 1, 0, NULL),
(20260315, '2026-03-15', 15, 3, 'Março', 1, 2026, 'Domingo', 1, 0, NULL),
(20260316, '2026-03-16', 16, 3, 'Março', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260317, '2026-03-17', 17, 3, 'Março', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260318, '2026-03-18', 18, 3, 'Março', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260319, '2026-03-19', 19, 3, 'Março', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260320, '2026-03-20', 20, 3, 'Março', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260321, '2026-03-21', 21, 3, 'Março', 1, 2026, 'Sábado', 1, 0, NULL),
(20260322, '2026-03-22', 22, 3, 'Março', 1, 2026, 'Domingo', 1, 0, NULL),
(20260323, '2026-03-23', 23, 3, 'Março', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260324, '2026-03-24', 24, 3, 'Março', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260325, '2026-03-25', 25, 3, 'Março', 1, 2026, 'Quarta-feira', 1, 0, NULL),
(20260326, '2026-03-26', 26, 3, 'Março', 1, 2026, 'Quinta-feira', 1, 0, NULL),
(20260327, '2026-03-27', 27, 3, 'Março', 1, 2026, 'Sexta-feira', 1, 0, NULL),
(20260328, '2026-03-28', 28, 3, 'Março', 1, 2026, 'Sábado', 1, 0, NULL),
(20260329, '2026-03-29', 29, 3, 'Março', 1, 2026, 'Domingo', 1, 0, NULL),
(20260330, '2026-03-30', 30, 3, 'Março', 1, 2026, 'Segunda-feira', 1, 0, NULL),
(20260331, '2026-03-31', 31, 3, 'Março', 1, 2026, 'Terça-feira', 1, 0, NULL),
(20260401, '2026-04-01', 1, 4, 'Abril', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260402, '2026-04-02', 2, 4, 'Abril', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260403, '2026-04-03', 3, 4, 'Abril', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260404, '2026-04-04', 4, 4, 'Abril', 2, 2026, 'Sábado', 1, 0, NULL),
(20260405, '2026-04-05', 5, 4, 'Abril', 2, 2026, 'Domingo', 1, 0, NULL),
(20260406, '2026-04-06', 6, 4, 'Abril', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260407, '2026-04-07', 7, 4, 'Abril', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260408, '2026-04-08', 8, 4, 'Abril', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260409, '2026-04-09', 9, 4, 'Abril', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260410, '2026-04-10', 10, 4, 'Abril', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260411, '2026-04-11', 11, 4, 'Abril', 2, 2026, 'Sábado', 1, 0, NULL),
(20260412, '2026-04-12', 12, 4, 'Abril', 2, 2026, 'Domingo', 1, 0, NULL),
(20260413, '2026-04-13', 13, 4, 'Abril', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260414, '2026-04-14', 14, 4, 'Abril', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260415, '2026-04-15', 15, 4, 'Abril', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260416, '2026-04-16', 16, 4, 'Abril', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260417, '2026-04-17', 17, 4, 'Abril', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260418, '2026-04-18', 18, 4, 'Abril', 2, 2026, 'Sábado', 1, 0, NULL),
(20260419, '2026-04-19', 19, 4, 'Abril', 2, 2026, 'Domingo', 1, 0, NULL),
(20260420, '2026-04-20', 20, 4, 'Abril', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260421, '2026-04-21', 21, 4, 'Abril', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260422, '2026-04-22', 22, 4, 'Abril', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260423, '2026-04-23', 23, 4, 'Abril', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260424, '2026-04-24', 24, 4, 'Abril', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260425, '2026-04-25', 25, 4, 'Abril', 2, 2026, 'Sábado', 1, 0, NULL),
(20260426, '2026-04-26', 26, 4, 'Abril', 2, 2026, 'Domingo', 1, 0, NULL),
(20260427, '2026-04-27', 27, 4, 'Abril', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260428, '2026-04-28', 28, 4, 'Abril', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260429, '2026-04-29', 29, 4, 'Abril', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260430, '2026-04-30', 30, 4, 'Abril', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260501, '2026-05-01', 1, 5, 'Maio', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260502, '2026-05-02', 2, 5, 'Maio', 2, 2026, 'Sábado', 1, 0, NULL),
(20260503, '2026-05-03', 3, 5, 'Maio', 2, 2026, 'Domingo', 1, 0, NULL),
(20260504, '2026-05-04', 4, 5, 'Maio', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260505, '2026-05-05', 5, 5, 'Maio', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260506, '2026-05-06', 6, 5, 'Maio', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260507, '2026-05-07', 7, 5, 'Maio', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260508, '2026-05-08', 8, 5, 'Maio', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260509, '2026-05-09', 9, 5, 'Maio', 2, 2026, 'Sábado', 1, 0, NULL),
(20260510, '2026-05-10', 10, 5, 'Maio', 2, 2026, 'Domingo', 1, 0, NULL),
(20260511, '2026-05-11', 11, 5, 'Maio', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260512, '2026-05-12', 12, 5, 'Maio', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260513, '2026-05-13', 13, 5, 'Maio', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260514, '2026-05-14', 14, 5, 'Maio', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260515, '2026-05-15', 15, 5, 'Maio', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260516, '2026-05-16', 16, 5, 'Maio', 2, 2026, 'Sábado', 1, 0, NULL),
(20260517, '2026-05-17', 17, 5, 'Maio', 2, 2026, 'Domingo', 1, 0, NULL),
(20260518, '2026-05-18', 18, 5, 'Maio', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260519, '2026-05-19', 19, 5, 'Maio', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260520, '2026-05-20', 20, 5, 'Maio', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260521, '2026-05-21', 21, 5, 'Maio', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260522, '2026-05-22', 22, 5, 'Maio', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260523, '2026-05-23', 23, 5, 'Maio', 2, 2026, 'Sábado', 1, 0, NULL),
(20260524, '2026-05-24', 24, 5, 'Maio', 2, 2026, 'Domingo', 1, 0, NULL),
(20260525, '2026-05-25', 25, 5, 'Maio', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260526, '2026-05-26', 26, 5, 'Maio', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260527, '2026-05-27', 27, 5, 'Maio', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260528, '2026-05-28', 28, 5, 'Maio', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260529, '2026-05-29', 29, 5, 'Maio', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260530, '2026-05-30', 30, 5, 'Maio', 2, 2026, 'Sábado', 1, 0, NULL),
(20260531, '2026-05-31', 31, 5, 'Maio', 2, 2026, 'Domingo', 1, 0, NULL),
(20260601, '2026-06-01', 1, 6, 'Junho', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260602, '2026-06-02', 2, 6, 'Junho', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260603, '2026-06-03', 3, 6, 'Junho', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260604, '2026-06-04', 4, 6, 'Junho', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260605, '2026-06-05', 5, 6, 'Junho', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260606, '2026-06-06', 6, 6, 'Junho', 2, 2026, 'Sábado', 1, 0, NULL),
(20260607, '2026-06-07', 7, 6, 'Junho', 2, 2026, 'Domingo', 1, 0, NULL),
(20260608, '2026-06-08', 8, 6, 'Junho', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260609, '2026-06-09', 9, 6, 'Junho', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260610, '2026-06-10', 10, 6, 'Junho', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260611, '2026-06-11', 11, 6, 'Junho', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260612, '2026-06-12', 12, 6, 'Junho', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260613, '2026-06-13', 13, 6, 'Junho', 2, 2026, 'Sábado', 1, 0, NULL),
(20260614, '2026-06-14', 14, 6, 'Junho', 2, 2026, 'Domingo', 1, 0, NULL),
(20260615, '2026-06-15', 15, 6, 'Junho', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260616, '2026-06-16', 16, 6, 'Junho', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260617, '2026-06-17', 17, 6, 'Junho', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260618, '2026-06-18', 18, 6, 'Junho', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260619, '2026-06-19', 19, 6, 'Junho', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260620, '2026-06-20', 20, 6, 'Junho', 2, 2026, 'Sábado', 1, 0, NULL),
(20260621, '2026-06-21', 21, 6, 'Junho', 2, 2026, 'Domingo', 1, 0, NULL),
(20260622, '2026-06-22', 22, 6, 'Junho', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260623, '2026-06-23', 23, 6, 'Junho', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260624, '2026-06-24', 24, 6, 'Junho', 2, 2026, 'Quarta-feira', 1, 0, NULL),
(20260625, '2026-06-25', 25, 6, 'Junho', 2, 2026, 'Quinta-feira', 1, 0, NULL),
(20260626, '2026-06-26', 26, 6, 'Junho', 2, 2026, 'Sexta-feira', 1, 0, NULL),
(20260627, '2026-06-27', 27, 6, 'Junho', 2, 2026, 'Sábado', 1, 0, NULL),
(20260628, '2026-06-28', 28, 6, 'Junho', 2, 2026, 'Domingo', 1, 0, NULL),
(20260629, '2026-06-29', 29, 6, 'Junho', 2, 2026, 'Segunda-feira', 1, 0, NULL),
(20260630, '2026-06-30', 30, 6, 'Junho', 2, 2026, 'Terça-feira', 1, 0, NULL),
(20260701, '2026-07-01', 1, 7, 'Julho', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260702, '2026-07-02', 2, 7, 'Julho', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260703, '2026-07-03', 3, 7, 'Julho', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260704, '2026-07-04', 4, 7, 'Julho', 3, 2026, 'Sábado', 2, 0, NULL),
(20260705, '2026-07-05', 5, 7, 'Julho', 3, 2026, 'Domingo', 2, 0, NULL),
(20260706, '2026-07-06', 6, 7, 'Julho', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260707, '2026-07-07', 7, 7, 'Julho', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260708, '2026-07-08', 8, 7, 'Julho', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260709, '2026-07-09', 9, 7, 'Julho', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260710, '2026-07-10', 10, 7, 'Julho', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260711, '2026-07-11', 11, 7, 'Julho', 3, 2026, 'Sábado', 2, 0, NULL),
(20260712, '2026-07-12', 12, 7, 'Julho', 3, 2026, 'Domingo', 2, 0, NULL),
(20260713, '2026-07-13', 13, 7, 'Julho', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260714, '2026-07-14', 14, 7, 'Julho', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260715, '2026-07-15', 15, 7, 'Julho', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260716, '2026-07-16', 16, 7, 'Julho', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260717, '2026-07-17', 17, 7, 'Julho', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260718, '2026-07-18', 18, 7, 'Julho', 3, 2026, 'Sábado', 2, 0, NULL),
(20260719, '2026-07-19', 19, 7, 'Julho', 3, 2026, 'Domingo', 2, 0, NULL),
(20260720, '2026-07-20', 20, 7, 'Julho', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260721, '2026-07-21', 21, 7, 'Julho', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260722, '2026-07-22', 22, 7, 'Julho', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260723, '2026-07-23', 23, 7, 'Julho', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260724, '2026-07-24', 24, 7, 'Julho', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260725, '2026-07-25', 25, 7, 'Julho', 3, 2026, 'Sábado', 2, 0, NULL),
(20260726, '2026-07-26', 26, 7, 'Julho', 3, 2026, 'Domingo', 2, 0, NULL),
(20260727, '2026-07-27', 27, 7, 'Julho', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260728, '2026-07-28', 28, 7, 'Julho', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260729, '2026-07-29', 29, 7, 'Julho', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260730, '2026-07-30', 30, 7, 'Julho', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260731, '2026-07-31', 31, 7, 'Julho', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260801, '2026-08-01', 1, 8, 'Agosto', 3, 2026, 'Sábado', 2, 0, NULL),
(20260802, '2026-08-02', 2, 8, 'Agosto', 3, 2026, 'Domingo', 2, 0, NULL),
(20260803, '2026-08-03', 3, 8, 'Agosto', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260804, '2026-08-04', 4, 8, 'Agosto', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260805, '2026-08-05', 5, 8, 'Agosto', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260806, '2026-08-06', 6, 8, 'Agosto', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260807, '2026-08-07', 7, 8, 'Agosto', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260808, '2026-08-08', 8, 8, 'Agosto', 3, 2026, 'Sábado', 2, 0, NULL),
(20260809, '2026-08-09', 9, 8, 'Agosto', 3, 2026, 'Domingo', 2, 0, NULL),
(20260810, '2026-08-10', 10, 8, 'Agosto', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260811, '2026-08-11', 11, 8, 'Agosto', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260812, '2026-08-12', 12, 8, 'Agosto', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260813, '2026-08-13', 13, 8, 'Agosto', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260814, '2026-08-14', 14, 8, 'Agosto', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260815, '2026-08-15', 15, 8, 'Agosto', 3, 2026, 'Sábado', 2, 0, NULL),
(20260816, '2026-08-16', 16, 8, 'Agosto', 3, 2026, 'Domingo', 2, 0, NULL),
(20260817, '2026-08-17', 17, 8, 'Agosto', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260818, '2026-08-18', 18, 8, 'Agosto', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260819, '2026-08-19', 19, 8, 'Agosto', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260820, '2026-08-20', 20, 8, 'Agosto', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260821, '2026-08-21', 21, 8, 'Agosto', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260822, '2026-08-22', 22, 8, 'Agosto', 3, 2026, 'Sábado', 2, 0, NULL),
(20260823, '2026-08-23', 23, 8, 'Agosto', 3, 2026, 'Domingo', 2, 0, NULL),
(20260824, '2026-08-24', 24, 8, 'Agosto', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260825, '2026-08-25', 25, 8, 'Agosto', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260826, '2026-08-26', 26, 8, 'Agosto', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260827, '2026-08-27', 27, 8, 'Agosto', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260828, '2026-08-28', 28, 8, 'Agosto', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260829, '2026-08-29', 29, 8, 'Agosto', 3, 2026, 'Sábado', 2, 0, NULL),
(20260830, '2026-08-30', 30, 8, 'Agosto', 3, 2026, 'Domingo', 2, 0, NULL),
(20260831, '2026-08-31', 31, 8, 'Agosto', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260901, '2026-09-01', 1, 9, 'Setembro', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260902, '2026-09-02', 2, 9, 'Setembro', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260903, '2026-09-03', 3, 9, 'Setembro', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260904, '2026-09-04', 4, 9, 'Setembro', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260905, '2026-09-05', 5, 9, 'Setembro', 3, 2026, 'Sábado', 2, 0, NULL),
(20260906, '2026-09-06', 6, 9, 'Setembro', 3, 2026, 'Domingo', 2, 0, NULL),
(20260907, '2026-09-07', 7, 9, 'Setembro', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260908, '2026-09-08', 8, 9, 'Setembro', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260909, '2026-09-09', 9, 9, 'Setembro', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260910, '2026-09-10', 10, 9, 'Setembro', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260911, '2026-09-11', 11, 9, 'Setembro', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260912, '2026-09-12', 12, 9, 'Setembro', 3, 2026, 'Sábado', 2, 0, NULL),
(20260913, '2026-09-13', 13, 9, 'Setembro', 3, 2026, 'Domingo', 2, 0, NULL),
(20260914, '2026-09-14', 14, 9, 'Setembro', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260915, '2026-09-15', 15, 9, 'Setembro', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260916, '2026-09-16', 16, 9, 'Setembro', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260917, '2026-09-17', 17, 9, 'Setembro', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260918, '2026-09-18', 18, 9, 'Setembro', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260919, '2026-09-19', 19, 9, 'Setembro', 3, 2026, 'Sábado', 2, 0, NULL),
(20260920, '2026-09-20', 20, 9, 'Setembro', 3, 2026, 'Domingo', 2, 0, NULL),
(20260921, '2026-09-21', 21, 9, 'Setembro', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260922, '2026-09-22', 22, 9, 'Setembro', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260923, '2026-09-23', 23, 9, 'Setembro', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20260924, '2026-09-24', 24, 9, 'Setembro', 3, 2026, 'Quinta-feira', 2, 0, NULL),
(20260925, '2026-09-25', 25, 9, 'Setembro', 3, 2026, 'Sexta-feira', 2, 0, NULL),
(20260926, '2026-09-26', 26, 9, 'Setembro', 3, 2026, 'Sábado', 2, 0, NULL),
(20260927, '2026-09-27', 27, 9, 'Setembro', 3, 2026, 'Domingo', 2, 0, NULL),
(20260928, '2026-09-28', 28, 9, 'Setembro', 3, 2026, 'Segunda-feira', 2, 0, NULL),
(20260929, '2026-09-29', 29, 9, 'Setembro', 3, 2026, 'Terça-feira', 2, 0, NULL),
(20260930, '2026-09-30', 30, 9, 'Setembro', 3, 2026, 'Quarta-feira', 2, 0, NULL),
(20261001, '2026-10-01', 1, 10, 'Outubro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261002, '2026-10-02', 2, 10, 'Outubro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261003, '2026-10-03', 3, 10, 'Outubro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261004, '2026-10-04', 4, 10, 'Outubro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261005, '2026-10-05', 5, 10, 'Outubro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261006, '2026-10-06', 6, 10, 'Outubro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261007, '2026-10-07', 7, 10, 'Outubro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261008, '2026-10-08', 8, 10, 'Outubro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261009, '2026-10-09', 9, 10, 'Outubro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261010, '2026-10-10', 10, 10, 'Outubro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261011, '2026-10-11', 11, 10, 'Outubro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261012, '2026-10-12', 12, 10, 'Outubro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261013, '2026-10-13', 13, 10, 'Outubro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261014, '2026-10-14', 14, 10, 'Outubro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261015, '2026-10-15', 15, 10, 'Outubro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261016, '2026-10-16', 16, 10, 'Outubro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261017, '2026-10-17', 17, 10, 'Outubro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261018, '2026-10-18', 18, 10, 'Outubro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261019, '2026-10-19', 19, 10, 'Outubro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261020, '2026-10-20', 20, 10, 'Outubro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261021, '2026-10-21', 21, 10, 'Outubro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261022, '2026-10-22', 22, 10, 'Outubro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261023, '2026-10-23', 23, 10, 'Outubro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261024, '2026-10-24', 24, 10, 'Outubro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261025, '2026-10-25', 25, 10, 'Outubro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261026, '2026-10-26', 26, 10, 'Outubro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261027, '2026-10-27', 27, 10, 'Outubro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261028, '2026-10-28', 28, 10, 'Outubro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261029, '2026-10-29', 29, 10, 'Outubro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261030, '2026-10-30', 30, 10, 'Outubro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261031, '2026-10-31', 31, 10, 'Outubro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261101, '2026-11-01', 1, 11, 'Novembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261102, '2026-11-02', 2, 11, 'Novembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261103, '2026-11-03', 3, 11, 'Novembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261104, '2026-11-04', 4, 11, 'Novembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261105, '2026-11-05', 5, 11, 'Novembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261106, '2026-11-06', 6, 11, 'Novembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261107, '2026-11-07', 7, 11, 'Novembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261108, '2026-11-08', 8, 11, 'Novembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261109, '2026-11-09', 9, 11, 'Novembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261110, '2026-11-10', 10, 11, 'Novembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261111, '2026-11-11', 11, 11, 'Novembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261112, '2026-11-12', 12, 11, 'Novembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261113, '2026-11-13', 13, 11, 'Novembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261114, '2026-11-14', 14, 11, 'Novembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261115, '2026-11-15', 15, 11, 'Novembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261116, '2026-11-16', 16, 11, 'Novembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261117, '2026-11-17', 17, 11, 'Novembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261118, '2026-11-18', 18, 11, 'Novembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261119, '2026-11-19', 19, 11, 'Novembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261120, '2026-11-20', 20, 11, 'Novembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261121, '2026-11-21', 21, 11, 'Novembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261122, '2026-11-22', 22, 11, 'Novembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261123, '2026-11-23', 23, 11, 'Novembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261124, '2026-11-24', 24, 11, 'Novembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261125, '2026-11-25', 25, 11, 'Novembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261126, '2026-11-26', 26, 11, 'Novembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261127, '2026-11-27', 27, 11, 'Novembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261128, '2026-11-28', 28, 11, 'Novembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261129, '2026-11-29', 29, 11, 'Novembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261130, '2026-11-30', 30, 11, 'Novembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261201, '2026-12-01', 1, 12, 'Dezembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261202, '2026-12-02', 2, 12, 'Dezembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261203, '2026-12-03', 3, 12, 'Dezembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261204, '2026-12-04', 4, 12, 'Dezembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261205, '2026-12-05', 5, 12, 'Dezembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261206, '2026-12-06', 6, 12, 'Dezembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261207, '2026-12-07', 7, 12, 'Dezembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261208, '2026-12-08', 8, 12, 'Dezembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261209, '2026-12-09', 9, 12, 'Dezembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261210, '2026-12-10', 10, 12, 'Dezembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261211, '2026-12-11', 11, 12, 'Dezembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261212, '2026-12-12', 12, 12, 'Dezembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261213, '2026-12-13', 13, 12, 'Dezembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261214, '2026-12-14', 14, 12, 'Dezembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261215, '2026-12-15', 15, 12, 'Dezembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261216, '2026-12-16', 16, 12, 'Dezembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261217, '2026-12-17', 17, 12, 'Dezembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261218, '2026-12-18', 18, 12, 'Dezembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261219, '2026-12-19', 19, 12, 'Dezembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261220, '2026-12-20', 20, 12, 'Dezembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261221, '2026-12-21', 21, 12, 'Dezembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261222, '2026-12-22', 22, 12, 'Dezembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261223, '2026-12-23', 23, 12, 'Dezembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261224, '2026-12-24', 24, 12, 'Dezembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20261225, '2026-12-25', 25, 12, 'Dezembro', 4, 2026, 'Sexta-feira', 2, 0, NULL),
(20261226, '2026-12-26', 26, 12, 'Dezembro', 4, 2026, 'Sábado', 2, 0, NULL),
(20261227, '2026-12-27', 27, 12, 'Dezembro', 4, 2026, 'Domingo', 2, 0, NULL),
(20261228, '2026-12-28', 28, 12, 'Dezembro', 4, 2026, 'Segunda-feira', 2, 0, NULL),
(20261229, '2026-12-29', 29, 12, 'Dezembro', 4, 2026, 'Terça-feira', 2, 0, NULL),
(20261230, '2026-12-30', 30, 12, 'Dezembro', 4, 2026, 'Quarta-feira', 2, 0, NULL),
(20261231, '2026-12-31', 31, 12, 'Dezembro', 4, 2026, 'Quinta-feira', 2, 0, NULL),
(20270101, '2027-01-01', 1, 1, 'Janeiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270102, '2027-01-02', 2, 1, 'Janeiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270103, '2027-01-03', 3, 1, 'Janeiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270104, '2027-01-04', 4, 1, 'Janeiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270105, '2027-01-05', 5, 1, 'Janeiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270106, '2027-01-06', 6, 1, 'Janeiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270107, '2027-01-07', 7, 1, 'Janeiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270108, '2027-01-08', 8, 1, 'Janeiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270109, '2027-01-09', 9, 1, 'Janeiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270110, '2027-01-10', 10, 1, 'Janeiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270111, '2027-01-11', 11, 1, 'Janeiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270112, '2027-01-12', 12, 1, 'Janeiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270113, '2027-01-13', 13, 1, 'Janeiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270114, '2027-01-14', 14, 1, 'Janeiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270115, '2027-01-15', 15, 1, 'Janeiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270116, '2027-01-16', 16, 1, 'Janeiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270117, '2027-01-17', 17, 1, 'Janeiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270118, '2027-01-18', 18, 1, 'Janeiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270119, '2027-01-19', 19, 1, 'Janeiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270120, '2027-01-20', 20, 1, 'Janeiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270121, '2027-01-21', 21, 1, 'Janeiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270122, '2027-01-22', 22, 1, 'Janeiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270123, '2027-01-23', 23, 1, 'Janeiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270124, '2027-01-24', 24, 1, 'Janeiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270125, '2027-01-25', 25, 1, 'Janeiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270126, '2027-01-26', 26, 1, 'Janeiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270127, '2027-01-27', 27, 1, 'Janeiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270128, '2027-01-28', 28, 1, 'Janeiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270129, '2027-01-29', 29, 1, 'Janeiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270130, '2027-01-30', 30, 1, 'Janeiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270131, '2027-01-31', 31, 1, 'Janeiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270201, '2027-02-01', 1, 2, 'Fevereiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270202, '2027-02-02', 2, 2, 'Fevereiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270203, '2027-02-03', 3, 2, 'Fevereiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270204, '2027-02-04', 4, 2, 'Fevereiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270205, '2027-02-05', 5, 2, 'Fevereiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270206, '2027-02-06', 6, 2, 'Fevereiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270207, '2027-02-07', 7, 2, 'Fevereiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270208, '2027-02-08', 8, 2, 'Fevereiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270209, '2027-02-09', 9, 2, 'Fevereiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270210, '2027-02-10', 10, 2, 'Fevereiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270211, '2027-02-11', 11, 2, 'Fevereiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270212, '2027-02-12', 12, 2, 'Fevereiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270213, '2027-02-13', 13, 2, 'Fevereiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270214, '2027-02-14', 14, 2, 'Fevereiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270215, '2027-02-15', 15, 2, 'Fevereiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270216, '2027-02-16', 16, 2, 'Fevereiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270217, '2027-02-17', 17, 2, 'Fevereiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270218, '2027-02-18', 18, 2, 'Fevereiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270219, '2027-02-19', 19, 2, 'Fevereiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270220, '2027-02-20', 20, 2, 'Fevereiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270221, '2027-02-21', 21, 2, 'Fevereiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270222, '2027-02-22', 22, 2, 'Fevereiro', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270223, '2027-02-23', 23, 2, 'Fevereiro', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270224, '2027-02-24', 24, 2, 'Fevereiro', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270225, '2027-02-25', 25, 2, 'Fevereiro', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270226, '2027-02-26', 26, 2, 'Fevereiro', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270227, '2027-02-27', 27, 2, 'Fevereiro', 1, 2027, 'Sábado', 1, 0, NULL),
(20270228, '2027-02-28', 28, 2, 'Fevereiro', 1, 2027, 'Domingo', 1, 0, NULL),
(20270301, '2027-03-01', 1, 3, 'Março', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270302, '2027-03-02', 2, 3, 'Março', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270303, '2027-03-03', 3, 3, 'Março', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270304, '2027-03-04', 4, 3, 'Março', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270305, '2027-03-05', 5, 3, 'Março', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270306, '2027-03-06', 6, 3, 'Março', 1, 2027, 'Sábado', 1, 0, NULL),
(20270307, '2027-03-07', 7, 3, 'Março', 1, 2027, 'Domingo', 1, 0, NULL),
(20270308, '2027-03-08', 8, 3, 'Março', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270309, '2027-03-09', 9, 3, 'Março', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270310, '2027-03-10', 10, 3, 'Março', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270311, '2027-03-11', 11, 3, 'Março', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270312, '2027-03-12', 12, 3, 'Março', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270313, '2027-03-13', 13, 3, 'Março', 1, 2027, 'Sábado', 1, 0, NULL),
(20270314, '2027-03-14', 14, 3, 'Março', 1, 2027, 'Domingo', 1, 0, NULL),
(20270315, '2027-03-15', 15, 3, 'Março', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270316, '2027-03-16', 16, 3, 'Março', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270317, '2027-03-17', 17, 3, 'Março', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270318, '2027-03-18', 18, 3, 'Março', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270319, '2027-03-19', 19, 3, 'Março', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270320, '2027-03-20', 20, 3, 'Março', 1, 2027, 'Sábado', 1, 0, NULL),
(20270321, '2027-03-21', 21, 3, 'Março', 1, 2027, 'Domingo', 1, 0, NULL),
(20270322, '2027-03-22', 22, 3, 'Março', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270323, '2027-03-23', 23, 3, 'Março', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270324, '2027-03-24', 24, 3, 'Março', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270325, '2027-03-25', 25, 3, 'Março', 1, 2027, 'Quinta-feira', 1, 0, NULL),
(20270326, '2027-03-26', 26, 3, 'Março', 1, 2027, 'Sexta-feira', 1, 0, NULL),
(20270327, '2027-03-27', 27, 3, 'Março', 1, 2027, 'Sábado', 1, 0, NULL),
(20270328, '2027-03-28', 28, 3, 'Março', 1, 2027, 'Domingo', 1, 0, NULL),
(20270329, '2027-03-29', 29, 3, 'Março', 1, 2027, 'Segunda-feira', 1, 0, NULL),
(20270330, '2027-03-30', 30, 3, 'Março', 1, 2027, 'Terça-feira', 1, 0, NULL),
(20270331, '2027-03-31', 31, 3, 'Março', 1, 2027, 'Quarta-feira', 1, 0, NULL),
(20270401, '2027-04-01', 1, 4, 'Abril', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270402, '2027-04-02', 2, 4, 'Abril', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270403, '2027-04-03', 3, 4, 'Abril', 2, 2027, 'Sábado', 1, 0, NULL),
(20270404, '2027-04-04', 4, 4, 'Abril', 2, 2027, 'Domingo', 1, 0, NULL),
(20270405, '2027-04-05', 5, 4, 'Abril', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270406, '2027-04-06', 6, 4, 'Abril', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270407, '2027-04-07', 7, 4, 'Abril', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270408, '2027-04-08', 8, 4, 'Abril', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270409, '2027-04-09', 9, 4, 'Abril', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270410, '2027-04-10', 10, 4, 'Abril', 2, 2027, 'Sábado', 1, 0, NULL),
(20270411, '2027-04-11', 11, 4, 'Abril', 2, 2027, 'Domingo', 1, 0, NULL),
(20270412, '2027-04-12', 12, 4, 'Abril', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270413, '2027-04-13', 13, 4, 'Abril', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270414, '2027-04-14', 14, 4, 'Abril', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270415, '2027-04-15', 15, 4, 'Abril', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270416, '2027-04-16', 16, 4, 'Abril', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270417, '2027-04-17', 17, 4, 'Abril', 2, 2027, 'Sábado', 1, 0, NULL),
(20270418, '2027-04-18', 18, 4, 'Abril', 2, 2027, 'Domingo', 1, 0, NULL),
(20270419, '2027-04-19', 19, 4, 'Abril', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270420, '2027-04-20', 20, 4, 'Abril', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270421, '2027-04-21', 21, 4, 'Abril', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270422, '2027-04-22', 22, 4, 'Abril', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270423, '2027-04-23', 23, 4, 'Abril', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270424, '2027-04-24', 24, 4, 'Abril', 2, 2027, 'Sábado', 1, 0, NULL),
(20270425, '2027-04-25', 25, 4, 'Abril', 2, 2027, 'Domingo', 1, 0, NULL),
(20270426, '2027-04-26', 26, 4, 'Abril', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270427, '2027-04-27', 27, 4, 'Abril', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270428, '2027-04-28', 28, 4, 'Abril', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270429, '2027-04-29', 29, 4, 'Abril', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270430, '2027-04-30', 30, 4, 'Abril', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270501, '2027-05-01', 1, 5, 'Maio', 2, 2027, 'Sábado', 1, 0, NULL),
(20270502, '2027-05-02', 2, 5, 'Maio', 2, 2027, 'Domingo', 1, 0, NULL),
(20270503, '2027-05-03', 3, 5, 'Maio', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270504, '2027-05-04', 4, 5, 'Maio', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270505, '2027-05-05', 5, 5, 'Maio', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270506, '2027-05-06', 6, 5, 'Maio', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270507, '2027-05-07', 7, 5, 'Maio', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270508, '2027-05-08', 8, 5, 'Maio', 2, 2027, 'Sábado', 1, 0, NULL),
(20270509, '2027-05-09', 9, 5, 'Maio', 2, 2027, 'Domingo', 1, 0, NULL),
(20270510, '2027-05-10', 10, 5, 'Maio', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270511, '2027-05-11', 11, 5, 'Maio', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270512, '2027-05-12', 12, 5, 'Maio', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270513, '2027-05-13', 13, 5, 'Maio', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270514, '2027-05-14', 14, 5, 'Maio', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270515, '2027-05-15', 15, 5, 'Maio', 2, 2027, 'Sábado', 1, 0, NULL),
(20270516, '2027-05-16', 16, 5, 'Maio', 2, 2027, 'Domingo', 1, 0, NULL),
(20270517, '2027-05-17', 17, 5, 'Maio', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270518, '2027-05-18', 18, 5, 'Maio', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270519, '2027-05-19', 19, 5, 'Maio', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270520, '2027-05-20', 20, 5, 'Maio', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270521, '2027-05-21', 21, 5, 'Maio', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270522, '2027-05-22', 22, 5, 'Maio', 2, 2027, 'Sábado', 1, 0, NULL),
(20270523, '2027-05-23', 23, 5, 'Maio', 2, 2027, 'Domingo', 1, 0, NULL),
(20270524, '2027-05-24', 24, 5, 'Maio', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270525, '2027-05-25', 25, 5, 'Maio', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270526, '2027-05-26', 26, 5, 'Maio', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270527, '2027-05-27', 27, 5, 'Maio', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270528, '2027-05-28', 28, 5, 'Maio', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270529, '2027-05-29', 29, 5, 'Maio', 2, 2027, 'Sábado', 1, 0, NULL),
(20270530, '2027-05-30', 30, 5, 'Maio', 2, 2027, 'Domingo', 1, 0, NULL),
(20270531, '2027-05-31', 31, 5, 'Maio', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270601, '2027-06-01', 1, 6, 'Junho', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270602, '2027-06-02', 2, 6, 'Junho', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270603, '2027-06-03', 3, 6, 'Junho', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270604, '2027-06-04', 4, 6, 'Junho', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270605, '2027-06-05', 5, 6, 'Junho', 2, 2027, 'Sábado', 1, 0, NULL),
(20270606, '2027-06-06', 6, 6, 'Junho', 2, 2027, 'Domingo', 1, 0, NULL),
(20270607, '2027-06-07', 7, 6, 'Junho', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270608, '2027-06-08', 8, 6, 'Junho', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270609, '2027-06-09', 9, 6, 'Junho', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270610, '2027-06-10', 10, 6, 'Junho', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270611, '2027-06-11', 11, 6, 'Junho', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270612, '2027-06-12', 12, 6, 'Junho', 2, 2027, 'Sábado', 1, 0, NULL),
(20270613, '2027-06-13', 13, 6, 'Junho', 2, 2027, 'Domingo', 1, 0, NULL),
(20270614, '2027-06-14', 14, 6, 'Junho', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270615, '2027-06-15', 15, 6, 'Junho', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270616, '2027-06-16', 16, 6, 'Junho', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270617, '2027-06-17', 17, 6, 'Junho', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270618, '2027-06-18', 18, 6, 'Junho', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270619, '2027-06-19', 19, 6, 'Junho', 2, 2027, 'Sábado', 1, 0, NULL),
(20270620, '2027-06-20', 20, 6, 'Junho', 2, 2027, 'Domingo', 1, 0, NULL),
(20270621, '2027-06-21', 21, 6, 'Junho', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270622, '2027-06-22', 22, 6, 'Junho', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270623, '2027-06-23', 23, 6, 'Junho', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270624, '2027-06-24', 24, 6, 'Junho', 2, 2027, 'Quinta-feira', 1, 0, NULL),
(20270625, '2027-06-25', 25, 6, 'Junho', 2, 2027, 'Sexta-feira', 1, 0, NULL),
(20270626, '2027-06-26', 26, 6, 'Junho', 2, 2027, 'Sábado', 1, 0, NULL),
(20270627, '2027-06-27', 27, 6, 'Junho', 2, 2027, 'Domingo', 1, 0, NULL),
(20270628, '2027-06-28', 28, 6, 'Junho', 2, 2027, 'Segunda-feira', 1, 0, NULL),
(20270629, '2027-06-29', 29, 6, 'Junho', 2, 2027, 'Terça-feira', 1, 0, NULL),
(20270630, '2027-06-30', 30, 6, 'Junho', 2, 2027, 'Quarta-feira', 1, 0, NULL),
(20270701, '2027-07-01', 1, 7, 'Julho', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270702, '2027-07-02', 2, 7, 'Julho', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270703, '2027-07-03', 3, 7, 'Julho', 3, 2027, 'Sábado', 2, 0, NULL),
(20270704, '2027-07-04', 4, 7, 'Julho', 3, 2027, 'Domingo', 2, 0, NULL),
(20270705, '2027-07-05', 6, 7, 'Julho', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270706, '2027-07-06', 6, 7, 'Julho', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270707, '2027-07-07', 7, 7, 'Julho', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270708, '2027-07-08', 8, 7, 'Julho', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270709, '2027-07-09', 9, 7, 'Julho', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270710, '2027-07-10', 10, 7, 'Julho', 3, 2027, 'Sábado', 2, 0, NULL),
(20270711, '2027-07-11', 11, 7, 'Julho', 3, 2027, 'Domingo', 2, 0, NULL),
(20270712, '2027-07-12', 12, 7, 'Julho', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270713, '2027-07-13', 13, 7, 'Julho', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270714, '2027-07-14', 14, 7, 'Julho', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270715, '2027-07-15', 15, 7, 'Julho', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270716, '2027-07-16', 16, 7, 'Julho', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270717, '2027-07-17', 17, 7, 'Julho', 3, 2027, 'Sábado', 2, 0, NULL),
(20270718, '2027-07-18', 18, 7, 'Julho', 3, 2027, 'Domingo', 2, 0, NULL),
(20270719, '2027-07-19', 19, 7, 'Julho', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270720, '2027-07-20', 20, 7, 'Julho', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270721, '2027-07-21', 21, 7, 'Julho', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270722, '2027-07-22', 22, 7, 'Julho', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270723, '2027-07-23', 23, 7, 'Julho', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270724, '2027-07-24', 24, 7, 'Julho', 3, 2027, 'Sábado', 2, 0, NULL),
(20270725, '2027-07-25', 25, 7, 'Julho', 3, 2027, 'Domingo', 2, 0, NULL),
(20270726, '2027-07-26', 26, 7, 'Julho', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270727, '2027-07-27', 27, 7, 'Julho', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270728, '2027-07-28', 28, 7, 'Julho', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270729, '2027-07-29', 29, 7, 'Julho', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270730, '2027-07-30', 30, 7, 'Julho', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270731, '2027-07-31', 31, 7, 'Julho', 3, 2027, 'Sábado', 2, 0, NULL),
(20270801, '2027-08-01', 1, 8, 'Agosto', 3, 2027, 'Domingo', 2, 0, NULL),
(20270802, '2027-08-02', 2, 8, 'Agosto', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270803, '2027-08-03', 3, 8, 'Agosto', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270804, '2027-08-04', 4, 8, 'Agosto', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270805, '2027-08-05', 5, 8, 'Agosto', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270806, '2027-08-06', 6, 8, 'Agosto', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270807, '2027-08-07', 7, 8, 'Agosto', 3, 2027, 'Sábado', 2, 0, NULL),
(20270808, '2027-08-08', 8, 8, 'Agosto', 3, 2027, 'Domingo', 2, 0, NULL),
(20270809, '2027-08-09', 9, 8, 'Agosto', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270810, '2027-08-10', 10, 8, 'Agosto', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270811, '2027-08-11', 11, 8, 'Agosto', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270812, '2027-08-12', 12, 8, 'Agosto', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270813, '2027-08-13', 13, 8, 'Agosto', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270814, '2027-08-14', 14, 8, 'Agosto', 3, 2027, 'Sábado', 2, 0, NULL),
(20270815, '2027-08-15', 15, 8, 'Agosto', 3, 2027, 'Domingo', 2, 0, NULL),
(20270816, '2027-08-16', 16, 8, 'Agosto', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270817, '2027-08-17', 17, 8, 'Agosto', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270818, '2027-08-18', 18, 8, 'Agosto', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270819, '2027-08-19', 19, 8, 'Agosto', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270820, '2027-08-20', 20, 8, 'Agosto', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270821, '2027-08-21', 21, 8, 'Agosto', 3, 2027, 'Sábado', 2, 0, NULL),
(20270822, '2027-08-22', 22, 8, 'Agosto', 3, 2027, 'Domingo', 2, 0, NULL),
(20270823, '2027-08-23', 23, 8, 'Agosto', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270824, '2027-08-24', 24, 8, 'Agosto', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270825, '2027-08-25', 25, 8, 'Agosto', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270826, '2027-08-26', 26, 8, 'Agosto', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270827, '2027-08-27', 27, 8, 'Agosto', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270828, '2027-08-28', 28, 8, 'Agosto', 3, 2027, 'Sábado', 2, 0, NULL),
(20270829, '2027-08-29', 29, 8, 'Agosto', 3, 2027, 'Domingo', 2, 0, NULL),
(20270830, '2027-08-30', 30, 8, 'Agosto', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270831, '2027-08-31', 31, 8, 'Agosto', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270901, '2027-09-01', 1, 9, 'Setembro', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270902, '2027-09-02', 2, 9, 'Setembro', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270903, '2027-09-03', 3, 9, 'Setembro', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270904, '2027-09-04', 4, 9, 'Setembro', 3, 2027, 'Sábado', 2, 0, NULL),
(20270905, '2027-09-05', 5, 9, 'Setembro', 3, 2027, 'Domingo', 2, 0, NULL),
(20270906, '2027-09-06', 6, 9, 'Setembro', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270907, '2027-09-07', 7, 9, 'Setembro', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270908, '2027-09-08', 8, 9, 'Setembro', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270909, '2027-09-09', 9, 9, 'Setembro', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270910, '2027-09-10', 10, 9, 'Setembro', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270911, '2027-09-11', 11, 9, 'Setembro', 3, 2027, 'Sábado', 2, 0, NULL),
(20270912, '2027-09-12', 12, 9, 'Setembro', 3, 2027, 'Domingo', 2, 0, NULL),
(20270913, '2027-09-13', 13, 9, 'Setembro', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270914, '2027-09-14', 14, 9, 'Setembro', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270915, '2027-09-15', 15, 9, 'Setembro', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270916, '2027-09-16', 16, 9, 'Setembro', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270917, '2027-09-17', 17, 9, 'Setembro', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270918, '2027-09-18', 18, 9, 'Setembro', 3, 2027, 'Sábado', 2, 0, NULL),
(20270919, '2027-09-19', 19, 9, 'Setembro', 3, 2027, 'Domingo', 2, 0, NULL),
(20270920, '2027-09-20', 20, 9, 'Setembro', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270921, '2027-09-21', 21, 9, 'Setembro', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270922, '2027-09-22', 22, 9, 'Setembro', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270923, '2027-09-23', 23, 9, 'Setembro', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20270924, '2027-09-24', 24, 9, 'Setembro', 3, 2027, 'Sexta-feira', 2, 0, NULL),
(20270925, '2027-09-25', 25, 9, 'Setembro', 3, 2027, 'Sábado', 2, 0, NULL),
(20270926, '2027-09-26', 26, 9, 'Setembro', 3, 2027, 'Domingo', 2, 0, NULL),
(20270927, '2027-09-27', 27, 9, 'Setembro', 3, 2027, 'Segunda-feira', 2, 0, NULL),
(20270928, '2027-09-28', 28, 9, 'Setembro', 3, 2027, 'Terça-feira', 2, 0, NULL),
(20270929, '2027-09-29', 29, 9, 'Setembro', 3, 2027, 'Quarta-feira', 2, 0, NULL),
(20270930, '2027-09-30', 30, 9, 'Setembro', 3, 2027, 'Quinta-feira', 2, 0, NULL),
(20271001, '2027-10-01', 1, 10, 'Outubro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271002, '2027-10-02', 2, 10, 'Outubro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271003, '2027-10-03', 3, 10, 'Outubro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271004, '2027-10-04', 4, 10, 'Outubro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271005, '2027-10-05', 5, 10, 'Outubro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271006, '2027-10-06', 6, 10, 'Outubro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271007, '2027-10-07', 7, 10, 'Outubro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271008, '2027-10-08', 8, 10, 'Outubro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271009, '2027-10-09', 9, 10, 'Outubro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271010, '2027-10-10', 10, 10, 'Outubro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271011, '2027-10-11', 11, 10, 'Outubro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271012, '2027-10-12', 12, 10, 'Outubro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271013, '2027-10-13', 13, 10, 'Outubro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271014, '2027-10-14', 14, 10, 'Outubro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271015, '2027-10-15', 15, 10, 'Outubro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271016, '2027-10-16', 16, 10, 'Outubro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271017, '2027-10-17', 17, 10, 'Outubro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271018, '2027-10-18', 18, 10, 'Outubro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271019, '2027-10-19', 19, 10, 'Outubro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271020, '2027-10-20', 20, 10, 'Outubro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271021, '2027-10-21', 21, 10, 'Outubro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271022, '2027-10-22', 22, 10, 'Outubro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271023, '2027-10-23', 23, 10, 'Outubro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271024, '2027-10-24', 24, 10, 'Outubro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271025, '2027-10-25', 25, 10, 'Outubro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271026, '2027-10-26', 26, 10, 'Outubro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271027, '2027-10-27', 27, 10, 'Outubro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271028, '2027-10-28', 28, 10, 'Outubro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271029, '2027-10-29', 29, 10, 'Outubro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271030, '2027-10-30', 30, 10, 'Outubro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271031, '2027-10-31', 31, 10, 'Outubro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271101, '2027-11-01', 1, 11, 'Novembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271102, '2027-11-02', 2, 11, 'Novembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271103, '2027-11-03', 3, 11, 'Novembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271104, '2027-11-04', 4, 11, 'Novembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271105, '2027-11-05', 5, 11, 'Novembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271106, '2027-11-06', 6, 11, 'Novembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271107, '2027-11-07', 7, 11, 'Novembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271108, '2027-11-08', 8, 11, 'Novembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271109, '2027-11-09', 9, 11, 'Novembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271110, '2027-11-10', 10, 11, 'Novembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271111, '2027-11-11', 11, 11, 'Novembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271112, '2027-11-12', 12, 11, 'Novembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271113, '2027-11-13', 13, 11, 'Novembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271114, '2027-11-14', 14, 11, 'Novembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271115, '2027-11-15', 15, 11, 'Novembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271116, '2027-11-16', 16, 11, 'Novembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271117, '2027-11-17', 17, 11, 'Novembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271118, '2027-11-18', 18, 11, 'Novembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271119, '2027-11-19', 19, 11, 'Novembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271120, '2027-11-20', 20, 11, 'Novembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271121, '2027-11-21', 21, 11, 'Novembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271122, '2027-11-22', 22, 11, 'Novembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271123, '2027-11-23', 23, 11, 'Novembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271124, '2027-11-24', 24, 11, 'Novembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271125, '2027-11-25', 25, 11, 'Novembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271126, '2027-11-26', 26, 11, 'Novembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271127, '2027-11-27', 27, 11, 'Novembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271128, '2027-11-28', 28, 11, 'Novembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271129, '2027-11-29', 29, 11, 'Novembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271130, '2027-11-30', 30, 11, 'Novembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271201, '2027-12-01', 1, 12, 'Dezembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271202, '2027-12-02', 2, 12, 'Dezembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271203, '2027-12-03', 3, 12, 'Dezembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271204, '2027-12-04', 4, 12, 'Dezembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271205, '2027-12-05', 5, 12, 'Dezembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271206, '2027-12-06', 6, 12, 'Dezembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271207, '2027-12-07', 7, 12, 'Dezembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271208, '2027-12-08', 8, 12, 'Dezembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271209, '2027-12-09', 9, 12, 'Dezembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271210, '2027-12-10', 10, 12, 'Dezembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271211, '2027-12-11', 11, 12, 'Dezembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271212, '2027-12-12', 12, 12, 'Dezembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271213, '2027-12-13', 13, 12, 'Dezembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271214, '2027-12-14', 14, 12, 'Dezembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271215, '2027-12-15', 15, 12, 'Dezembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271216, '2027-12-16', 16, 12, 'Dezembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271217, '2027-12-17', 17, 12, 'Dezembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271218, '2027-12-18', 18, 12, 'Dezembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271219, '2027-12-19', 19, 12, 'Dezembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271220, '2027-12-20', 20, 12, 'Dezembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271221, '2027-12-21', 21, 12, 'Dezembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271222, '2027-12-22', 22, 12, 'Dezembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271223, '2027-12-23', 23, 12, 'Dezembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271224, '2027-12-24', 24, 12, 'Dezembro', 4, 2027, 'Sexta-feira', 2, 0, NULL),
(20271225, '2027-12-25', 25, 12, 'Dezembro', 4, 2027, 'Sábado', 2, 0, NULL),
(20271226, '2027-12-26', 26, 12, 'Dezembro', 4, 2027, 'Domingo', 2, 0, NULL),
(20271227, '2027-12-27', 27, 12, 'Dezembro', 4, 2027, 'Segunda-feira', 2, 0, NULL),
(20271228, '2027-12-28', 28, 12, 'Dezembro', 4, 2027, 'Terça-feira', 2, 0, NULL),
(20271229, '2027-12-29', 29, 12, 'Dezembro', 4, 2027, 'Quarta-feira', 2, 0, NULL),
(20271230, '2027-12-30', 30, 12, 'Dezembro', 4, 2027, 'Quinta-feira', 2, 0, NULL),
(20271231, '2027-12-31', 31, 12, 'Dezembro', 4, 2027, 'Sexta-feira', 2, 0, NULL);

UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Confraternização Universal' WHERE sk_tempo = 20250101;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Carnaval' WHERE sk_tempo = 20250304;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Sexta-feira Santa' WHERE sk_tempo = 20250418;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Páscoa' WHERE sk_tempo = 20250420;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Tiradentes' WHERE sk_tempo = 20250421;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia do Trabalho' WHERE sk_tempo = 20250501;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Corpus Christi' WHERE sk_tempo = 20250619;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Independência do Brasil' WHERE sk_tempo = 20250907;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Nossa Sra. Aparecida' WHERE sk_tempo = 20251012;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia do Professor' WHERE sk_tempo = 20251015;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Finados' WHERE sk_tempo = 20251102;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Proclamação da República' WHERE sk_tempo = 20251115;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia da Consciência Negra' WHERE sk_tempo = 20251120;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Natal' WHERE sk_tempo = 20251225;

UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Confraternização Universal' WHERE sk_tempo = 20260101;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Carnaval' WHERE sk_tempo = 20260217;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Sexta-feira Santa' WHERE sk_tempo = 20260403;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Páscoa' WHERE sk_tempo = 20260405;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Tiradentes' WHERE sk_tempo = 20260421;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia do Trabalho' WHERE sk_tempo = 20260501;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Corpus Christi' WHERE sk_tempo = 20260604;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Independência do Brasil' WHERE sk_tempo = 20260907;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Nossa Sra. Aparecida' WHERE sk_tempo = 20261012;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia do Professor' WHERE sk_tempo = 20261015;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Finados' WHERE sk_tempo = 20261102;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Proclamação da República' WHERE sk_tempo = 20261115;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia da Consciência Negra' WHERE sk_tempo = 20261120;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Natal' WHERE sk_tempo = 20261225;

UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Confraternização Universal' WHERE sk_tempo = 20270101;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Carnaval' WHERE sk_tempo = 20270209;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Sexta-feira Santa' WHERE sk_tempo = 20270326;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Páscoa' WHERE sk_tempo = 20270328;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Tiradentes' WHERE sk_tempo = 20270421;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia do Trabalho' WHERE sk_tempo = 20270501;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Corpus Christi' WHERE sk_tempo = 20270527;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Independência do Brasil' WHERE sk_tempo = 20270907;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Nossa Sra. Aparecida' WHERE sk_tempo = 20271012;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia do Professor' WHERE sk_tempo = 20271015;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Finados' WHERE sk_tempo = 20271102;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Proclamação da República' WHERE sk_tempo = 20271115;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Dia da Consciência Negra' WHERE sk_tempo = 20271120;
UPDATE dim_tempo SET flag_feriado = 1, nome_feriado = 'Natal' WHERE sk_tempo = 20271225;

-- ============================================================
-- 10. FATO_ACADEMICO
-- ============================================================

select count(*) from fato_academico;

INSERT INTO fato_academico (
    sk_aluno, sk_turma, sk_unidade, sk_tempo, sk_status, 
    num_trimestre, nota, total_faltas, qtd_matricula
)
-- TRIMESTRE 1
SELECT
    da.sk_aluno, dt.sk_turma, du.sk_unidade, dtempo.sk_tempo, ds.sk_status,1,
    m.nota1 AS nota,
    m.total_faltas / 4 AS total_faltas, -- Dividindo faltas por 4 para não quadruplicar o total no BI
    0.25 AS qtd_matricula -- Cada linha representa 1/4 da matrícula total
FROM tb_matricula m
JOIN dim_aluno da ON da.ra = m.pk_fk_ra
JOIN dim_turma dt ON dt.id_turma = m.pk_fk_id_turma
JOIN tb_turma t ON t.pk_id_turma = m.pk_fk_id_turma
JOIN dim_unidade du ON du.id_unidade = t.fk_id_unidade
JOIN dim_status ds ON ds.status_nome = m.status_matricula
JOIN dim_tempo dtempo ON dtempo.data_completa = m.data_matricula
WHERE m.nota1 IS NOT NULL

UNION ALL

-- TRIMESTRE 2
SELECT
    da.sk_aluno, dt.sk_turma, du.sk_unidade, dtempo.sk_tempo, ds.sk_status,2,
    m.nota2 AS nota,
    m.total_faltas / 4,
    0.25
FROM tb_matricula m
JOIN dim_aluno da ON da.ra = m.pk_fk_ra
JOIN dim_turma dt ON dt.id_turma = m.pk_fk_id_turma
JOIN tb_turma t ON t.pk_id_turma = m.pk_fk_id_turma
JOIN dim_unidade du ON du.id_unidade = t.fk_id_unidade
JOIN dim_status ds ON ds.status_nome = m.status_matricula
JOIN dim_tempo dtempo ON dtempo.data_completa = m.data_matricula
WHERE m.nota2 IS NOT NULL

UNION ALL

-- TRIMESTRE 3
SELECT
    da.sk_aluno, dt.sk_turma, du.sk_unidade, dtempo.sk_tempo, ds.sk_status,3,
    m.nota2 AS nota,
    m.total_faltas / 4,
    0.25
FROM tb_matricula m
JOIN dim_aluno da ON da.ra = m.pk_fk_ra
JOIN dim_turma dt ON dt.id_turma = m.pk_fk_id_turma
JOIN tb_turma t ON t.pk_id_turma = m.pk_fk_id_turma
JOIN dim_unidade du ON du.id_unidade = t.fk_id_unidade
JOIN dim_status ds ON ds.status_nome = m.status_matricula
JOIN dim_tempo dtempo ON dtempo.data_completa = m.data_matricula
WHERE m.nota3 IS NOT NULL

UNION ALL
-- TRIMESTRE 4
SELECT
    da.sk_aluno, dt.sk_turma, du.sk_unidade, dtempo.sk_tempo, ds.sk_status,4,
    m.nota2 AS nota,
    m.total_faltas / 4,
    0.25
FROM tb_matricula m
JOIN dim_aluno da ON da.ra = m.pk_fk_ra
JOIN dim_turma dt ON dt.id_turma = m.pk_fk_id_turma
JOIN tb_turma t ON t.pk_id_turma = m.pk_fk_id_turma
JOIN dim_unidade du ON du.id_unidade = t.fk_id_unidade
JOIN dim_status ds ON ds.status_nome = m.status_matricula
JOIN dim_tempo dtempo ON dtempo.data_completa = m.data_matricula
WHERE m.nota4 IS NOT NULL;
    
-- --------------------------------------------------------------------------
-- 11. FATO_FINANCEIRO
-- --------------------------------------------------------------------------

INSERT INTO fato_financeiro (
     sk_tempo, 
     sk_unidade, 
     sk_forma_pagamento, 
     sk_natureza, 
     sk_aluno, 
     sk_fornecedor, 
     num_documento, 
     valor_total, 
     quantidade 
) 
SELECT 
     dt.sk_tempo, 
     du.sk_unidade, 
     dfp.sk_forma_pagamento, 
     dn.sk_natureza, 
     da.sk_aluno, 
     0, -- sk_fornecedor (Não Aplicável para mensalidade)
     men.pk_nsu, 
     pg.valor_pago, 
     1 
FROM tb_pagamento pg 
JOIN tb_conta_receber cr ON cr.pk_id_conta_receber = pg.fk_id_conta_receber 
JOIN tb_mensalidade men ON men.pk_nsu = cr.fk_nsu 
JOIN tb_contrato c ON c.pk_registro_nrcontrato = men.fk_registro_nrcontrato 
JOIN dim_aluno da ON da.ra = c.fk_ra 
JOIN tb_turma t ON t.pk_id_turma = c.fk_id_turma 
JOIN dim_unidade du ON du.id_unidade = t.fk_id_unidade 
JOIN dim_tempo dt ON dt.data_completa = pg.data_pagamento 
JOIN dim_forma_pagamento dfp ON LOWER(dfp.forma_pagamento) = LOWER(pg.forma_pagamento) 
JOIN dim_natureza_financeira dn ON dn.codigo_operacional = 1;

INSERT INTO fato_financeiro (
     sk_tempo, 
     sk_unidade, 
     sk_forma_pagamento, 
     sk_natureza, 
     sk_aluno, 
     sk_fornecedor, 
     num_documento, 
     valor_total, 
     quantidade 
) 
SELECT 
     dt.sk_tempo, 
     1, -- sk_unidade (Geralmente 1 para Sede/Adm em despesas)
     1, -- sk_forma_pagamento (Definir padrão ou mapear de tb_conta_pagar se houver)
     dn.sk_natureza, 
     0, -- sk_aluno (Não Aplicável para fornecedor)
     df.sk_fornecedor, 
     cp.fk_nfe, 
     SUM(ic.valor_unitario * ic.qtd), 
     SUM(ic.qtd)
FROM tb_conta_pagar cp
JOIN tb_item_compra ic ON ic.pk_fk_nfe = cp.fk_nfe
JOIN tb_compra c ON c.pk_nfe = cp.fk_nfe
JOIN dim_fornecedor df ON df.cnpj = c.fk_cnpj
JOIN dim_tempo dt ON dt.data_completa = cp.data_pagamento
JOIN dim_natureza_financeira dn ON dn.codigo_operacional = 3 -- 3 = Compra
GROUP BY 
     dt.sk_tempo, 
     df.sk_fornecedor, 
     cp.fk_nfe, 
     dn.sk_natureza;
select * from fato_financeiro;
-- --------------------------------------------------------------------------
-- 12. FATO_RH
-- --------------------------------------------------------------------------
INSERT INTO fato_rh (
    sk_funcionario,
    sk_unidade,
    sk_tempo,
    salario_base,
    total_proventos,
    total_descontos,
    salario_liquido,
    horas_trabalhadas,
    horas_extra,
    qtd_faltas_ponto,
    flag_ferias,
    flag_afastamento,
    qtd_treinamentos,
    horas_treinamento
)
SELECT
    df.sk_funcionario,
    du.sk_unidade,
    dt.sk_tempo,
    -- Financeiro
    COALESCE(folha.salario_base, 0) AS salario_base,
    (
        COALESCE(folha.salario_base, 0)
        + COALESCE(prov.total_prov, 0)
    ) AS total_proventos,

    COALESCE(desc_tab.total_desc, 0) AS total_descontos,
    (
        COALESCE(folha.salario_base, 0)
        + COALESCE(prov.total_prov, 0)
        - COALESCE(desc_tab.total_desc, 0)
    ) AS salario_liquido,
    -- Frequência
    COALESCE(ponto.horas_totais, 0) AS horas_trabalhadas,
    COALESCE(ponto.horas_extras, 0) AS horas_extra,
    COALESCE(ponto.faltas, 0) AS qtd_faltas_ponto,
    -- Status
    COALESCE(fer.flag_ferias, 0) AS flag_ferias,
    COALESCE(afast.flag_afastamento, 0) AS flag_afastamento,
    -- Desenvolvimento
    COALESCE(treinos.qtd, 0) AS qtd_treinamentos,
    COALESCE(treinos.horas, 0) AS horas_treinamento
FROM dim_funcionario df
JOIN tb_funcionario f
    ON df.cpf = f.fk_cpf
JOIN dim_unidade du
    ON du.sk_unidade = 1
-- Um registro por mês
JOIN dim_tempo dt
    ON dt.dia = 1
   AND dt.data_completa BETWEEN '2025-01-01' AND '2025-12-01'
-- Folha do mês
LEFT JOIN tb_folha_pagamento folha
    ON folha.fk_n_contratacao = f.pk_n_contratacao
   AND folha.data_pagamento >= dt.data_completa
   AND folha.data_pagamento < DATE_ADD(dt.data_completa, INTERVAL 1 MONTH)
-- Proventos consolidados
LEFT JOIN (
    SELECT
        fk_id_folha,
        SUM(valor) AS total_prov
    FROM tb_provento
    GROUP BY fk_id_folha
) prov
    ON prov.fk_id_folha = folha.pk_id_folha
-- Descontos consolidados
LEFT JOIN (
    SELECT
        fk_id_folha,
        SUM(valor) AS total_desc
    FROM tb_desconto
    GROUP BY fk_id_folha
) desc_tab
    ON desc_tab.fk_id_folha = folha.pk_id_folha
-- Pontos consolidados por mês
LEFT JOIN (
    SELECT
        fk_n_contratacao,
        DATE_FORMAT(data, '%Y-%m-01') AS mes_ref,
        SUM(
            TIMESTAMPDIFF(
                HOUR,
                hora_entrada,
                hora_saida
            )
        ) AS horas_totais,
        SUM(
            CASE
                WHEN TIMESTAMPDIFF(
                    HOUR,
                    hora_entrada,
                    hora_saida
                ) > 8
                THEN TIMESTAMPDIFF(
                    HOUR,
                    hora_entrada,
                    hora_saida
                ) - 8
                ELSE 0
            END
        ) AS horas_extras,
        SUM(
            CASE
                WHEN hora_saida IS NULL
                THEN 1
                ELSE 0
            END
        ) AS faltas
    FROM tb_ponto
    GROUP BY
        fk_n_contratacao,
        DATE_FORMAT(data, '%Y-%m-01')
) ponto
    ON ponto.fk_n_contratacao = f.pk_n_contratacao
   AND ponto.mes_ref = dt.data_completa
-- Treinamentos consolidados por mês
LEFT JOIN (
    SELECT
        fk_n_contratacao,
        DATE_FORMAT(data_inicio, '%Y-%m-01') AS mes_ref,
        COUNT(*) AS qtd,
        SUM(carga_horaria) AS horas
    FROM tb_treinamento
    GROUP BY
        fk_n_contratacao,
        DATE_FORMAT(data_inicio, '%Y-%m-01')
) treinos
    ON treinos.fk_n_contratacao = f.pk_n_contratacao
   AND treinos.mes_ref = dt.data_completa
-- Férias por mês
LEFT JOIN (
    SELECT DISTINCT
        tf.fk_n_contratacao,
        dt2.data_completa AS mes_ref,
        1 AS flag_ferias
    FROM tb_ferias tf
    JOIN dim_tempo dt2
        ON dt2.dia = 1
       AND dt2.data_completa BETWEEN '2025-01-01' AND '2025-12-01'
    WHERE tf.data_inicio <= LAST_DAY(dt2.data_completa)
      AND tf.data_fim >= dt2.data_completa
) fer
    ON fer.fk_n_contratacao = f.pk_n_contratacao
   AND fer.mes_ref = dt.data_completa
-- Afastamentos por mês
LEFT JOIN (
    SELECT DISTINCT
        ta.fk_n_contratacao,
        dt3.data_completa AS mes_ref,
        1 AS flag_afastamento
    FROM tb_afastamento ta
    JOIN dim_tempo dt3
        ON dt3.dia = 1
       AND dt3.data_completa BETWEEN '2025-01-01' AND '2025-12-01'
    WHERE ta.data_inicio <= LAST_DAY(dt3.data_completa)
      AND (
            ta.data_fim >= dt3.data_completa
            OR ta.data_fim IS NULL
          )
) afast
    ON afast.fk_n_contratacao = f.pk_n_contratacao
   AND afast.mes_ref = dt.data_completa
WHERE
    (
        f.dt_desligamento IS NULL
        OR f.dt_desligamento >= dt.data_completa
    );

-- ========================================================================
-- VALIDAÇÃO DO ETL
-- ========================================================================

SELECT SUM(valor_pago) as total_oltp_mensalidades 
FROM tb_pagamento; 	
SELECT SUM(valor_total) as total_olap_mensalidades 
FROM fato_financeiro 
WHERE sk_natureza = 1;

-- ----------------------------------------------------------------------------

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
