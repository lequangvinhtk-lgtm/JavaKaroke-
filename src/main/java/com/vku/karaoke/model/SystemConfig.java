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
