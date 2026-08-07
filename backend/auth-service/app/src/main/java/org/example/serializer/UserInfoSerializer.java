package org.example.serializer;

import java.util.Map;

import org.apache.kafka.common.serialization.Serializer;
import org.example.eventProducer.UserInfoEvent;

import com.fasterxml.jackson.databind.ObjectMapper;

public class UserInfoSerializer implements Serializer<UserInfoEvent> {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void configure(Map<String, ?> configs, boolean isKey) {
    }

    @Override
    public byte[] serialize(String topic, UserInfoEvent data) {
        if (data == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsBytes(data);
        } catch (Exception e) {
            System.err.println("Error serializing UserInfoEvent: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public void close() {
    }
}
