//
//  main.swift
//  StagedMigration
//
//  Created by kse2 on 23.10.2025.
//

import Foundation
import CoreData



var v1ModelChecksum: String!
var v2ModelChecksum: String!
var v3ModelChecksum: String!
var v4ModelChecksum: String!

var v2DBURL: URL!

let cachesURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
var tempURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: cachesURL, create: true)


// make V1 data
let v1DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)

let v1ModelURL = Bundle.main.url(forResource: "V1", withExtension: "mom", subdirectory: "Model.momd")!
let v1Model = NSManagedObjectModel(contentsOf: v1ModelURL)!
v1ModelChecksum = v1Model.versionChecksum
let v1Container = NSPersistentContainer(name: "Model", managedObjectModel: v1Model)
let v1StoreDescription = NSPersistentStoreDescription(url: v1DBURL)
v1StoreDescription.type = NSBinaryStoreType
v1Container.persistentStoreDescriptions = [v1StoreDescription]
v1Container.loadPersistentStores { _, error in
	print(">>>Creating V1, error: \(String(describing: error?.localizedDescription))")
}

try v1Container.viewContext.performAndWait { [moc = v1Container.viewContext] in
	let entity = NSManagedObject(entity: .entity(forEntityName: "Entity", in: moc)!, insertInto: moc)
	entity.setValue("asdf", forKey: "foo")
	try moc.save()
}
let v1Size = try FileManager.default.attributesOfItem(atPath: v1DBURL.path())[.size] as! Int
print(">>>Created V1, size = \(v1Size)")


do
{
	// V1 -> V2
	v2DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v2DBURL)
	
	let v2ModelURL = Bundle.main.url(forResource: "V2", withExtension: "mom", subdirectory: "Model.momd")!
	let v2Model = NSManagedObjectModel(contentsOf: v2ModelURL)!
	v2ModelChecksum = v2Model.versionChecksum
	let v2Container = NSPersistentContainer(name: "Model", managedObjectModel: v2Model)
	let v2StoreDescription = NSPersistentStoreDescription(url: v2DBURL)
	v2StoreDescription.type = NSBinaryStoreType
	v2Container.persistentStoreDescriptions = [v2StoreDescription]
	v2Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V2, error: \(String(describing: error?.localizedDescription))")
	}
	
	let v2Size = try FileManager.default.attributesOfItem(atPath: v2DBURL.path())[.size] as! Int
	print(">>>Migrated V1->V2, size = \(v2Size)")
	
	
	// V2 -> V3
	let v3DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v2DBURL, to: v3DBURL)
	
	let v3ModelURL = Bundle.main.url(forResource: "V3", withExtension: "mom", subdirectory: "Model.momd")!
	let v3Model = NSManagedObjectModel(contentsOf: v3ModelURL)!
	v3ModelChecksum = v3Model.versionChecksum
	let v3Container = NSPersistentContainer(name: "Model", managedObjectModel: v3Model)
	let v3StoreDescription = NSPersistentStoreDescription(url: v3DBURL)
	v3StoreDescription.type = NSBinaryStoreType
	v3Container.persistentStoreDescriptions = [v3StoreDescription]
	v3Container.loadPersistentStores { _, error in
		print(">>>Migrating V2->V3, error: \(String(describing: error?.localizedDescription))")
	}
	
	let v3Size = try FileManager.default.attributesOfItem(atPath: v3DBURL.path())[.size] as! Int
	print(">>>Migrated V2->V3, size = \(v3Size)")
	
	
	// V3 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v3DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	v4ModelChecksum = v4Model.versionChecksum
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V3->V4, error: \(String(describing: error?.localizedDescription))")
	}
	
	let v4Size = try FileManager.default.attributesOfItem(atPath: v4DBURL.path())[.size] as! Int
	print(">>>Migrated V3->V4, size = \(v4Size)")
}


do
{
	// V1 -> V3
	let v3DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v3DBURL)
	
	let v3ModelURL = Bundle.main.url(forResource: "V3", withExtension: "mom", subdirectory: "Model.momd")!
	let v3Model = NSManagedObjectModel(contentsOf: v3ModelURL)!
	let v3Container = NSPersistentContainer(name: "Model", managedObjectModel: v3Model)
	let v3StoreDescription = NSPersistentStoreDescription(url: v3DBURL)
	v3StoreDescription.type = NSBinaryStoreType
	v3Container.persistentStoreDescriptions = [v3StoreDescription]
	v3Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V3, no manager, error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V3
	let v3DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v3DBURL)
	
	let v3ModelURL = Bundle.main.url(forResource: "V3", withExtension: "mom", subdirectory: "Model.momd")!
	let v3Model = NSManagedObjectModel(contentsOf: v3ModelURL)!
	let v3Container = NSPersistentContainer(name: "Model", managedObjectModel: v3Model)
	let v3StoreDescription = NSPersistentStoreDescription(url: v3DBURL)
	v3StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSLightweightMigrationStage([
			v1ModelChecksum,
			v2ModelChecksum,
			v3ModelChecksum,
		])
	])
	v3StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v3Container.persistentStoreDescriptions = [v3StoreDescription]
	v3Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V3, lightweight[1, 2, 3], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V3
	let v3DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v3DBURL)
	
	let v3ModelURL = Bundle.main.url(forResource: "V3", withExtension: "mom", subdirectory: "Model.momd")!
	let v3Model = NSManagedObjectModel(contentsOf: v3ModelURL)!
	let v3Container = NSPersistentContainer(name: "Model", managedObjectModel: v3Model)
	let v3StoreDescription = NSPersistentStoreDescription(url: v3DBURL)
	v3StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSLightweightMigrationStage([v1ModelChecksum]),
		NSLightweightMigrationStage([v2ModelChecksum]),
		NSLightweightMigrationStage([v3ModelChecksum]),
	])
	v3StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v3Container.persistentStoreDescriptions = [v3StoreDescription]
	v3Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V3, lightweight[1]->lightweight[2]->lightweight[3], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V3
	let v3DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v3DBURL)
	
	let v3ModelURL = Bundle.main.url(forResource: "V3", withExtension: "mom", subdirectory: "Model.momd")!
	let v3Model = NSManagedObjectModel(contentsOf: v3ModelURL)!
	let v3Container = NSPersistentContainer(name: "Model", managedObjectModel: v3Model)
	let v3StoreDescription = NSPersistentStoreDescription(url: v3DBURL)
	v3StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v1ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum)),
		NSLightweightMigrationStage([v3ModelChecksum]),
	])
	v3StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v3Container.persistentStoreDescriptions = [v3StoreDescription]
	v3Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V3, custom[1->2]->lightweight[3], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V3
	let v3DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v3DBURL)
	
	let v3ModelURL = Bundle.main.url(forResource: "V3", withExtension: "mom", subdirectory: "Model.momd")!
	let v3Model = NSManagedObjectModel(contentsOf: v3ModelURL)!
	let v3Container = NSPersistentContainer(name: "Model", managedObjectModel: v3Model)
	let v3StoreDescription = NSPersistentStoreDescription(url: v3DBURL)
	v3StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSLightweightMigrationStage([v1ModelChecksum]),
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v3ModelChecksum)),
	])
	v3StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v3Container.persistentStoreDescriptions = [v3StoreDescription]
	v3Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V3, lightweight[1]->custom[2->3], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V3
	let v3DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v3DBURL)
	
	let v3ModelURL = Bundle.main.url(forResource: "V3", withExtension: "mom", subdirectory: "Model.momd")!
	let v3Model = NSManagedObjectModel(contentsOf: v3ModelURL)!
	let v3Container = NSPersistentContainer(name: "Model", managedObjectModel: v3Model)
	let v3StoreDescription = NSPersistentStoreDescription(url: v3DBURL)
	v3StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v1ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum)),
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v3ModelChecksum)),
	])
	v3StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v3Container.persistentStoreDescriptions = [v3StoreDescription]
	v3Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V3, custom[1->2]->custom[2->3], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V4, error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V2 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v2DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V2->V4, error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v1ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum)),
		NSLightweightMigrationStage([
			v3ModelChecksum,
			v4ModelChecksum,
		]),
	])
	v4StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V4, custom[1->2]->lightweight[3, 4], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSLightweightMigrationStage([
			v3ModelChecksum,
			v4ModelChecksum,
		]),
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v1ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum)),
	])
	v4StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V4, lightweight[3, 4]->custom[1->2], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSLightweightMigrationStage([
			v1ModelChecksum,
			v2ModelChecksum,
		]),
		NSLightweightMigrationStage([
			v3ModelChecksum,
			v4ModelChecksum,
		]),
	])
	v4StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V4, lightweight[1, 2]->lightweight[3, 4], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSLightweightMigrationStage([
			v1ModelChecksum,
		]),
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v3ModelChecksum)),
		NSLightweightMigrationStage([
			v4ModelChecksum,
		]),
	])
	v4StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V4, lightweight[1]->custom[2->3]->lightweight[4], error: \(String(describing: error?.localizedDescription))")
	}
}



do
{
	// V1 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSLightweightMigrationStage([
			v1ModelChecksum,
			v4ModelChecksum,
		]),
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v3ModelChecksum)),
	])
	v4StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V4, lightweight[1,4]->custom[2->3], error: \(String(describing: error?.localizedDescription))")
	}
}


do
{
	// V1 -> V4
	let v4DBURL = tempURL.appending(path: UUID().uuidString, directoryHint: .notDirectory)
	try FileManager.default.copyItem(at: v1DBURL, to: v4DBURL)
	
	let v4ModelURL = Bundle.main.url(forResource: "V4", withExtension: "mom", subdirectory: "Model.momd")!
	let v4Model = NSManagedObjectModel(contentsOf: v4ModelURL)!
	let v4Container = NSPersistentContainer(name: "Model", managedObjectModel: v4Model)
	let v4StoreDescription = NSPersistentStoreDescription(url: v4DBURL)
	v4StoreDescription.type = NSBinaryStoreType
	
	let migrationManager = NSStagedMigrationManager([
		NSCustomMigrationStage(
			migratingFrom: .init(name: "Model", in: nil, versionChecksum: v2ModelChecksum),
			to: .init(name: "Model", in: nil, versionChecksum: v3ModelChecksum)),
		NSLightweightMigrationStage([
			v1ModelChecksum,
			v4ModelChecksum,
		]),
	])
	v4StoreDescription.setOption(migrationManager, forKey: NSPersistentStoreStagedMigrationManagerOptionKey)
	
	v4Container.persistentStoreDescriptions = [v4StoreDescription]
	v4Container.loadPersistentStores { _, error in
		print(">>>Migrating V1->V4, custom[2->3]->lightweight[1,4], error: \(String(describing: error?.localizedDescription))")
	}
}
