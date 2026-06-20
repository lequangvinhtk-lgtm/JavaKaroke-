#!/usr/bin/env bash
set -e
echo "Dang ghi full code Karaoke vao project hien tai..."
cat > 'pom.xml' <<'EOF_KARAOKE'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.vku</groupId>
    <artifactId>JavaFxCuoiKyKaraoke</artifactId>
    <version>1.0-SNAPSHOT</version>
    <name>JavaFX Karaoke Management</name>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <javafx.version>21.0.6</javafx.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.openjfx</groupId>
            <artifactId>javafx-controls</artifactId>
            <version>${javafx.version}</version>
        </dependency>

        <dependency>
            <groupId>org.openjfx</groupId>
            <artifactId>javafx-fxml</artifactId>
            <version>${javafx.version}</version>
        </dependency>

        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <version>8.3.0</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.openjfx</groupId>
                <artifactId>javafx-maven-plugin</artifactId>
                <version>0.0.8</version>
                <configuration>
                    <mainClass>com.vku.karaoke.client.Launcher</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF_KARAOKE

cat > 'database.sql' <<'EOF_KARAOKE'
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
EOF_KARAOKE

cat > 'config.xml' <<'EOF_KARAOKE'
<?xml version="1.0" encoding="UTF-8"?>
<config>
    <serverHost>localhost</serverHost>
    <serverPort>9999</serverPort>

    <dbHost>localhost</dbHost>
    <dbPort>3306</dbPort>
    <dbName>karaoke_db</dbName>
    <dbUser>root</dbUser>
    <dbPassword>Admin@123</dbPassword>
</config>
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/model'
cat > 'src/main/java/com/vku/karaoke/model/Song.java' <<'EOF_KARAOKE'
package com.vku.karaoke.model;

import java.io.Serializable;

public class Song implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;
    private String title;
    private String artist;
    private String genre;

    public Song() {
    }

    public Song(String id, String title, String artist, String genre) {
        this.id = id;
        this.title = title;
        this.artist = artist;
        this.genre = genre;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    @Override
    public String toString() {
        return id + " - " + title + " - " + artist + " - " + genre;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/model'
cat > 'src/main/java/com/vku/karaoke/model/User.java' <<'EOF_KARAOKE'
package com.vku.karaoke.model;

import java.io.Serializable;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String username;
    private String role;

    public User() {
    }

    public User(int id, String username, String role) {
        this.id = id;
        this.username = username;
        this.role = role;
    }

    public int getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getRole() {
        return role;
    }

    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(role);
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/model'
cat > 'src/main/java/com/vku/karaoke/model/Playlist.java' <<'EOF_KARAOKE'
package com.vku.karaoke.model;

import java.io.Serializable;

public class Playlist implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String name;
    private String createdAt;

    public Playlist() {
    }

    public Playlist(int id, int userId, String name, String createdAt) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public int getUserId() {
        return userId;
    }

    public String getName() {
        return name;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    @Override
    public String toString() {
        return name + " (#" + id + ")";
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/model'
cat > 'src/main/java/com/vku/karaoke/model/SearchHistory.java' <<'EOF_KARAOKE'
package com.vku.karaoke.model;

import java.io.Serializable;

public class SearchHistory implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String keyword;
    private String searchedAt;

    public SearchHistory() {
    }

    public SearchHistory(int id, int userId, String keyword, String searchedAt) {
        this.id = id;
        this.userId = userId;
        this.keyword = keyword;
        this.searchedAt = searchedAt;
    }

    public int getId() {
        return id;
    }

    public int getUserId() {
        return userId;
    }

    public String getKeyword() {
        return keyword;
    }

    public String getSearchedAt() {
        return searchedAt;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/model'
cat > 'src/main/java/com/vku/karaoke/model/SystemConfig.java' <<'EOF_KARAOKE'
package com.vku.karaoke.model;

public class SystemConfig {
    private String serverHost;
    private int serverPort;
    private String dbHost;
    private int dbPort;
    private String dbName;
    private String dbUser;
    private String dbPassword;

    public SystemConfig() {
    }

    public SystemConfig(String serverHost, int serverPort, String dbHost, int dbPort,
                        String dbName, String dbUser, String dbPassword) {
        this.serverHost = serverHost;
        this.serverPort = serverPort;
        this.dbHost = dbHost;
        this.dbPort = dbPort;
        this.dbName = dbName;
        this.dbUser = dbUser;
        this.dbPassword = dbPassword;
    }

    public static SystemConfig defaultConfig() {
        return new SystemConfig(
                "localhost",
                9999,
                "localhost",
                3306,
                "karaoke_db",
                "root",
                "Admin@123"
        );
    }

    public String getServerHost() {
        return serverHost;
    }

    public int getServerPort() {
        return serverPort;
    }

    public String getDbHost() {
        return dbHost;
    }

    public int getDbPort() {
        return dbPort;
    }

    public String getDbName() {
        return dbName;
    }

    public String getDbUser() {
        return dbUser;
    }

    public String getDbPassword() {
        return dbPassword;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/model'
cat > 'src/main/java/com/vku/karaoke/model/Request.java' <<'EOF_KARAOKE'
package com.vku.karaoke.model;

import java.io.Serializable;

public class Request implements Serializable {
    private static final long serialVersionUID = 1L;

    private String command;
    private Object data;

    public Request() {
    }

    public Request(String command) {
        this.command = command;
    }

    public Request(String command, Object data) {
        this.command = command;
        this.data = data;
    }

    public String getCommand() {
        return command;
    }

    public Object getData() {
        return data;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/model'
cat > 'src/main/java/com/vku/karaoke/model/Response.java' <<'EOF_KARAOKE'
package com.vku.karaoke.model;

import java.io.Serializable;

public class Response implements Serializable {
    private static final long serialVersionUID = 1L;

    private boolean success;
    private String message;
    private Object data;

    public Response() {
    }

    public Response(boolean success, String message, Object data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }

    public static Response ok(String message) {
        return new Response(true, message, null);
    }

    public static Response ok(String message, Object data) {
        return new Response(true, message, data);
    }

    public static Response fail(String message) {
        return new Response(false, message, null);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public Object getData() {
        return data;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/utils'
cat > 'src/main/java/com/vku/karaoke/utils/PasswordUtil.java' <<'EOF_KARAOKE'
package com.vku.karaoke.utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class PasswordUtil {
    private PasswordUtil() {
    }

    public static String sha256(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encoded = digest.digest(password.getBytes(StandardCharsets.UTF_8));

            StringBuilder sb = new StringBuilder();
            for (byte b : encoded) {
                sb.append(String.format("%02x", b));
            }

            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Không thể mã hóa mật khẩu SHA-256", e);
        }
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/utils'
cat > 'src/main/java/com/vku/karaoke/utils/ConfigXMLUtil.java' <<'EOF_KARAOKE'
package com.vku.karaoke.utils;

import com.vku.karaoke.model.SystemConfig;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.File;

public class ConfigXMLUtil {
    private static final String CONFIG_FILE = "config.xml";

    private ConfigXMLUtil() {
    }

    public static SystemConfig loadConfig() {
        try {
            File file = new File(CONFIG_FILE);
            if (!file.exists()) {
                SystemConfig config = SystemConfig.defaultConfig();
                saveConfig(config);
                return config;
            }

            Document doc = DocumentBuilderFactory.newInstance()
                    .newDocumentBuilder()
                    .parse(file);

            doc.getDocumentElement().normalize();

            return new SystemConfig(
                    getText(doc, "serverHost", "localhost"),
                    Integer.parseInt(getText(doc, "serverPort", "9999")),
                    getText(doc, "dbHost", "localhost"),
                    Integer.parseInt(getText(doc, "dbPort", "3306")),
                    getText(doc, "dbName", "karaoke_db"),
                    getText(doc, "dbUser", "root"),
                    getText(doc, "dbPassword", "Admin@123")
            );
        } catch (Exception e) {
            System.err.println("Không đọc được config.xml, dùng cấu hình mặc định: " + e.getMessage());
            return SystemConfig.defaultConfig();
        }
    }

    public static void saveConfig(SystemConfig config) {
        try {
            Document doc = DocumentBuilderFactory.newInstance()
                    .newDocumentBuilder()
                    .newDocument();

            Element root = doc.createElement("config");
            doc.appendChild(root);

            append(doc, root, "serverHost", config.getServerHost());
            append(doc, root, "serverPort", String.valueOf(config.getServerPort()));
            append(doc, root, "dbHost", config.getDbHost());
            append(doc, root, "dbPort", String.valueOf(config.getDbPort()));
            append(doc, root, "dbName", config.getDbName());
            append(doc, root, "dbUser", config.getDbUser());
            append(doc, root, "dbPassword", config.getDbPassword());

            javax.xml.transform.Transformer transformer =
                    TransformerFactory.newInstance().newTransformer();

            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");

            transformer.transform(new DOMSource(doc), new StreamResult(new File(CONFIG_FILE)));
        } catch (Exception e) {
            throw new RuntimeException("Không ghi được file config.xml", e);
        }
    }

    private static String getText(Document doc, String tag, String defaultValue) {
        if (doc.getElementsByTagName(tag).getLength() == 0) {
            return defaultValue;
        }

        String value = doc.getElementsByTagName(tag).item(0).getTextContent();
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }

        return value.trim();
    }

    private static void append(Document doc, Element root, String tag, String value) {
        Element element = doc.createElement(tag);
        element.appendChild(doc.createTextNode(value));
        root.appendChild(element);
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/utils'
cat > 'src/main/java/com/vku/karaoke/utils/DBUtil.java' <<'EOF_KARAOKE'
package com.vku.karaoke.utils;

import com.vku.karaoke.model.SystemConfig;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private DBUtil() {
    }

    public static Connection getConnection() throws SQLException {
        SystemConfig config = ConfigXMLUtil.loadConfig();

        String url = "jdbc:mysql://" + config.getDbHost() + ":" + config.getDbPort()
                + "/" + config.getDbName()
                + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
                + "&characterEncoding=utf8";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Chưa có thư viện mysql-connector-j trong pom.xml", e);
        }

        return DriverManager.getConnection(url, config.getDbUser(), config.getDbPassword());
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/utils'
cat > 'src/main/java/com/vku/karaoke/utils/FileIOUtil.java' <<'EOF_KARAOKE'
package com.vku.karaoke.utils;

import com.vku.karaoke.model.Song;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class FileIOUtil {
    private FileIOUtil() {
    }

    public static void saveSongsToTxt(List<Song> songs, String filePath) throws Exception {
        Path path = Path.of(filePath);

        try (BufferedWriter writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
            for (Song song : songs) {
                writer.write(song.getId() + "|" + song.getTitle() + "|" + song.getArtist() + "|" + song.getGenre());
                writer.newLine();
            }
        }
    }

    public static List<Song> loadSongsFromTxt(String filePath) throws Exception {
        List<Song> songs = new ArrayList<>();
        Path path = Path.of(filePath);

        if (!Files.exists(path)) {
            return songs;
        }

        try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            String line;

            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|", -1);

                if (parts.length == 4) {
                    songs.add(new Song(
                            parts[0].trim(),
                            parts[1].trim(),
                            parts[2].trim(),
                            parts[3].trim()
                    ));
                }
            }
        }

        return songs;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/utils'
cat > 'src/main/java/com/vku/karaoke/utils/XMLUtil.java' <<'EOF_KARAOKE'
package com.vku.karaoke.utils;

import com.vku.karaoke.model.Song;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.File;
import java.util.List;

public class XMLUtil {
    private XMLUtil() {
    }

    public static void exportSongsToXML(List<Song> songs, String filePath) throws Exception {
        Document doc = DocumentBuilderFactory.newInstance()
                .newDocumentBuilder()
                .newDocument();

        Element root = doc.createElement("karaokeSongs");
        doc.appendChild(root);

        for (Song song : songs) {
            Element songNode = doc.createElement("song");
            songNode.setAttribute("id", song.getId());

            append(doc, songNode, "title", song.getTitle());
            append(doc, songNode, "artist", song.getArtist());
            append(doc, songNode, "genre", song.getGenre());

            root.appendChild(songNode);
        }

        javax.xml.transform.Transformer transformer =
                TransformerFactory.newInstance().newTransformer();

        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");

        transformer.transform(new DOMSource(doc), new StreamResult(new File(filePath)));
    }

    private static void append(Document doc, Element parent, String tag, String value) {
        Element element = doc.createElement(tag);
        element.appendChild(doc.createTextNode(value == null ? "" : value));
        parent.appendChild(element);
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/server/dao'
cat > 'src/main/java/com/vku/karaoke/server/dao/UserDAO.java' <<'EOF_KARAOKE'
package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.User;
import com.vku.karaoke.utils.DBUtil;
import com.vku.karaoke.utils.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {
    public User authenticate(String username, String password) throws Exception {
        String sql = "SELECT id, username, role FROM users WHERE username = ? AND password_hash = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, PasswordUtil.sha256(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("role")
                    );
                }
            }
        }

        return null;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/server/dao'
cat > 'src/main/java/com/vku/karaoke/server/dao/SongDAO.java' <<'EOF_KARAOKE'
package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.Song;
import com.vku.karaoke.utils.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SongDAO {
    public List<Song> getAllSongs() throws Exception {
        List<Song> songs = new ArrayList<>();
        String sql = "SELECT id, title, artist, genre FROM songs ORDER BY id";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                songs.add(mapSong(rs));
            }
        }

        return songs;
    }

    public List<Song> searchSongs(String keyword) throws Exception {
        List<Song> songs = new ArrayList<>();
        String sql = """
                SELECT id, title, artist, genre
                FROM songs
                WHERE id LIKE ? OR title LIKE ? OR artist LIKE ? OR genre LIKE ?
                ORDER BY title
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    songs.add(mapSong(rs));
                }
            }
        }

        return songs;
    }

    public boolean addSong(Song song) throws Exception {
        String sql = "INSERT INTO songs(id, title, artist, genre) VALUES (?, ?, ?, ?)";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            fillSongParams(ps, song);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateSong(Song song) throws Exception {
        String sql = "UPDATE songs SET title = ?, artist = ?, genre = ? WHERE id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, song.getTitle());
            ps.setString(2, song.getArtist());
            ps.setString(3, song.getGenre());
            ps.setString(4, song.getId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean upsertSong(Song song) throws Exception {
        String sql = """
                INSERT INTO songs(id, title, artist, genre)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    title = VALUES(title),
                    artist = VALUES(artist),
                    genre = VALUES(genre)
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            fillSongParams(ps, song);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteSong(String id) throws Exception {
        String sql = "DELETE FROM songs WHERE id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private void fillSongParams(PreparedStatement ps, Song song) throws Exception {
        ps.setString(1, song.getId());
        ps.setString(2, song.getTitle());
        ps.setString(3, song.getArtist());
        ps.setString(4, song.getGenre());
    }

    private Song mapSong(ResultSet rs) throws Exception {
        return new Song(
                rs.getString("id"),
                rs.getString("title"),
                rs.getString("artist"),
                rs.getString("genre")
        );
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/server/dao'
cat > 'src/main/java/com/vku/karaoke/server/dao/PlaylistDAO.java' <<'EOF_KARAOKE'
package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.Playlist;
import com.vku.karaoke.model.Song;
import com.vku.karaoke.utils.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PlaylistDAO {
    public List<Playlist> findByUser(int userId) throws Exception {
        List<Playlist> playlists = new ArrayList<>();
        String sql = "SELECT id, user_id, name, created_at FROM playlists WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    playlists.add(new Playlist(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getString("name"),
                            String.valueOf(rs.getTimestamp("created_at"))
                    ));
                }
            }
        }

        return playlists;
    }

    public boolean createPlaylist(int userId, String name) throws Exception {
        String sql = "INSERT INTO playlists(user_id, name) VALUES (?, ?)";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, name);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deletePlaylist(int userId, int playlistId) throws Exception {
        String sql = "DELETE FROM playlists WHERE id = ? AND user_id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, playlistId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean addSongToPlaylist(int userId, int playlistId, String songId) throws Exception {
        String sql = """
                INSERT IGNORE INTO playlist_songs(playlist_id, song_id)
                SELECT id, ?
                FROM playlists
                WHERE id = ? AND user_id = ?
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, songId);
            ps.setInt(2, playlistId);
            ps.setInt(3, userId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean removeSongFromPlaylist(int userId, int playlistId, String songId) throws Exception {
        String sql = """
                DELETE ps
                FROM playlist_songs ps
                JOIN playlists p ON ps.playlist_id = p.id
                WHERE ps.playlist_id = ?
                  AND p.user_id = ?
                  AND ps.song_id = ?
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, playlistId);
            ps.setInt(2, userId);
            ps.setString(3, songId);

            return ps.executeUpdate() > 0;
        }
    }

    public List<Song> getSongsInPlaylist(int userId, int playlistId) throws Exception {
        List<Song> songs = new ArrayList<>();
        String sql = """
                SELECT s.id, s.title, s.artist, s.genre
                FROM songs s
                JOIN playlist_songs ps ON s.id = ps.song_id
                JOIN playlists p ON ps.playlist_id = p.id
                WHERE p.id = ? AND p.user_id = ?
                ORDER BY s.title
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, playlistId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    songs.add(new Song(
                            rs.getString("id"),
                            rs.getString("title"),
                            rs.getString("artist"),
                            rs.getString("genre")
                    ));
                }
            }
        }

        return songs;
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/server/dao'
cat > 'src/main/java/com/vku/karaoke/server/dao/SearchHistoryDAO.java' <<'EOF_KARAOKE'
package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.SearchHistory;
import com.vku.karaoke.utils.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SearchHistoryDAO {
    public void saveKeyword(int userId, String keyword) throws Exception {
        if (keyword == null || keyword.trim().isEmpty()) {
            return;
        }

        String sql = "INSERT INTO search_history(user_id, keyword) VALUES (?, ?)";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, keyword.trim());
            ps.executeUpdate();
        }
    }

    public List<SearchHistory> findByUser(int userId) throws Exception {
        List<SearchHistory> historyList = new ArrayList<>();
        String sql = """
                SELECT id, user_id, keyword, searched_at
                FROM search_history
                WHERE user_id = ?
                ORDER BY searched_at DESC
                LIMIT 100
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    historyList.add(new SearchHistory(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getString("keyword"),
                            String.valueOf(rs.getTimestamp("searched_at"))
                    ));
                }
            }
        }

        return historyList;
    }

    public boolean clearByUser(int userId) throws Exception {
        String sql = "DELETE FROM search_history WHERE user_id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
            return true;
        }
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/server'
cat > 'src/main/java/com/vku/karaoke/server/MainServer.java' <<'EOF_KARAOKE'
package com.vku.karaoke.server;

import com.vku.karaoke.model.SystemConfig;
import com.vku.karaoke.server.network.ClientHandler;
import com.vku.karaoke.utils.ConfigXMLUtil;

import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainServer {
    public static void main(String[] args) {
        SystemConfig config = ConfigXMLUtil.loadConfig();
        ExecutorService pool = Executors.newCachedThreadPool();

        try (ServerSocket serverSocket = new ServerSocket(config.getServerPort())) {
            System.out.println("=================================================");
            System.out.println(" KARAOKE SERVER ĐANG CHẠY Ở PORT: " + config.getServerPort());
            System.out.println(" Mỗi client sẽ được xử lý bằng một luồng riêng.");
            System.out.println("=================================================");

            while (true) {
                Socket socket = serverSocket.accept();
                System.out.println("[CONNECT] Client mới: " + socket.getInetAddress());
                pool.execute(new ClientHandler(socket));
            }
        } catch (Exception e) {
            System.err.println("[SERVER ERROR] Không thể khởi động server: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/server/network'
cat > 'src/main/java/com/vku/karaoke/server/network/ClientHandler.java' <<'EOF_KARAOKE'
package com.vku.karaoke.server.network;

import com.vku.karaoke.model.Request;
import com.vku.karaoke.model.Response;
import com.vku.karaoke.model.Song;
import com.vku.karaoke.model.User;
import com.vku.karaoke.server.dao.PlaylistDAO;
import com.vku.karaoke.server.dao.SearchHistoryDAO;
import com.vku.karaoke.server.dao.SongDAO;
import com.vku.karaoke.server.dao.UserDAO;
import com.vku.karaoke.utils.FileIOUtil;
import com.vku.karaoke.utils.XMLUtil;

import java.io.EOFException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.util.List;

public class ClientHandler implements Runnable {
    private final Socket socket;
    private ObjectOutputStream out;
    private ObjectInputStream in;

    private final UserDAO userDAO = new UserDAO();
    private final SongDAO songDAO = new SongDAO();
    private final PlaylistDAO playlistDAO = new PlaylistDAO();
    private final SearchHistoryDAO historyDAO = new SearchHistoryDAO();

    private User currentUser;

    public ClientHandler(Socket socket) {
        this.socket = socket;
    }

    @Override
    public void run() {
        try {
            out = new ObjectOutputStream(socket.getOutputStream());
            out.flush();
            in = new ObjectInputStream(socket.getInputStream());

            while (true) {
                Object object = in.readObject();

                if (!(object instanceof Request)) {
                    write(Response.fail("Gói tin gửi lên không đúng định dạng Request"));
                    continue;
                }

                Request request = (Request) object;
                Response response = handleRequest(request);
                write(response);
            }
        } catch (EOFException e) {
            System.out.println("[DISCONNECT] Client đã thoát.");
        } catch (Exception e) {
            System.err.println("[CLIENT ERROR] " + e.getMessage());
        } finally {
            close();
        }
    }

    private Response handleRequest(Request request) {
        try {
            String command = request.getCommand();

            if ("LOGIN".equals(command)) {
                return handleLogin(request);
            }

            if (currentUser == null) {
                return Response.fail("Bạn phải đăng nhập trước khi sử dụng hệ thống.");
            }

            switch (command) {
                case "GET_ALL":
                    return Response.ok("Lấy danh sách bài hát thành công", songDAO.getAllSongs());

                case "SEARCH":
                    String keyword = String.valueOf(request.getData()).trim();
                    historyDAO.saveKeyword(currentUser.getId(), keyword);
                    return Response.ok("Tìm kiếm thành công", songDAO.searchSongs(keyword));

                case "ADD":
                    requireAdmin();
                    return Response.ok("Thêm bài hát thành công", songDAO.addSong((Song) request.getData()));

                case "UPDATE":
                    requireAdmin();
                    return Response.ok("Cập nhật bài hát thành công", songDAO.updateSong((Song) request.getData()));

                case "DELETE":
                    requireAdmin();
                    return Response.ok("Xóa bài hát thành công", songDAO.deleteSong(String.valueOf(request.getData())));

                case "EXPORT_TXT":
                    FileIOUtil.saveSongsToTxt(songDAO.getAllSongs(), "backup_songs.txt");
                    return Response.ok("Đã xuất file backup_songs.txt");

                case "IMPORT_TXT":
                    requireAdmin();
                    List<Song> importedSongs = FileIOUtil.loadSongsFromTxt("backup_songs.txt");
                    for (Song song : importedSongs) {
                        songDAO.upsertSong(song);
                    }
                    return Response.ok("Đã nhập " + importedSongs.size() + " bài hát từ backup_songs.txt");

                case "EXPORT_XML":
                    XMLUtil.exportSongsToXML(songDAO.getAllSongs(), "backup_songs.xml");
                    return Response.ok("Đã xuất file backup_songs.xml");

                case "GET_HISTORY":
                    return Response.ok("Lấy lịch sử tìm kiếm thành công",
                            historyDAO.findByUser(currentUser.getId()));

                case "CLEAR_HISTORY":
                    historyDAO.clearByUser(currentUser.getId());
                    return Response.ok("Đã xóa lịch sử tìm kiếm");

                case "PLAYLISTS":
                    return Response.ok("Lấy playlist thành công",
                            playlistDAO.findByUser(currentUser.getId()));

                case "PLAYLIST_CREATE":
                    return Response.ok("Tạo playlist thành công",
                            playlistDAO.createPlaylist(currentUser.getId(), String.valueOf(request.getData())));

                case "PLAYLIST_DELETE":
                    return Response.ok("Xóa playlist thành công",
                            playlistDAO.deletePlaylist(currentUser.getId(), (Integer) request.getData()));

                case "PLAYLIST_ADD_SONG": {
                    String[] parts = String.valueOf(request.getData()).split("\\|", -1);
                    int playlistId = Integer.parseInt(parts[0]);
                    String songId = parts[1];
                    return Response.ok("Đã thêm bài hát vào playlist",
                            playlistDAO.addSongToPlaylist(currentUser.getId(), playlistId, songId));
                }

                case "PLAYLIST_REMOVE_SONG": {
                    String[] parts = String.valueOf(request.getData()).split("\\|", -1);
                    int playlistId = Integer.parseInt(parts[0]);
                    String songId = parts[1];
                    return Response.ok("Đã xóa bài hát khỏi playlist",
                            playlistDAO.removeSongFromPlaylist(currentUser.getId(), playlistId, songId));
                }

                case "PLAYLIST_SONGS":
                    return Response.ok("Lấy bài hát trong playlist thành công",
                            playlistDAO.getSongsInPlaylist(currentUser.getId(), (Integer) request.getData()));

                default:
                    return Response.fail("Lệnh không tồn tại: " + command);
            }
        } catch (SecurityException e) {
            return Response.fail(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return Response.fail("Server xử lý lỗi: " + e.getMessage());
        }
    }

    private Response handleLogin(Request request) throws Exception {
        String[] data = (String[]) request.getData();

        if (data.length < 2) {
            return Response.fail("Thiếu username hoặc password");
        }

        User user = userDAO.authenticate(data[0], data[1]);

        if (user == null) {
            return Response.fail("Sai tài khoản hoặc mật khẩu");
        }

        this.currentUser = user;
        return Response.ok("Đăng nhập thành công", user);
    }

    private void requireAdmin() {
        if (currentUser == null || !currentUser.isAdmin()) {
            throw new SecurityException("Bạn không có quyền ADMIN để thực hiện chức năng này.");
        }
    }

    private void write(Response response) throws Exception {
        out.writeObject(response);
        out.flush();
        out.reset();
    }

    private void close() {
        try {
            if (in != null) {
                in.close();
            }
        } catch (Exception ignored) {
        }

        try {
            if (out != null) {
                out.close();
            }
        } catch (Exception ignored) {
        }

        try {
            socket.close();
        } catch (Exception ignored) {
        }
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/client'
cat > 'src/main/java/com/vku/karaoke/client/Launcher.java' <<'EOF_KARAOKE'
package com.vku.karaoke.client;

public class Launcher {
    public static void main(String[] args) {
        MainClientApp.main(args);
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/client'
cat > 'src/main/java/com/vku/karaoke/client/MainClientApp.java' <<'EOF_KARAOKE'
package com.vku.karaoke.client;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class MainClientApp extends Application {
    @Override
    public void start(Stage stage) throws Exception {
        FXMLLoader loader = new FXMLLoader(MainClientApp.class.getResource("/login.fxml"));

        Scene scene = new Scene(loader.load(), 430, 330);
        scene.getStylesheets().add(MainClientApp.class.getResource("/style.css").toExternalForm());

        stage.setTitle("Đăng nhập hệ thống Karaoke");
        stage.setScene(scene);
        stage.centerOnScreen();
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/client/network'
cat > 'src/main/java/com/vku/karaoke/client/network/ClientConnection.java' <<'EOF_KARAOKE'
package com.vku.karaoke.client.network;

import com.vku.karaoke.model.Request;
import com.vku.karaoke.model.Response;
import com.vku.karaoke.model.SystemConfig;
import com.vku.karaoke.utils.ConfigXMLUtil;

import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

public class ClientConnection {
    private final Socket socket;
    private final ObjectOutputStream out;
    private final ObjectInputStream in;

    public ClientConnection() throws Exception {
        SystemConfig config = ConfigXMLUtil.loadConfig();

        socket = new Socket(config.getServerHost(), config.getServerPort());
        out = new ObjectOutputStream(socket.getOutputStream());
        out.flush();
        in = new ObjectInputStream(socket.getInputStream());
    }

    public synchronized Response send(Request request) throws Exception {
        out.writeObject(request);
        out.flush();
        out.reset();

        Object response = in.readObject();

        if (!(response instanceof Response)) {
            throw new IllegalStateException("Server trả về dữ liệu không đúng định dạng Response");
        }

        return (Response) response;
    }

    public void close() {
        try {
            in.close();
        } catch (Exception ignored) {
        }

        try {
            out.close();
        } catch (Exception ignored) {
        }

        try {
            socket.close();
        } catch (Exception ignored) {
        }
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/client/controller'
cat > 'src/main/java/com/vku/karaoke/client/controller/LoginController.java' <<'EOF_KARAOKE'
package com.vku.karaoke.client.controller;

import com.vku.karaoke.client.MainClientApp;
import com.vku.karaoke.client.network.ClientConnection;
import com.vku.karaoke.model.Request;
import com.vku.karaoke.model.Response;
import com.vku.karaoke.model.User;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

public class LoginController {
    @FXML
    private TextField txtUsername;

    @FXML
    private PasswordField txtPassword;

    @FXML
    private Label lblError;

    @FXML
    void handleLogin(ActionEvent event) {
        String username = txtUsername.getText().trim();
        String password = txtPassword.getText().trim();

        if (username.isEmpty() || password.isEmpty()) {
            lblError.setText("Vui lòng nhập đầy đủ tài khoản và mật khẩu.");
            return;
        }

        ClientConnection connection = null;

        try {
            connection = new ClientConnection();

            Response response = connection.send(new Request(
                    "LOGIN",
                    new String[]{username, password}
            ));

            if (!response.isSuccess()) {
                lblError.setText(response.getMessage());
                connection.close();
                return;
            }

            User user = (User) response.getData();

            FXMLLoader loader = new FXMLLoader(MainClientApp.class.getResource("/dashboard.fxml"));
            Scene scene = new Scene(loader.load(), 1100, 720);
            scene.getStylesheets().add(MainClientApp.class.getResource("/style.css").toExternalForm());

            KaraokeDashboardController controller = loader.getController();
            controller.initUserData(connection, user);

            Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
            stage.setTitle("Hệ thống quản lý bài hát Karaoke");
            stage.setScene(scene);
            stage.centerOnScreen();
        } catch (Exception e) {
            lblError.setText("Không kết nối được Server. Hãy chạy MainServer trước.");
            if (connection != null) {
                connection.close();
            }
            e.printStackTrace();
        }
    }
}
EOF_KARAOKE

mkdir -p 'src/main/java/com/vku/karaoke/client/controller'
cat > 'src/main/java/com/vku/karaoke/client/controller/KaraokeDashboardController.java' <<'EOF_KARAOKE'
package com.vku.karaoke.client.controller;

import com.vku.karaoke.client.MainClientApp;
import com.vku.karaoke.client.network.ClientConnection;
import com.vku.karaoke.model.Playlist;
import com.vku.karaoke.model.Request;
import com.vku.karaoke.model.Response;
import com.vku.karaoke.model.SearchHistory;
import com.vku.karaoke.model.Song;
import com.vku.karaoke.model.User;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.stage.Stage;

import java.util.List;

public class KaraokeDashboardController {
    @FXML
    private Label lblWelcome;

    @FXML
    private TextField txtSearch;

    @FXML
    private TextField txtId;

    @FXML
    private TextField txtTitle;

    @FXML
    private TextField txtArtist;

    @FXML
    private TextField txtGenre;

    @FXML
    private TableView<Song> tableSongs;

    @FXML
    private TableColumn<Song, String> colId;

    @FXML
    private TableColumn<Song, String> colTitle;

    @FXML
    private TableColumn<Song, String> colArtist;

    @FXML
    private TableColumn<Song, String> colGenre;

    @FXML
    private Button btnAdd;

    @FXML
    private Button btnUpdate;

    @FXML
    private Button btnDelete;

    @FXML
    private Button btnImportTxt;

    @FXML
    private ListView<Playlist> listPlaylists;

    @FXML
    private TextField txtPlaylistName;

    @FXML
    private TableView<Song> tablePlaylistSongs;

    @FXML
    private TableColumn<Song, String> colPlId;

    @FXML
    private TableColumn<Song, String> colPlTitle;

    @FXML
    private TableColumn<Song, String> colPlArtist;

    @FXML
    private TableView<SearchHistory> tableHistory;

    @FXML
    private TableColumn<SearchHistory, String> colKeyword;

    @FXML
    private TableColumn<SearchHistory, String> colSearchedAt;

    private ClientConnection connection;
    private User currentUser;

    @FXML
    public void initialize() {
        colId.setCellValueFactory(new PropertyValueFactory<>("id"));
        colTitle.setCellValueFactory(new PropertyValueFactory<>("title"));
        colArtist.setCellValueFactory(new PropertyValueFactory<>("artist"));
        colGenre.setCellValueFactory(new PropertyValueFactory<>("genre"));

        colPlId.setCellValueFactory(new PropertyValueFactory<>("id"));
        colPlTitle.setCellValueFactory(new PropertyValueFactory<>("title"));
        colPlArtist.setCellValueFactory(new PropertyValueFactory<>("artist"));

        colKeyword.setCellValueFactory(new PropertyValueFactory<>("keyword"));
        colSearchedAt.setCellValueFactory(new PropertyValueFactory<>("searchedAt"));

        tableSongs.getSelectionModel().selectedItemProperty().addListener((obs, oldSong, newSong) -> {
            if (newSong != null) {
                txtId.setText(newSong.getId());
                txtTitle.setText(newSong.getTitle());
                txtArtist.setText(newSong.getArtist());
                txtGenre.setText(newSong.getGenre());
            }
        });

        listPlaylists.getSelectionModel().selectedItemProperty().addListener((obs, oldPlaylist, newPlaylist) -> {
            if (newPlaylist != null) {
                loadPlaylistSongs(newPlaylist);
            }
        });
    }

    public void initUserData(ClientConnection connection, User user) {
        this.connection = connection;
        this.currentUser = user;

        lblWelcome.setText("Xin chào: " + user.getUsername() + " | Quyền: " + user.getRole());

        boolean isAdmin = user.isAdmin();
        btnAdd.setDisable(!isAdmin);
        btnUpdate.setDisable(!isAdmin);
        btnDelete.setDisable(!isAdmin);
        btnImportTxt.setDisable(!isAdmin);

        txtId.setEditable(isAdmin);
        txtTitle.setEditable(isAdmin);
        txtArtist.setEditable(isAdmin);
        txtGenre.setEditable(isAdmin);

        loadSongs();
        loadPlaylists();
        loadHistory();
    }

    @FXML
    void handleRefresh(ActionEvent event) {
        loadSongs();
        loadPlaylists();
        loadHistory();
        clearSongForm();
    }

    @FXML
    void handleSearch(ActionEvent event) {
        String keyword = txtSearch.getText().trim();

        if (keyword.isEmpty()) {
            loadSongs();
            return;
        }

        try {
            Response response = connection.send(new Request("SEARCH", keyword));
            if (response.isSuccess()) {
                tableSongs.setItems(FXCollections.observableArrayList((List<Song>) response.getData()));
                loadHistory();
            } else {
                showAlert("Lỗi tìm kiếm", response.getMessage());
            }
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleInsert(ActionEvent event) {
        if (!currentUser.isAdmin()) {
            showAlert("Không đủ quyền", "Chỉ ADMIN mới được thêm bài hát.");
            return;
        }

        Song song = getSongFromForm();
        if (song == null) {
            return;
        }

        try {
            Response response = connection.send(new Request("ADD", song));
            showAlert("Kết quả", response.getMessage());
            loadSongs();
            clearSongForm();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleUpdate(ActionEvent event) {
        if (!currentUser.isAdmin()) {
            showAlert("Không đủ quyền", "Chỉ ADMIN mới được sửa bài hát.");
            return;
        }

        Song song = getSongFromForm();
        if (song == null) {
            return;
        }

        try {
            Response response = connection.send(new Request("UPDATE", song));
            showAlert("Kết quả", response.getMessage());
            loadSongs();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleDelete(ActionEvent event) {
        if (!currentUser.isAdmin()) {
            showAlert("Không đủ quyền", "Chỉ ADMIN mới được xóa bài hát.");
            return;
        }

        String id = txtId.getText().trim();
        if (id.isEmpty()) {
            showAlert("Thiếu dữ liệu", "Chọn bài hát cần xóa.");
            return;
        }

        try {
            Response response = connection.send(new Request("DELETE", id));
            showAlert("Kết quả", response.getMessage());
            loadSongs();
            clearSongForm();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleExportTxt(ActionEvent event) {
        sendSimpleCommand("EXPORT_TXT");
    }

    @FXML
    void handleImportTxt(ActionEvent event) {
        sendSimpleCommand("IMPORT_TXT");
        loadSongs();
    }

    @FXML
    void handleExportXml(ActionEvent event) {
        sendSimpleCommand("EXPORT_XML");
    }

    @FXML
    void handleCreatePlaylist(ActionEvent event) {
        String name = txtPlaylistName.getText().trim();

        if (name.isEmpty()) {
            showAlert("Thiếu dữ liệu", "Nhập tên playlist.");
            return;
        }

        try {
            Response response = connection.send(new Request("PLAYLIST_CREATE", name));
            showAlert("Kết quả", response.getMessage());
            txtPlaylistName.clear();
            loadPlaylists();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleDeletePlaylist(ActionEvent event) {
        Playlist playlist = listPlaylists.getSelectionModel().getSelectedItem();

        if (playlist == null) {
            showAlert("Thiếu dữ liệu", "Chọn playlist cần xóa.");
            return;
        }

        try {
            Response response = connection.send(new Request("PLAYLIST_DELETE", playlist.getId()));
            showAlert("Kết quả", response.getMessage());
            tablePlaylistSongs.getItems().clear();
            loadPlaylists();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleAddSongToPlaylist(ActionEvent event) {
        Playlist playlist = listPlaylists.getSelectionModel().getSelectedItem();
        Song song = tableSongs.getSelectionModel().getSelectedItem();

        if (playlist == null || song == null) {
            showAlert("Thiếu dữ liệu", "Chọn playlist và chọn bài hát ở bảng danh sách bài hát.");
            return;
        }

        try {
            String data = playlist.getId() + "|" + song.getId();
            Response response = connection.send(new Request("PLAYLIST_ADD_SONG", data));
            showAlert("Kết quả", response.getMessage());
            loadPlaylistSongs(playlist);
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleRemoveSongFromPlaylist(ActionEvent event) {
        Playlist playlist = listPlaylists.getSelectionModel().getSelectedItem();
        Song song = tablePlaylistSongs.getSelectionModel().getSelectedItem();

        if (playlist == null || song == null) {
            showAlert("Thiếu dữ liệu", "Chọn playlist và chọn bài hát trong playlist.");
            return;
        }

        try {
            String data = playlist.getId() + "|" + song.getId();
            Response response = connection.send(new Request("PLAYLIST_REMOVE_SONG", data));
            showAlert("Kết quả", response.getMessage());
            loadPlaylistSongs(playlist);
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleClearHistory(ActionEvent event) {
        sendSimpleCommand("CLEAR_HISTORY");
        loadHistory();
    }

    @FXML
    void handleLogout(ActionEvent event) {
        try {
            if (connection != null) {
                connection.close();
            }

            FXMLLoader loader = new FXMLLoader(MainClientApp.class.getResource("/login.fxml"));
            Scene scene = new Scene(loader.load(), 430, 330);
            scene.getStylesheets().add(MainClientApp.class.getResource("/style.css").toExternalForm());

            Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
            stage.setTitle("Đăng nhập hệ thống Karaoke");
            stage.setScene(scene);
            stage.centerOnScreen();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    private void loadSongs() {
        try {
            Response response = connection.send(new Request("GET_ALL"));
            if (response.isSuccess()) {
                tableSongs.setItems(FXCollections.observableArrayList((List<Song>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải bài hát", e.getMessage());
        }
    }

    private void loadPlaylists() {
        try {
            Response response = connection.send(new Request("PLAYLISTS"));
            if (response.isSuccess()) {
                listPlaylists.setItems(FXCollections.observableArrayList((List<Playlist>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải playlist", e.getMessage());
        }
    }

    private void loadPlaylistSongs(Playlist playlist) {
        try {
            Response response = connection.send(new Request("PLAYLIST_SONGS", playlist.getId()));
            if (response.isSuccess()) {
                tablePlaylistSongs.setItems(FXCollections.observableArrayList((List<Song>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải bài hát trong playlist", e.getMessage());
        }
    }

    private void loadHistory() {
        try {
            Response response = connection.send(new Request("GET_HISTORY"));
            if (response.isSuccess()) {
                tableHistory.setItems(FXCollections.observableArrayList((List<SearchHistory>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải lịch sử", e.getMessage());
        }
    }

    private Song getSongFromForm() {
        String id = txtId.getText().trim();
        String title = txtTitle.getText().trim();
        String artist = txtArtist.getText().trim();
        String genre = txtGenre.getText().trim();

        if (id.isEmpty() || title.isEmpty() || artist.isEmpty() || genre.isEmpty()) {
            showAlert("Thiếu dữ liệu", "Không được để trống mã, tên bài hát, ca sĩ, thể loại.");
            return null;
        }

        return new Song(id, title, artist, genre);
    }

    private void clearSongForm() {
        txtId.clear();
        txtTitle.clear();
        txtArtist.clear();
        txtGenre.clear();
    }

    private void sendSimpleCommand(String command) {
        try {
            Response response = connection.send(new Request(command));
            showAlert("Kết quả", response.getMessage());
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    private void showAlert(String title, String message) {
        Platform.runLater(() -> {
            Alert alert = new Alert(Alert.AlertType.INFORMATION);
            alert.setTitle(title);
            alert.setHeaderText(null);
            alert.setContentText(message);
            alert.showAndWait();
        });
    }
}
EOF_KARAOKE

mkdir -p 'src/main/resources'
cat > 'src/main/resources/login.fxml' <<'EOF_KARAOKE'
<?xml version="1.0" encoding="UTF-8"?>

<?import javafx.geometry.Insets?>
<?import javafx.scene.control.Button?>
<?import javafx.scene.control.Label?>
<?import javafx.scene.control.PasswordField?>
<?import javafx.scene.control.TextField?>
<?import javafx.scene.layout.VBox?>

<VBox xmlns:fx="http://javafx.com/fxml"
      fx:controller="com.vku.karaoke.client.controller.LoginController"
      alignment="CENTER"
      spacing="14"
      styleClass="root-box">

    <padding>
        <Insets top="25" right="35" bottom="25" left="35"/>
    </padding>

    <Label text="HỆ THỐNG KARAOKE" styleClass="title"/>
    <Label text="Đăng nhập tài khoản để sử dụng hệ thống" styleClass="subtitle"/>

    <TextField fx:id="txtUsername" promptText="Tên đăng nhập"/>
    <PasswordField fx:id="txtPassword" promptText="Mật khẩu"/>

    <Button text="Đăng nhập" onAction="#handleLogin" maxWidth="Infinity" styleClass="primary-button"/>

    <Label fx:id="lblError" textFill="#d32f2f" wrapText="true"/>

    <Label text="Tài khoản mẫu: admin/admin123 hoặc user/user123" styleClass="hint"/>
</VBox>
EOF_KARAOKE

mkdir -p 'src/main/resources'
cat > 'src/main/resources/dashboard.fxml' <<'EOF_KARAOKE'
<?xml version="1.0" encoding="UTF-8"?>

<?import javafx.geometry.Insets?>
<?import javafx.scene.control.Button?>
<?import javafx.scene.control.Label?>
<?import javafx.scene.control.ListView?>
<?import javafx.scene.control.Tab?>
<?import javafx.scene.control.TabPane?>
<?import javafx.scene.control.TableColumn?>
<?import javafx.scene.control.TableView?>
<?import javafx.scene.control.TextField?>
<?import javafx.scene.layout.BorderPane?>
<?import javafx.scene.layout.GridPane?>
<?import javafx.scene.layout.HBox?>
<?import javafx.scene.layout.VBox?>

<BorderPane xmlns:fx="http://javafx.com/fxml"
            fx:controller="com.vku.karaoke.client.controller.KaraokeDashboardController"
            styleClass="dashboard-root">

    <top>
        <HBox spacing="12" alignment="CENTER_LEFT" styleClass="top-bar">
            <Label fx:id="lblWelcome" text="Xin chào" styleClass="welcome"/>
            <Button text="Làm mới" onAction="#handleRefresh"/>
            <Button text="Đăng xuất" onAction="#handleLogout" styleClass="danger-button"/>
        </HBox>
    </top>

    <center>
        <TabPane tabClosingPolicy="UNAVAILABLE">
            <Tab text="Quản lý bài hát">
                <BorderPane>
                    <top>
                        <VBox spacing="10" styleClass="content-box">
                            <HBox spacing="8">
                                <TextField fx:id="txtSearch" promptText="Nhập mã, tên bài hát, ca sĩ hoặc thể loại để tìm..." HBox.hgrow="ALWAYS"/>
                                <Button text="Tìm kiếm" onAction="#handleSearch" styleClass="primary-button"/>
                                <Button text="Xuất TXT" onAction="#handleExportTxt"/>
                                <Button fx:id="btnImportTxt" text="Nhập TXT" onAction="#handleImportTxt"/>
                                <Button text="Xuất XML" onAction="#handleExportXml"/>
                            </HBox>

                            <GridPane hgap="8" vgap="8">
                                <Label text="Mã bài hát:" GridPane.rowIndex="0" GridPane.columnIndex="0"/>
                                <TextField fx:id="txtId" promptText="S001" GridPane.rowIndex="0" GridPane.columnIndex="1"/>

                                <Label text="Tên bài hát:" GridPane.rowIndex="0" GridPane.columnIndex="2"/>
                                <TextField fx:id="txtTitle" promptText="Tên bài hát" GridPane.rowIndex="0" GridPane.columnIndex="3"/>

                                <Label text="Ca sĩ:" GridPane.rowIndex="1" GridPane.columnIndex="0"/>
                                <TextField fx:id="txtArtist" promptText="Ca sĩ" GridPane.rowIndex="1" GridPane.columnIndex="1"/>

                                <Label text="Thể loại:" GridPane.rowIndex="1" GridPane.columnIndex="2"/>
                                <TextField fx:id="txtGenre" promptText="Pop, Ballad..." GridPane.rowIndex="1" GridPane.columnIndex="3"/>
                            </GridPane>

                            <HBox spacing="8">
                                <Button fx:id="btnAdd" text="Thêm bài hát" onAction="#handleInsert" styleClass="primary-button"/>
                                <Button fx:id="btnUpdate" text="Sửa bài hát" onAction="#handleUpdate"/>
                                <Button fx:id="btnDelete" text="Xóa bài hát" onAction="#handleDelete" styleClass="danger-button"/>
                                <Button text="Thêm bài đang chọn vào playlist" onAction="#handleAddSongToPlaylist"/>
                            </HBox>
                        </VBox>
                    </top>

                    <center>
                        <TableView fx:id="tableSongs">
                            <columns>
                                <TableColumn fx:id="colId" text="Mã" prefWidth="100"/>
                                <TableColumn fx:id="colTitle" text="Tên bài hát" prefWidth="330"/>
                                <TableColumn fx:id="colArtist" text="Ca sĩ" prefWidth="250"/>
                                <TableColumn fx:id="colGenre" text="Thể loại" prefWidth="160"/>
                            </columns>
                        </TableView>
                    </center>
                </BorderPane>
            </Tab>

            <Tab text="Playlist">
                <BorderPane>
                    <left>
                        <VBox spacing="8" styleClass="side-box" prefWidth="300">
                            <Label text="Playlist của tôi" styleClass="section-title"/>
                            <TextField fx:id="txtPlaylistName" promptText="Tên playlist mới"/>
                            <Button text="Tạo playlist" onAction="#handleCreatePlaylist" maxWidth="Infinity" styleClass="primary-button"/>
                            <Button text="Xóa playlist" onAction="#handleDeletePlaylist" maxWidth="Infinity" styleClass="danger-button"/>
                            <ListView fx:id="listPlaylists" VBox.vgrow="ALWAYS"/>
                        </VBox>
                    </left>

                    <center>
                        <VBox spacing="8" styleClass="content-box">
                            <Label text="Bài hát trong playlist đang chọn" styleClass="section-title"/>
                            <Button text="Xóa bài đang chọn khỏi playlist" onAction="#handleRemoveSongFromPlaylist"/>
                            <TableView fx:id="tablePlaylistSongs" VBox.vgrow="ALWAYS">
                                <columns>
                                    <TableColumn fx:id="colPlId" text="Mã" prefWidth="100"/>
                                    <TableColumn fx:id="colPlTitle" text="Tên bài hát" prefWidth="400"/>
                                    <TableColumn fx:id="colPlArtist" text="Ca sĩ" prefWidth="260"/>
                                </columns>
                            </TableView>
                        </VBox>
                    </center>
                </BorderPane>
            </Tab>

            <Tab text="Lịch sử tìm kiếm">
                <VBox spacing="8" styleClass="content-box">
                    <HBox spacing="8" alignment="CENTER_LEFT">
                        <Label text="Lịch sử tìm kiếm của tài khoản đang đăng nhập" styleClass="section-title"/>
                        <Button text="Xóa lịch sử" onAction="#handleClearHistory" styleClass="danger-button"/>
                    </HBox>

                    <TableView fx:id="tableHistory" VBox.vgrow="ALWAYS">
                        <columns>
                            <TableColumn fx:id="colKeyword" text="Từ khóa" prefWidth="450"/>
                            <TableColumn fx:id="colSearchedAt" text="Thời gian tìm kiếm" prefWidth="260"/>
                        </columns>
                    </TableView>
                </VBox>
            </Tab>
        </TabPane>
    </center>
</BorderPane>
EOF_KARAOKE

mkdir -p 'src/main/resources'
cat > 'src/main/resources/style.css' <<'EOF_KARAOKE'
.root-box {
    -fx-background-color: #f4f6f8;
}

.dashboard-root {
    -fx-background-color: #f4f6f8;
}

.title {
    -fx-font-size: 26px;
    -fx-font-weight: bold;
}

.subtitle {
    -fx-font-size: 14px;
    -fx-text-fill: #555;
}

.hint {
    -fx-font-size: 12px;
    -fx-text-fill: #666;
}

.top-bar {
    -fx-padding: 12;
    -fx-background-color: #263238;
}

.welcome {
    -fx-text-fill: white;
    -fx-font-size: 15px;
    -fx-font-weight: bold;
}

.content-box {
    -fx-padding: 12;
}

.side-box {
    -fx-padding: 12;
    -fx-background-color: #ffffff;
}

.section-title {
    -fx-font-size: 16px;
    -fx-font-weight: bold;
}

.primary-button {
    -fx-background-color: #1976d2;
    -fx-text-fill: white;
    -fx-font-weight: bold;
}

.danger-button {
    -fx-background-color: #d32f2f;
    -fx-text-fill: white;
    -fx-font-weight: bold;
}

.button {
    -fx-cursor: hand;
}

.text-field, .password-field {
    -fx-pref-height: 34;
}

.table-view {
    -fx-background-color: white;
}
EOF_KARAOKE

cat > 'backup_songs.txt' <<'EOF_KARAOKE'
S009|Ngày mai người ta lấy chồng|Thành Đạt|Ballad
S010|Cắt đôi nỗi sầu|Tăng Duy Tân|Pop
S011|Tháng tư là lời nói dối của em|Hà Anh Tuấn|Ballad
EOF_KARAOKE

echo "Xong. Hay sua config.xml neu mat khau MySQL khac Admin@123."
