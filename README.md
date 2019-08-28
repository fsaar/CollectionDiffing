![](https://img.shields.io/badge/Swift-5-orange.svg)
[![Travis Build Status](https://api.travis-ci.org/fsaar/CollectionDiffing.svg?branch=master)](https://travis-ci.org/fsaar/CollectionDiffing) 

# Collection Diffing

A sample demo and dummy mac app to provide an implementation for my custom collection diffing algorithm I talk about in my [blog](https://www.allaboutswift.com).
I could have created a framework for this but decided instead to do it with this quick and dirty approach due to Swift 5's support for Collection Diffing. 

## How does it work

Since collection diffing should be available to any *Collection*, the implementation extends *Collection*. The basic idea for the interface is to provide the steps of how to transform an old List A into a new List A'. These steps can be divided into

- insertions
- deletions
- updates and
- moves

An updated element is any element that is not inserted, deleted or moved. If there’s no interest in potential updates, it can of course be ignored. By the way, it’s potential updates since the algorithm is based on unique identifiers and hence there is no definite way to know if this is an actual update for the respective data model or not. Nonetheless, it's nice to have theses potential candidates handy. 
The algorithm takes advantage of basic *Set* function to categorise each element. For this reason, all *Collection* elements need to conform to the *Hashable* protocol.


Putting is all together, the result is the following declaration:

~~~
extension Collection where Element : Hashable {
        
    func transformTo(newList : [Element])  -> (inserted :[(element:Element,index:Int)],
   											 deleted : [(element:Element,index:Int)],
    										 updated : [(element:Element,index:Int)],
    										 moved : [(element:Element,oldIndex:Int,newIndex:Int)])
}
~~~

## The implementation
### Inserted and deleted Elements

Insertions can be determined by removing all elements in the old List from the new List i.e. in Swift using *Set* methods it looks like this:

~~~
	let insertedSet = newSet.subtracting(oldSet)
~~~
Vice versa, all deleted elements in the new List can be determined by removing all the elements in the new list from the old list:

~~~
	let deletedSet = oldSet.subtracting(newSet)
~~~

With those 2 sets in place, it's time to determine moved elements.

### Moved Elements

The basic idea on how to identify moved elements is to gradually convert the old list to the new list:

1. delete removed elements from old list results in *reducedOldList*
2. order the elements in *reducedOldList* in the order they appear in the new list, which results in *updatedList*
3. add new elements to *updatedList* to get *unsortedNewList*
4. compare elements in *unsortedNewList* and new list to determine *movedElementList*
5. reduce *movedElementList* by transforming *unsortedNewList* into new list by gradually performing moves from *movedElementList*. This last step is necessary to get the minimal amount of steps to transform old list into new list.

### Updated Elements

As mentioned above, having identified inserted, deleted and moved elements, the updated Set is defined by the elements that are not in any of theses lists.

## Conclusion

To see the algorithm in action check out [iOS app](https://apps.apple.com/gb/app/bus-stops/id1177594684) in the Appstore which still uses this algorithm (up to version 1.3). The app visualises arriving buses for nearby bus stops in the London area.
To ensure correctness of the algorithm, I backed it up with 20+ tests that can also be found here. 


