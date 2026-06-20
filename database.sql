CREATE DATABASE IF NOT EXISTS karaoke_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE karaoke_db;

DROP TABLE IF EXISTS playlist_songs;
DROP TABLE IF EXISTS search_history;
DROP TABLE IF EXISTS playlists;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(64) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'USER')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE songs (
    id VARCHAR(30) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist VARCHAR(255) NOT NULL,
    genre VARCHAR(100) NOT NULL
);

CREATE TABLE playlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_playlists_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE TABLE playlist_songs (
    playlist_id INT NOT NULL,
    song_id VARCHAR(30) NOT NULL,
    PRIMARY KEY (playlist_id, song_id),
    CONSTRAINT fk_playlist_songs_playlist
        FOREIGN KEY (playlist_id) REFERENCES playlists(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_playlist_songs_song
        FOREIGN KEY (song_id) REFERENCES songs(id)
        ON DELETE CASCADE
);

CREATE TABLE search_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    keyword VARCHAR(255) NOT NULL,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
);

-- Tài khoản mẫu:
-- admin / admin123
-- user  / user123
INSERT INTO users(username, password_hash, role) VALUES
('admin', SHA2('admin123', 256), 'ADMIN'),
('user',  SHA2('user123', 256),  'USER');

INSERT INTO songs(id, title, artist, genre) VALUES
('S001', 'Nơi này có anh', 'Sơn Tùng M-TP', 'Pop'),
('S002', 'Chúng ta của tương lai', 'Sơn Tùng M-TP', 'Pop'),
('S003', 'Em của ngày hôm qua', 'Sơn Tùng M-TP', 'Pop'),
('S004', 'Sóng gió', 'Jack, K-ICM', 'Ballad'),
('S005', 'Bạc phận', 'Jack, K-ICM', 'Ballad'),
('S006', 'Có chắc yêu là đây', 'Sơn Tùng M-TP', 'Pop'),
('S007', 'Một bước yêu vạn dặm đau', 'Mr. Siro', 'Ballad'),
('S008', 'Anh nhớ em người yêu cũ', 'Minh Vương M4U', 'Ballad');
