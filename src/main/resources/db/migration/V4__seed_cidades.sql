INSERT INTO cidades (ativo, data_criacao, data_atualizacao, nome, estado)
SELECT TRUE, NOW(), NOW(), v.nome, v.estado
FROM (VALUES
    ('Alfenas', 'MG'),
    ('Belo Horizonte', 'MG'),
    ('São Paulo', 'SP')
) AS v(nome, estado)
WHERE NOT EXISTS (
    SELECT 1 FROM cidades c
    WHERE LOWER(c.nome) = LOWER(v.nome)
      AND LOWER(c.estado) = LOWER(v.estado)
);
