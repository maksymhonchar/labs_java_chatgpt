package com.kabanchiktask;

import java.util.List;
import java.util.Map;

public class DataLoader {
    private final DatabaseManager databaseManager;

    public DataLoader(DatabaseManager databaseManager) {
        this.databaseManager = databaseManager;
    }

    public void loadData(Map<Integer, List<Map<String, Object>>> data) {
        for (Map.Entry<Integer, List<Map<String, Object>>> entry : data.entrySet()) {
            int eventId = entry.getKey();
            List<Map<String, Object>> eventList = entry.getValue();

            String scriptFilename = getInsertScriptFilename(eventId);
            if (scriptFilename == null) {
                throw new RuntimeException("Got unexpected eventId: " + eventId);
            }

            String sql = databaseManager.readSqlScript(scriptFilename);
            if (sql == null) {
                throw new RuntimeException("The script cannot be read for eventId: " + eventId + ", scriptFilename: " + scriptFilename);
            }

            for (Map<String, Object> event : eventList) {
                executeEventInsertQuery(eventId, sql, event);
            }
        }
    }

    private void executeEventInsertQuery(int eventId, String sql, Map<String, Object> event) {
        switch (eventId) {
            case 1: executeInsertQuery(sql, event, "udid", "date"); break;
            case 2: executeInsertQuery(sql, event, "udid", "date", "gender", "age", "country"); break;
            case 3: executeInsertQuery(sql, event, "udid", "date", "stage"); break;
            case 4: executeInsertQuery(sql, event, "udid", "date", "stage", "win", "time", "income"); break;
            case 5: executeInsertQuery(sql, event, "udid", "date", "item", "price"); break;
            case 6: executeInsertQuery(sql, event, "udid", "date", "name", "price", "income"); break;
            default: throw new RuntimeException("Got invalid eventId: " + eventId);
        }
    }

    private void executeInsertQuery(String sql, Map<String, Object> event, String... params) {
        Object[] values = new Object[params.length];
        for (int i = 0; i < params.length; i++) {
            values[i] = event.get(params[i]);
        }
        databaseManager.executeInsertQuery(sql, values);
    }

    private String getInsertScriptFilename(int eventId) {
        switch (eventId) {
            case 1: return "insert_start_game_event.sql";
            case 2: return "insert_first_start_event.sql";
            case 3: return "insert_stage_start_event.sql";
            case 4: return "insert_stage_end_event.sql";
            case 5: return "insert_item_purchase_event.sql";
            case 6: return "insert_currency_purchase_event.sql";
            default: return null;
        }
    }
}
