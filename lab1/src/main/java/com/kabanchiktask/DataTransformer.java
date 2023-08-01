package com.kabanchiktask;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DataTransformer {
    public Map<Integer, List<Map<String, Object>>> transformData(JsonArray jsonArray) {
        Map<Integer, List<Map<String, Object>>> transformedData = new HashMap<>();

        for (JsonElement jsonElement : jsonArray) {
            JsonObject jsonObject = jsonElement.getAsJsonObject();
            Map<String, Object> transformedJsonObject = transformJsonObject(jsonObject);

            int eventId = (int) transformedJsonObject.get("event_id");
            List<Map<String, Object>> eventList = transformedData.get(eventId);
            if (eventList == null) {
                eventList = new ArrayList<>();
                transformedData.put(eventId, eventList);
            }
            eventList.add(transformedJsonObject);
        }

        return transformedData;
    }

    private Map<String, Object> transformJsonObject(JsonObject jsonObject) {
        Map<String, Object> transformedJsonObject = new HashMap<>();

        transformedJsonObject.put("event_id", jsonObject.get("event_id").getAsInt());
        transformedJsonObject.put("udid", jsonObject.get("udid").getAsString());
        transformedJsonObject.put("date", transformDate(jsonObject));

        JsonObject parametersObject = jsonObject.getAsJsonObject("parameters");
        if (parametersObject != null) {
            transformedJsonObject.putAll(transformParameters(parametersObject));
        }

        return transformedJsonObject;
    }

    private LocalDate transformDate(JsonObject jsonObject) {
        String dateValue = jsonObject.get("date").getAsString();
        return LocalDate.parse(dateValue, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }

    private Map<String, Object> transformParameters(JsonObject parametersObject) {
        Map<String, Object> transformedParameters = new HashMap<>();

        for (Map.Entry<String, JsonElement> entry : parametersObject.entrySet()) {
            String key = entry.getKey();
            JsonElement valueElement = entry.getValue();
            Object value = null;

            if (valueElement.isJsonPrimitive()) {
                if (valueElement.getAsJsonPrimitive().isString()) {
                    value = valueElement.getAsString();
                } else if (valueElement.getAsJsonPrimitive().isNumber()) {
                    String numberValue = valueElement.getAsString();
                    value = transformNumber(numberValue);
                } else if (valueElement.getAsJsonPrimitive().isBoolean()) {
                    value = valueElement.getAsBoolean();
                }
            }

            transformedParameters.put(key, value);
        }

        return transformedParameters;
    }

    private Object transformNumber(String numberValue) {
        if (numberValue.contains(".")) {
            return Double.parseDouble(numberValue);
        } else {
            try {
                return Long.parseLong(numberValue);
            } catch (NumberFormatException e) {
                return Integer.parseInt(numberValue);
            }
        }
    }
}
