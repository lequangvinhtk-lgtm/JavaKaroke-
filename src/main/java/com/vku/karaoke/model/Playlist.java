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
