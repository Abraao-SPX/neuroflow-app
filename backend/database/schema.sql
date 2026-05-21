CREATE DATABASE IF NOT EXISTS neuroflow_db;
USE neuroflow_db;

CREATE TABLE IF NOT EXISTS Usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(254) UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    reset_token VARCHAR(255) DEFAULT NULL,
    reset_token_expires DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Tarefas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    concluida TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX tarefas_usuario_id_idx (usuario_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS RefreshTokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    revoked_at DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX refresh_tokens_usuario_id_idx (usuario_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS checkins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    humor VARCHAR(50) NOT NULL,
    outro_incomodo TEXT,
    data_checkin DATE NOT NULL DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX checkins_usuario_id_idx (usuario_id),
    INDEX checkins_usuario_data_idx (usuario_id, data_checkin),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Gatilhos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    icone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS CheckinGatilhos (
    checkin_id INT NOT NULL,
    gatilho_id INT NOT NULL,
    PRIMARY KEY (checkin_id, gatilho_id),
    INDEX checkin_gatilhos_gatilho_id_idx (gatilho_id),
    FOREIGN KEY (checkin_id) REFERENCES checkins(id) ON DELETE CASCADE,
    FOREIGN KEY (gatilho_id) REFERENCES Gatilhos(id) ON DELETE CASCADE
);

INSERT IGNORE INTO Gatilhos (nome, icone) VALUES
('Luz do dia excessiva','wb_sunny_outlined'),
('Ruídos e Barulhos','volume_up_outlined'),
('Excesso de tarefas','assignment_outlined'),
('Toques indesejados','front_hand_outlined'),
('Dificuldade de concentração','psychology_outlined'),
('Barulho','volume_up'),
('Luz Forte','wb_sunny'),
('Multidão','groups'),
('Conversas','forum'),
('Cheiros','air'),
('Calor','thermostat'),
('Vibração','vibration');
