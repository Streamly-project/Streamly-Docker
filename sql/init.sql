-- Crée un admin par défaut si absent
INSERT INTO "User" (username, password, role)
SELECT 'admin', 'admin', 'ADMIN'::"Role"
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE username = 'admin');
