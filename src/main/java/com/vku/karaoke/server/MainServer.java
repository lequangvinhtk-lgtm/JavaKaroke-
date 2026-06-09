package com.vku.karaoke.server;

import com.vku.karaoke.server.network.ClientHandler;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

/**
 * TRẢ LỜI VẤN ĐÁP: Điểm khởi chạy (Entry Point) của Máy Chủ Hệ Thống.
 * Tạo ra một ServerSocket mở cổng dịch vụ lắng nghe cố định. Chạy file này đầu tiên để máy chủ sẵn sàng nhận lệnh.
 */
public class MainServer {
    private static final int PORT = 9999; // Cấu hình cổng kết nối mạng của hệ thống máy chủ

    public static void main(String[] args) {
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("=================================================");
            System.out.println(" KÝ TÚC XÁ KARAOKE SERVER ĐÃ CHẠY TRÊN CỔNG: " + PORT);
            System.out.println(" ĐANG CHỜ CÁC MÁY TRẠM CLIENT KẾT NỐI VÀO... ");
            System.out.println("=================================================");

            while (true) {
                // Hàm accept() sẽ đứng chặn (Block) dừng luồng chính đợi cho đến khi có một Client kết nối tới
                Socket clientSocket = serverSocket.accept();
                System.out.println("[CONNECT] Máy trạm kết nối thành công từ địa chỉ IP: " + clientSocket.getInetAddress());

                // MULTITHREADING: Giao socket vừa kết nối cho phân luồng quản lý ClientHandler xử lý,
                // rồi quay ngược lại vòng lặp ngay lập tức để chờ máy trạm khác kết nối kết nối tiếp.
                ClientHandler handler = new ClientHandler(clientSocket);
                Thread thread = new Thread(handler);
                thread.start();
            }
        } catch (IOException e) {
            System.err.println("Không thể khởi động cổng máy chủ vì lỗi xung đột hệ thống: " + e.getMessage());
        }
    }
}