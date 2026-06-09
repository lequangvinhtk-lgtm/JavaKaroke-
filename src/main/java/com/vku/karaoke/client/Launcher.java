package com.vku.karaoke.client;

/**
 * TRẢ LỜI VẤN ĐÁP: Lớp này sinh ra để làm gì?
 * Trả lời: Đây là lớp mồi (Wrapper/Launcher). Vì từ Java 11, JVM cấm chạy trực tiếp class
 * kế thừa Application mà không khai báo module-path. Lớp Launcher này không kế thừa Application,
 * nó giúp "đánh lừa" bộ nạp class (ClassLoader) của JVM, tải các thư viện JavaFX vào bộ nhớ
 * một cách mượt mà rồi mới gọi tới MainClientApp.
 */
public class Launcher {
    public static void main(String[] args) {
        // Gọi hàm main của MainClientApp từ đây
        MainClientApp.main(args);
    }
}