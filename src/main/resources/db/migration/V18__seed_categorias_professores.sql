INSERT INTO categorias (nome, ativo)
SELECT v.nome, TRUE
FROM (VALUES
    ('Professor(a) particular')
) AS v(nome)
WHERE NOT EXISTS (
    SELECT 1 FROM categorias c WHERE LOWER(c.nome) = LOWER(v.nome)
);
