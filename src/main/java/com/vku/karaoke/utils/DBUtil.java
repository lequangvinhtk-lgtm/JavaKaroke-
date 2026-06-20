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
