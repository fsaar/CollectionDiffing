import Foundation

typealias TFLTransformCollectionCompare<T> = (_ lhs : T,_ rhs: T) -> (Bool)

enum SetIndexListError : Error {
    case elementNotInTargetList
}

enum CollectionError : Error {
    case mergeIndexOutOfRange
    case findMovedElementsIndexOutOfRange
}

//enum Collection

extension Collection where Element : Hashable {
    func transformTo(newList : [Element],sortedBy compare: @escaping TFLTransformCollectionCompare<Element>)  -> (inserted : [(element:Element,index:Int)],deleted : [(element:Element,index:Int)], updated : [(element:Element,index:Int)],moved : [(element:Element,oldIndex:Int,newIndex:Int)])
    {
        let sortedOldList = self.sorted(by: compare)
        let sortedNewList = newList.sorted(by: compare)
        return sortedOldList.transformTo(newList: sortedNewList)
    }
    
    func transformTo(newList : [Element])  -> (inserted : [(element:Element,index:Int)],deleted : [(element:Element,index:Int)], updated : [(element:Element,index:Int)],moved : [(element:Element,oldIndex:Int,newIndex:Int)])
    {
        guard newList.count == Set(newList).count else {
            return ([],[],[],[])
        }
        guard !self.isEmpty else {
            return (newList.enumerated().map { ($0.1,$0.0) },[],[],[])
        }
        guard !newList.isEmpty else {
            return ([],self.enumerated().map { ($0.1,$0.0) },[],[])
        }
        let oldList = Array(self)
        let oldSet = Set(self)
        let newSet = Set(newList)


        let insertedSet = newSet.subtracting(oldSet)
        let unchangedSet = newSet.intersection(oldSet)
        let deletedSet = oldSet.subtracting(newSet)

        do {
            let inserted = try insertedSet.indexedList(basedOn: newList)
            
            let deleted = try deletedSet.indexedList(basedOn: oldList)
            
            let moved = try findMovedElements(in: newList,inserted: inserted ,deleted: deleted)
            let movedTypes = moved.map { $0.0 }
            
            let updatedTypes = unchangedSet.subtracting(Set(movedTypes))
            let updated = try updatedTypes.indexedList(basedOn: newList)
            return (inserted,deleted,updated,moved)
        }
        catch {
            return (newList.enumerated().map { ($0.1,$0.0) },self.enumerated().map { ($0.1,$0.0) },[],[])
        }
    }

    func mergeELements(with indexedList : [(element:Element,index:Int)]) throws  -> [Element] {
        let sortedIndexListByIndex = indexedList.sorted { $0.1 < $1.1 }
        var copy = Array(self)
        try sortedIndexListByIndex.forEach { arg in
            let (element, index) = arg
            guard index <= copy.count else {
                throw CollectionError.mergeIndexOutOfRange
            }
            copy.insert(element, at: index)
        }
        return copy
        
    }
}


fileprivate extension Set {
    func indexedList(basedOn list:[Element]) throws -> [(Element,Int)] {
        let indexList : [(Element,Int)] = try self.compactMap { el in
            guard let index = list.firstIndex(of:el) else {
                throw SetIndexListError.elementNotInTargetList
            }
            return (el,index)
        }
        return indexList
    }
}

fileprivate extension Array where Element : Equatable {
    func moveElement(_ element : Element, to : Int) -> Array {
        var currentList = self
        if let from = firstIndex(of:element),0 ..< currentList.count ~= to {
            currentList.insert(currentList.remove(at: from), at: to)
        }
        return currentList
    }
}



fileprivate extension Collection where Element : Hashable{
    
    func findMovedElements(in newList : [Element],
                                     inserted : [(element:Element,index:Int)],
                                     deleted : [(element:Element,index:Int)]) throws -> [(Element,Int,Int)]  {

        // Reconstruct the unordered newList
        // 1. delete items from old list
        // 2. insert new items
        // 3. identify all moved elements
        // 4. reduce moved element list by transforming list from (2) into new list by applying moves from (3)
        
        let deletedTypes = deleted.map { $0.element }
        let reducedOldList = self.filter { !deletedTypes.contains($0) }
        let updatedList : [Element] = try reducedOldList.compactMap { el in
            guard let index = newList.firstIndex(of: el) else {
                throw CollectionError.findMovedElementsIndexOutOfRange
            }
            return newList[index]
        }
        let unsortedNewList = try updatedList.mergeELements(with: inserted)
        let oldList = Array(self)
        let movedTypes : [(Element,Int,Int)] = updatedList.compactMap { element in
            guard let index = oldList.firstIndex(of:element),let index2 = newList.firstIndex(of:element),index != index2 else {
                return nil
            }
            return (element,index,index2)
        }.sorted { $0.2 < $1.2 }
        
        let reducedMovedTypes : [(Element,Int,Int)]  = movedTypes.reduce(([],unsortedNewList)) { tuple,move in
            let (sum,currentList) = tuple
            guard currentList != newList else {
                return (sum,newList)
            }
            let (element,_,to) = move
            let list = currentList.moveElement(element, to: to)
            return (sum + [move],list)
        }.0
        return reducedMovedTypes
    }
}
