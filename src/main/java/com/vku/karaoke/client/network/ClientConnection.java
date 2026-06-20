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
