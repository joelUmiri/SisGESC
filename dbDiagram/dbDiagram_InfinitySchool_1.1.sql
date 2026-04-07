CREATE TABLE `pessoa` (
  `cpf` char(11) PRIMARY KEY NOT NULL,
  `primeiro_nome` varchar(15) NOT NULL,
  `sobrenome` varchar(30) NOT NULL,
  `data_nasc` date NOT NULL,
  `genero` enum(Masculino,Feminino,Outro),
  `deficiencia` enum(Visual,Auditiva,Motora,Intelectual,Multipla,Nenhuma) DEFAULT 'Nenhuma',
  `etnia` enum(Branca,Preta,Parda,Amarela,Indígena,Outro/Prefiro não responder)
);

CREATE TABLE `unidade` (
  `id_unidade` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) UNIQUE NOT NULL,
  `logradouro` varchar(100) NOT NULL,
  `num_logradouro` varchar(10) NOT NULL,
  `telefone` varchar(15) NOT NULL
);

CREATE TABLE `curso` (
  `id_curso` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_curso` varchar(50) UNIQUE NOT NULL,
  `duracao_meses` int NOT NULL,
  `idade_min` int NOT NULL,
  `idade_max` int
);

CREATE TABLE `cargo` (
  `id_cargo` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `cargo` varchar(50) UNIQUE NOT NULL
);

CREATE TABLE `aluno` (
  `ra` varchar(10) PRIMARY KEY NOT NULL,
  `cpf` char(11) NOT NULL
);

CREATE TABLE `funcionario` (
  `n_contratacao` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `cpf` char(11) NOT NULL,
  `ano_contratacao` date NOT NULL
);

CREATE TABLE `email` (
  `email` varchar(40) NOT NULL,
  `cpf` char(11) NOT NULL,
  PRIMARY KEY (`email`, `cpf`)
);

CREATE TABLE `telefone` (
  `num_pais` char(3) NOT NULL DEFAULT 55,
  `ddd` char(2) NOT NULL,
  `numero` char(9) NOT NULL,
  `cpf` char(11) NOT NULL,
  PRIMARY KEY (`num_pais`, `ddd`, `numero`, `cpf`)
);

CREATE TABLE `endereco` (
  `cep` char(8) NOT NULL,
  `numero` int NOT NULL,
  `complemento` varchar(20),
  `cpf` char(11) NOT NULL,
  PRIMARY KEY (`cep`, `numero`)
);

CREATE TABLE `disciplina` (
  `id_curso` int NOT NULL,
  `id_disciplina` int NOT NULL,
  `disciplina` varchar(50) NOT NULL,
  PRIMARY KEY (`id_curso`, `id_disciplina`)
);

CREATE TABLE `turma` (
  `id_turma` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `n_contratacao` int NOT NULL,
  `id_curso` int NOT NULL,
  `id_disciplina` int NOT NULL,
  `id_unidade` int NOT NULL,
  `semestre` int NOT NULL,
  `ano` int NOT NULL,
  `turno` enum(matutino,vespertino,noturno)
);

CREATE TABLE `func_cargo` (
  `n_contratacao` int NOT NULL,
  `id_cargo` int NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date,
  PRIMARY KEY (`n_contratacao`, `id_cargo`, `data_inicio`)
);

CREATE TABLE `matricula` (
  `ra` varchar(10) NOT NULL,
  `id_turma` int NOT NULL,
  `data_matricula` date NOT NULL,
  `status_matricula` enum(cursando,aprovado,reprovado,trancado,evadido) DEFAULT 'cursando',
  `nota_final` DECIMAL(4,2),
  `total_faltas` INT DEFAULT 0,
  PRIMARY KEY (`ra`, `id_turma`)
);

CREATE TABLE `grade_horaria` (
  `id_turma` int NOT NULL,
  `dia_semana` enum(seg,ter,qua,qui,sex),
  `hora_inicio` time NOT NULL,
  `hora_fim` time NOT NULL,
  PRIMARY KEY (`id_turma`, `dia_semana`, `hora_inicio`)
);

ALTER TABLE `telefone` ADD FOREIGN KEY (`cpf`) REFERENCES `pessoa` (`cpf`);

ALTER TABLE `aluno` ADD FOREIGN KEY (`cpf`) REFERENCES `pessoa` (`cpf`);

ALTER TABLE `endereco` ADD FOREIGN KEY (`cpf`) REFERENCES `pessoa` (`cpf`);

ALTER TABLE `funcionario` ADD FOREIGN KEY (`cpf`) REFERENCES `pessoa` (`cpf`);

ALTER TABLE `email` ADD FOREIGN KEY (`cpf`) REFERENCES `pessoa` (`cpf`);

ALTER TABLE `func_cargo` ADD FOREIGN KEY (`n_contratacao`) REFERENCES `funcionario` (`n_contratacao`);

ALTER TABLE `func_cargo` ADD FOREIGN KEY (`id_cargo`) REFERENCES `cargo` (`id_cargo`);

ALTER TABLE `turma` ADD FOREIGN KEY (`id_unidade`) REFERENCES `unidade` (`id_unidade`);

ALTER TABLE `matricula` ADD FOREIGN KEY (`ra`) REFERENCES `aluno` (`ra`);

ALTER TABLE `matricula` ADD FOREIGN KEY (`id_turma`) REFERENCES `turma` (`id_turma`);

ALTER TABLE `grade_horaria` ADD FOREIGN KEY (`id_turma`) REFERENCES `turma` (`id_turma`);

ALTER TABLE `disciplina` ADD FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id_curso`);

ALTER TABLE `turma` ADD FOREIGN KEY (`id_disciplina`) REFERENCES `disciplina` (`id_disciplina`);

ALTER TABLE `turma` ADD FOREIGN KEY (`n_contratacao`) REFERENCES `funcionario` (`n_contratacao`);

ALTER TABLE `turma` ADD FOREIGN KEY (`id_curso`) REFERENCES `disciplina` (`id_curso`);
