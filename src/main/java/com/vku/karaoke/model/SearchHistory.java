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
