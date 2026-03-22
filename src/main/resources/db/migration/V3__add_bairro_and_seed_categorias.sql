ALTER TABLE profissionais
    ADD COLUMN IF NOT EXISTS bairro VARCHAR(255);

INSERT INTO categorias (ativo, data_criacao, data_atualizacao, nome, descricao)
SELECT TRUE, NOW(), NOW(), v.nome, NULL
FROM (VALUES
    ('Diarista'),
    ('Pedreiro'),
    ('Eletricista'),
    ('Encanador'),
    ('Motoboy')
) AS v(nome)
WHERE NOT EXISTS (
    SELECT 1 FROM categorias c WHERE LOWER(c.nome) = LOWER(v.nome)
);
