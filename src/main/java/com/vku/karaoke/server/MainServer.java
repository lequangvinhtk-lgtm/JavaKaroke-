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
