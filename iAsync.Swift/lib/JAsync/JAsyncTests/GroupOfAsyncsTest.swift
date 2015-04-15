//
//  GroupOfAsyncsTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 20.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

//1. Test normal finish direct order
//2. Test normal finish reverse order order
//3. Test normal finish direct order (first  immediately result)
//4. Test normal finish direct order (second immediately result)
//5. Test normal finish direct order (both   immediately result)

//Errors
//6. Test first  loader error (sesond not error)
//7. Test second loader error (first  not error)
//8. Test both loaders errors

//9 . Test first loader error (sesond not error) - error  immediately
//10. Test first loader error (sesond not error) - result immediately
//11. Test first loader error (sesond not error) - both   immediately

//12. Test second loader error (first not error) - error  immediately
//13. Test second loader error (first not error) - result immediately
//14. Test second loader error (first not error) - both   immediately

//15. Test both loaders errors - first  error immediately
//16. Test both loaders errors - second error immediately
//17. Test both loaders errors - both   error immediately

//Cancel && Unsubscribe

//Cancel all
//18. both not loaded
//19. first  loaded with result before

class GroupOfAsyncsTest: XCTestCase {
    
    //Finish
    //1. Test normal finish direct order
    func testNormalFinishDirectOrder()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupResult: [Int]?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onValue { groupResult = $0 }
            })
            
            XCTAssertFalse(firstLoader.finished , "First loader not finished yet" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            firstLoader.loaderFinishBlock!(result: JResult.value(1))
            
            XCTAssertFalse(secondLoader.finished, "Second loader finished already")
            XCTAssertTrue (firstLoader.finished , "First loader not finished yet" )
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            secondLoader.loaderFinishBlock!(result: JResult.value(2))
            
            cancel(task: .Cancel)
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertEqual(groupResult!, [1, 2], "Group loader finished already")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //2. Test normal finish reverse order order
    func testNormalFinishReverseOrder()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupResult: NSObject?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onValue { groupResult = $0 }
            })
            
            XCTAssertFalse(firstLoader.finished , "First loader not finished yet" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            secondLoader.loaderFinishBlock!(result: JResult.value(2))
            
            XCTAssertTrue (secondLoader.finished, "Second loader finished already")
            XCTAssertFalse(firstLoader.finished , "First loader not finished yet" )
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            firstLoader.loaderFinishBlock!(result: JResult.value(1))
            
            cancel(task: .UnSubscribe)
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertEqual(groupResult!, [1, 2], "Group loader finished already")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //3. Test normal finish direct order (first  immediately result)
    func testNormalFinishDirectOrder_firstImmediatelyResult()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            firstLoader.finishAtLoadingResult = 1
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupResult: NSObject?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onValue { groupResult = $0 }
            })
            
            XCTAssertFalse(secondLoader.finished, "Second loader finished already")
            XCTAssertTrue (firstLoader.finished , "First loader not finished yet" )
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            secondLoader.loaderFinishBlock!(result: JResult.value(2))
            
            cancel(task: .Cancel)
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertEqual(groupResult!, [1, 2], "Group loader finished already")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //4. Test normal finish direct order (second immediately result)
    func testNormalFinishDirectOrder_secondImmediatelyResult()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            secondLoader.finishAtLoadingResult = 2
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupResult: NSObject?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onValue { groupResult = $0 }
            })
            
            XCTAssertTrue (secondLoader.finished, "Second loader finished already")
            XCTAssertFalse(firstLoader.finished , "First loader not finished yet" )
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            firstLoader.loaderFinishBlock!(result: JResult.value(1))
            
            cancel(task: .UnSubscribe)
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertEqual(groupResult!, [1, 2], "Group loader finished already")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //5. Test normal finish direct order (both   immediately result)
    func testNormalFinishDirectOrder_bothImmediatelyResult()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            firstLoader.finishAtLoadingResult  = 1
            secondLoader.finishAtLoadingResult = 2
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupResult: NSObject?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onValue { groupResult = $0 }
            })
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertEqual(groupResult!, [1, 2], "Group loader finished already")
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //Errors
    //6. Test first loader error (second not error)
    func testFirstLoaderError_secondNotError()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertFalse(firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            let testError = JError(description: "some test error")
            firstLoader.loaderFinishBlock!(result: JResult.error(testError))
            
            XCTAssertTrue (firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            //finish next
            
            secondLoader.loaderFinishBlock!(result: JResult.value(1))
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            XCTAssertTrue (secondLoader.finished, "Second loader not finished yet")
            
            cancel(task: .UnSubscribe)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //7. Test second loader error (first  not error)
    func testSecondLoaderError_firstNotError()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertFalse(firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            let testError = JError(description: "some test error")
            secondLoader.loaderFinishBlock!(result: JResult.error(testError))
            
            XCTAssertFalse(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue (secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            //finish next
            
            firstLoader.loaderFinishBlock!(result: JResult.value(1))
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            XCTAssertTrue (firstLoader.finished, "Second loader not finished yet")
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //8. Test both loaders errors
    func testBothLoadersErrors()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertFalse(firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            let testError1 = JError(description: "some test error 1")
            secondLoader.loaderFinishBlock!(result: JResult.error(testError1))
            
            XCTAssertFalse(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue (secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError1, groupError!, "Group loader finished already")
            
            //finish next
            
            let testError2 = JError(description: "some test error 2")
            firstLoader.loaderFinishBlock!(result: JResult.error(testError2))
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            XCTAssertTrue (firstLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError1, groupError!, "Group loader finished already")
            
            cancel(task: .UnSubscribe)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //9. Test first loader error (sesond not error) - error  immediately
    func testFirstLoaderError_secondNotError_errorImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let testError = JError(description: "some test error")
            firstLoader.failAtLoadingError = testError
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertTrue (firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            //finish next
            
            secondLoader.loaderFinishBlock!(result: JResult.value(1))
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            XCTAssertTrue (secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //10. Test first loader error (sesond not error) - result immediately
    func testFirstLoaderError_secondNotError_resultImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            //let testError = JError(description: "some test error")
            //firstLoader.failAtLoadingError = testError
            secondLoader.finishAtLoadingResult = 1
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertFalse(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue (secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            let testError = JError(description: "some test error")
            firstLoader.loaderFinishBlock!(result: JResult.error(testError))
            
            XCTAssertTrue (firstLoader.finished , "First loader finished already" )
            XCTAssertTrue (secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            //finish next
            
            cancel(task: .UnSubscribe)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //11. Test first loader error (sesond not error) - both   immediately
    func testFirstLoaderError_secondNotError_bothImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let testError = JError(description: "some test error")
            firstLoader.failAtLoadingError = testError
            secondLoader.finishAtLoadingResult = 1
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            //finish next
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //12. Test second loader error (first not error) - error  immediately
    func RtestSecondLoaderError_firstNotError_errorImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let testError = JError(description: "some test error")
            secondLoader.failAtLoadingError = testError
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertFalse(secondLoader.finished , "First loader finished already" )
            XCTAssertTrue (firstLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            //finish next
            
            firstLoader.loaderFinishBlock!(result: JResult.value(1))
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            XCTAssertTrue(firstLoader.finished , "Second loader not finished yet")
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            cancel(task: .UnSubscribe)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //13. Test second loader error (first not error) - result immediately
    func testSecondLoaderError_firstNotError_resultImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            //let testError = JError(description: "some test error")
            firstLoader.finishAtLoadingResult = 1
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertTrue (firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            let testError = JError(description: "some test error")
            secondLoader.loaderFinishBlock!(result: JResult.error(testError))
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //14. Test second loader error (first not error) - both   immediately
    func testSecondLoaderError_firstNotError_bothImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            //let testError = JError(description: "some test error")
            let testError = JError(description: "some test error")
            secondLoader.failAtLoadingError = testError
            firstLoader.finishAtLoadingResult = 1
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            cancel(task: .UnSubscribe)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //15. Test both loaders errors - first  error immediately
    func testBothLoadersErrors_firstErrorImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let testError1 = JError(description: "some test error")
            firstLoader.failAtLoadingError = testError1
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already"  )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError1, groupError!, "Group loader finished already")
            
            let testError2 = JError(description: "some test error")
            secondLoader.loaderFinishBlock!(result: JResult.error(testError2))
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError1, groupError!, "Group loader finished already")
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //16. Test both loaders errors - second error immediately
    func testBothLoadersErrors_secondErrorImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let testError1 = JError(description: "some test error")
            secondLoader.failAtLoadingError = testError1
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertTrue (secondLoader.finished , "First loader finished already"  )
            XCTAssertFalse(firstLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError1, groupError!, "Group loader finished already")
            
            let testError2 = JError(description: "some test error")
            firstLoader.loaderFinishBlock!(result: JResult.error(testError2))
            
            XCTAssertTrue(firstLoader.finished , "First loader finished already" )
            XCTAssertTrue(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError1, groupError!, "Group loader finished already")
            
            cancel(task: .UnSubscribe)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //17. Test both loaders errors - both   error immediately
    func testBothLoadersErrors_bothErrorImmediately()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let testError = JError(description: "some test error")
            firstLoader.failAtLoadingError  = testError
            secondLoader.failAtLoadingError = testError
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertTrue(secondLoader.finished, "First loader finished already" )
            XCTAssertTrue(firstLoader.finished , "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(testError, groupError!, "Group loader finished already")
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //Cancel && Unsubscribe
    
    //Cancel all
    //18. cancel all - both not loaded
    func testCancelAll_bothNotLoaded()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            cancel(task: .Cancel)
            
            XCTAssertTrue(firstLoader.canceled , "Second loader not finished yet")
            XCTAssertTrue(secondLoader.canceled, "First loader finished already" )
            XCTAssertEqual(.Cancel, firstLoader.lastHandleFlag , "Second loader not finished yet")
            XCTAssertEqual(.Cancel, secondLoader.lastHandleFlag, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"        )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(JAsyncFinishedByCancellationError(), groupError!, "Group loader finished already")
            
            cancel(task: .UnSubscribe)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    //19. cancel all - first  loaded with result before
    func testCancelAll_firstLoadedWithResultBefore()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var groupError: NSError?
            var callsCount = 0
            
            let loader = groupOfAsyncsArray([firstLoader.loader, secondLoader.loader])
            
            let cancel = loader(nil, nil, { (result: JResult<[Int]>) -> () in
                
                ++callsCount
                result.onError { groupError = $0 }
            })
            
            XCTAssertFalse(firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNil(groupError, "Group loader finished already")
            
            firstLoader.loaderFinishBlock!(result: JResult.value(1))
            
            XCTAssertTrue (firstLoader.finished , "First loader finished already" )
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertEqual(0, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNil(groupError, "Group loader finished already")
            
            cancel(task: .Cancel)
            
            XCTAssertFalse(firstLoader.canceled , "Second loader not finished yet")
            XCTAssertTrue (secondLoader.canceled, "First loader finished already" )
            XCTAssertEqual(.Cancel, secondLoader.lastHandleFlag, "Second loader not finished yet")
            XCTAssertEqual(1, callsCount, "Group loader not finished yet"         )
            
            XCTAssertNotNil(groupError, "Group loader finished already")
            XCTAssertEqual(JAsyncFinishedByCancellationError(), groupError!, "Group loader finished already")
            
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, callsCount, "Group loader not finished yet")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
}
