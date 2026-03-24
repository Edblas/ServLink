INSERT INTO categorias (nome, ativo)
SELECT 'Mecânico', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Mecânico'));

INSERT INTO categorias (nome, ativo)
SELECT 'Programador', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Programador'));

INSERT INTO categorias (nome, ativo)
SELECT 'Professor', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Professor'));

INSERT INTO categorias (nome, ativo)
SELECT 'Manicure', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Manicure'));

INSERT INTO categorias (nome, ativo)
SELECT 'Contador', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Contador'));

INSERT INTO categorias (nome, ativo)
SELECT 'Cozinheiro(a)', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Cozinheiro(a)'));

INSERT INTO categorias (nome, ativo)
SELECT 'Dentista', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Dentista'));

INSERT INTO categorias (nome, ativo)
SELECT 'Médico', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Médico'));

INSERT INTO categorias (nome, ativo)
SELECT 'Enfermeiro', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Enfermeiro'));

INSERT INTO categorias (nome, ativo)
SELECT 'Babá', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Babá'));

INSERT INTO categorias (nome, ativo)
SELECT 'Eletricista', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Eletricista'));

INSERT INTO categorias (nome, ativo)
SELECT 'Encanador', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Encanador'));

INSERT INTO categorias (nome, ativo)
SELECT 'Pedreiro', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Pedreiro'));

INSERT INTO categorias (nome, ativo)
SELECT 'Jardineiro', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Jardineiro'));

INSERT INTO categorias (nome, ativo)
SELECT 'Designer', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Designer'));

INSERT INTO categorias (nome, ativo)
SELECT 'Fotógrafo', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Fotógrafo'));

INSERT INTO categorias (nome, ativo)
SELECT 'Motorista', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Motorista'));

INSERT INTO categorias (nome, ativo)
SELECT 'Pintor', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Pintor'));

INSERT INTO categorias (nome, ativo)
SELECT 'Personal Trainer', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Personal Trainer'));

INSERT INTO categorias (nome, ativo)
SELECT 'Faxineira', TRUE
WHERE NOT EXISTS (SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Faxineira'));
