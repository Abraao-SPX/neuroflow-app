CREATE DATABASE IF NOT EXISTS neuroflow_db;
USE neuroflow_db;

CREATE TABLE IF NOT EXISTS Usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Tarefas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    concluida TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Gatilhos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    icone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Registros_Diarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nivel_bateria INT NOT NULL,
    observacao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Registros_Gatilhos (
    registro_id INT NOT NULL,
    gatilho_id INT NOT NULL,        
    PRIMARY KEY (registro_id, gatilho_id),
    FOREIGN KEY (registro_id) REFERENCES Registros_Diarios(id) ON DELETE CASCADE,
    FOREIGN KEY (gatilho_id) REFERENCES Gatilhos(id) ON DELETE CASCADE
);

INSERT INTO Gatilhos (nome, icone) VALUES 
('Barulho','volume_up'),
('Luz Forte','wb_sunny'),
('Multidão','groups'),
('Conversas','forum'),
('Toque fisico','front_hand'),
('Cheiros','air'),
('Calor','thermostat'),
('Vibração','vibration');
