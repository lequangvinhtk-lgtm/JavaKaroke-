package com.vku.karaoke.model;

import java.io.Serializable;

/**
 * TRẢ LỜI VẤN ĐÁP: Lớp này đóng vai trò là Model đại diện cho thực thể Bài hát trong hệ thống.
 * Phải implements Serializable để chuyển đổi đối tượng thành dòng bit dữ liệu nhằm truyền qua mạng mạng (Socket)
 * và lưu trữ xuống File (.txt, .xml).
 */
public class Song implements Serializable {
    // Thuộc tính tương ứng với các cột trong Database
    private String id;
    private String title;
    private String artist;
    private String genre;

    // Constructor mặc định không tham số
    public Song() {}

    // Constructor đầy đủ tham số để khởi tạo nhanh một bài hát
    public Song(String id, String title, String artist, String genre) {
        this.id = id;
        this.title = title;
        this.artist = artist;
        this.genre = genre;
    }

    // Các hàm Getter và Setter giúp bảo đóng gói dữ liệu (Encapsulation)
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getArtist() { return artist; }
    public void setArtist(String artist) { this.artist = artist; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }
}