import Foundation
import Nimble
import Quick

@testable import CollectionDiffing


fileprivate struct Pos : Hashable {
    let a : M
    let b : Int
    init(_ tuple:(a: M,b: Int)) {
        self.a = tuple.a
        self.b = tuple.b
    }
    init(_ a: M,_ b: Int) {
        self.a = a
        self.b = b
    }
   
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.a)
        hasher.combine(self.b)
    }
    
    static public func ==(lhs : Pos, rhs : Pos) -> Bool {
        return (lhs.a == rhs.a) && (rhs.b == lhs.b)
    }
}

fileprivate struct MovedPos : Hashable,CustomStringConvertible {
    let a : M
    let b : Int
    let c : Int
    init(_ tuple : (a: M,b: Int,c: Int)) {
        self.a = tuple.a
        self.b = tuple.b
        self.c = tuple.c
    }
    init(_ a: M,_ b: Int,_ c: Int) {
        self.a = a
        self.b = b
        self.c = c
    }
    var description: String {
        return "\(a): \(b) -> \(c)"
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.a)
        hasher.combine(self.b)
        hasher.combine(self.c)
    }

    static public func ==(lhs : MovedPos, rhs : MovedPos) -> Bool {
        return (lhs.a == rhs.a) && (rhs.b == lhs.b) && (rhs.c == lhs.c)
    }
}


fileprivate struct M : Hashable,CustomStringConvertible {
    let id : String
    let x : Int
    public static func ==(lhs: M, rhs: M) -> Bool {
        return lhs.id == rhs.id
    }
    public static func compare(lhs: M, rhs: M) -> Bool {
        return lhs.x <= rhs.x
    }
    var description: String {
        return "[\(id)-\(x)]"
    }
    init(_ id: String,_ x: Int) {
        self.id = id
        self.x = x
    }
    
   // var debugDescription: String { return "[\(id)]\(x)" } //tempList
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class TFLChangeSetProtocolSpecs : QuickSpec {
    
    override func spec() {
      
        beforeEach {
        
        }
        context("when testing trasnformTo") {
            it("should return the correct tuple when nothing's been inserted : [] -> []") {
                let newList : [M] = []
                let (inserted ,deleted ,updated, moved)  = [].transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
                
            }
            
            it("should return the correct tuple when inserted 1,2,4,6,8 : [] -> [1,2,4,6,8]") {
                let newList = [1,2,4,6,8].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = [].transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),3),Pos(M("8",8),4)])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            
            it("should return the correct tuple when nothing's changed : [1,2,4,6,8] -> [1,2,4,6,8]") {
                let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
                let newList = [1,2,4,6,8].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),3),Pos(M("8",8),4)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
                
            }
            
            it("should return the correct tuple when everything's removed : [1,2,4,6,8] -> []") {
                let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: [], sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),3),Pos(M("8",8),4)])
                expect(Set(updated.map { Pos($0) })) == Set([])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
                
            }
            
            it("should return the correct tuple when inserted 5 : ([1,2,4,6,8] -> [1,2,4,5,6,8]") {
                let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
                let newList = [1,2,4,5,6,8].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo( newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("5",5),3)])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),4),Pos(M("8",8),5)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            it("should return the correct tuple when deleted 2 : ([1,2,4,5,6,8] -> [1,4,5,6,8]") {
                let oldList = [1,2,4,5,6,8].map { M("\($0)",$0) }
                let newList = [1,4,5,6,8].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("2",2),1)])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("4",4),1),Pos(M("5",5),2),Pos(M("6",6),3),Pos(M("8",8),4)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            it("should return the correct tuple when deleted 1,4 : ([1,4,5,6,8] -> [5,6,8]") {
                let oldList = [1,4,5,6,8].map { M("\($0)",$0) }
                let newList = [5,6,8].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("4",4),1)])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("5",5),0),Pos(M("6",6),1),Pos(M("8",8),2)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            it("should return the correct tuple when inserted 7,9 : ([5,6,8] -> [5,6,7,8,9]") {
                let oldList = [5,6,8].map { M("\($0)",$0) }
                let newList = [5,6,7,8,9].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) } )) == Set([Pos(M("7",7),2),Pos(M("9",9),4)])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("5",5),0),Pos(M("6",6),1),Pos(M("8",8),3)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            it("should return the correct tuple when moved 8 to first position: ([5,6,7,8,9] -> [8,5,6,7,9]") {
                let oldList = [5,6,7,8,9].map { M("\($0)",$0) }
                let newList =  [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("5",5),1),Pos(M("6",6),2),Pos(M("7",7),3),Pos(M("9",9),4)])
                expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("8",0),3,0)])
            }
            it("should return the correct tuple when moved 7 to 2nd position: ([5,6,7,8,9] -> [8,5,6,7,9]") {
                let oldList = [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
                let newList =  [M("8",0),M("7",1),M("5",5),M("6",6),M("9",9)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("8",0),0),Pos(M("5",5),2),Pos(M("6",6),3),Pos(M("9",9),4)])
                expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("7",1),3,1)])
            }
            
            it("should return the correct tuple when moved 5 to the end plus 2 new inserts: ([1,5] -> [3,1,2,5]") {
                let oldList = [1,5].map { M("\($0)",$0) }
                let newList =  [M("1",1),M("2",2),M("3",3),M("5",5)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("2",2),1),Pos(M("3",3),2)])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("5",5),3)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            it("should return the correct tuple when moving 1 to next pos and inserting 2: ([1,3,5] -> [3,1,2,5]") {
                let oldList = [1,3,5].map { M("\($0)",$0) }
                let newList =  [M("3",0),M("1",1),M("2",2),M("5",5)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("2",2),2)])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),1),Pos(M("5",5),3)])
                expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("3",0),1,0)])
            }
            it("should return the correct tuple when deleting 1  and inserting 2: ([1,3,5] -> [3,2,5]") {
                let oldList = [1,3,5].map { M("\($0)",$0) }
                let newList =  [M("3",0),M("2",2),M("5",5)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("2",2),1)])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0)])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("3",0),0),Pos(M("5",5),2)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            it("should return the correct tuple when deleting 1: ([1,3,5] -> [3,5]") {
                let oldList = [1,3,5].map { M("\($0)",$0) }
                let newList =  [3,5].map { M("\($0)",$0) }
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0)])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("3",3),0),Pos(M("5",5),1)])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
            it("should return the correct tuple when deleting 1 and moving 5 to first pos: ([1,3,5] -> [5,3]") {
                let oldList = [1,3,5].map { M("\($0)",$0) }
                let newList =  [M("5",0),M("3",1)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0)])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("3",1),1)])
                expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("5",0),2,0)])
            }
            
            it("should return the correct tuple when deleting 5 and moving 1 to last pos: ([1,3,5] -> [3,1]") {
                let oldList = [1,3,5].map { M("\($0)",$0) }
                let newList =  [M("3",0),M("1",2)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("5",5),2)])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",2),1)])
                expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("3",0),1,0)])
            }
            it("should return the correct tuple when deleting 3 and moving 5 to first pos: ([1,3,5] -> [5,1]") {
                let oldList = [1,3,5].map { M("\($0)",$0) }
                let newList =  [M("5",0),M("1",2)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("3",3),1)])
                expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",2),1)])
                expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("5",0),2,0)])
            }
            
            it("should handle invalid / non unique lists gracefully") {
                let oldList = [1,2,3,4,5].map { M("\($0)",$0) }
                let newList = [M("1",0),M("1",1),M("2",2),M("3",3),M("4",4),M("5",5)]
                let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
                expect(Set(inserted.map { Pos($0) })) == Set([])
                expect(Set(deleted.map { Pos($0) })) == Set([])
                expect(Set(updated.map { Pos($0) })) == Set([])
                expect(Set(moved.map { MovedPos($0) })) == Set([])
            }
        }
        
        context("when testing mergeELements") {
            it ("sould merge correctly when inserting items at the end") {
                let list = ["1","2","3"]
                let indexedList = [("4",3)]
                let newList = try! list.mergeELements(with: indexedList)
                expect(newList) == ["1","2","3","4"]

            }
            
            it ("sould merge correctly when inserting items at the beginning") {
                let list = ["1","2","3"]
                let indexedList = [("0",0)]
                let newList = try! list.mergeELements(with: indexedList)
                expect(newList) == ["0","1","2","3"]
                
            }
            
            it ("sould merge correctly when inserting items in the middle") {
                let list = ["10","20","30"]
                let indexedList = [("15",1)]
                let newList = try! list.mergeELements(with: indexedList)
                expect(newList) == ["10","15","20","30"]
                
            }
            
            it ("sould merge correctly when inserting multiple items") {
                let list = ["10","20","30"]
                let indexedList = [("9",0),("12",2),("21",4),("35",6)]
                let newList = try! list.mergeELements(with: indexedList)
                expect(newList) == ["9","10","12","20","21","30","35"]
                
            }
            
            it ("sould merge correctly when inserting 0 items") {
                let list = ["10","20","30"]
                let newList = try! list.mergeELements(with: [])
                expect(newList) == list
                
            }
            
            it ("should throw if index out of range") {
                let list = ["10","20","30"]
                expect { try list.mergeELements(with: [("40",10)]) }.to(throwError(CollectionError.mergeIndexOutOfRange))
                
            }
        }
        

    }
}
