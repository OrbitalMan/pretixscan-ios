//
//  Item.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import FMDB

extension Item: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "id"    INTEGER NOT NULL UNIQUE,
    "name"    TEXT,
    "internal_name"    TEXT,
    "default_price"    TEXT,
    "category"    INTEGER,
    "active"    INTEGER,
    "description"    TEXT,
    "position"    INTEGER,
    "checkin_attention"    INTEGER,
    "json"    TEXT,
    PRIMARY KEY("id")
    );
    """

    static var insertQuery = """
    REPLACE INTO \"\(stringName)\"(
    "id","name","internal_name","default_price",
    "category","active","description","position",
    "checkin_attention","json"
    ) VALUES (?,?,?,?,?,?,?,?,?,?);
    """

    static var searchByIdentifierQuery = """
    SELECT * FROM "\(stringName)" WHERE id=?;
    """

    static var allItemsQuery = """
    SELECT * FROM "\(stringName)";
    """

    static func getItem(by identifier: Identifier, in queue: FMDatabaseQueue) -> Item? {
        var item: Item?
        queue.inDatabase { database in
            if let result = try? database.executeQuery(Item.searchByIdentifierQuery, values: [identifier]) {
                while result.next() {
                    if let foundItem = Item.from(result: result, in: database) {
                        item = foundItem
                    }
                }
            }

        }

        return item
    }

    static func from(result: FMResultSet, in database: FMDatabase) -> Item? {
        let json = result.string(forColumn: "json")
        guard let jsonData = json?.data(using: .utf8),
            let item = try? JSONDecoder.iso8601withFractionsDecoder.decode(Item.self, from: jsonData) else { return nil }
        return item
    }

    static func store(_ items: [Item], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for item in items {
                let identifier = item.identifier as Int
                let name = item.name.toJSONString()
                let internal_name = item.internalName
                let default_price = item.defaultPrice as String
                let category = item.categoryIdentifier as Int?
                let active = item.active.toInt()
                let description = item.description?.toJSONString()
                let position = item.position
                let checkin_attention = item.checkInAttention.toInt()
                let json = item.toJSONString()

                do {
                    try database.executeUpdate(Item.insertQuery, values: [
                        identifier, name as Any, internal_name as Any, default_price,
                        category as Any, active, description as Any,
                        position, checkin_attention, json as Any])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }
            }
        }
    }

    static func getAllItems(in queue: FMDatabaseQueue) -> [Item] {
        var results = [Item]()

        queue.inDatabase { database in
            do {
                let result = try database.executeQuery(allItemsQuery, values: [])
                while result.next() {
                    if let itemFromResult = Item.from(result: result, in: database) {
                        results.append(itemFromResult)
                    }
                }

            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }

        return results
    }
}
