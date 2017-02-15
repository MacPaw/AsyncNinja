//
//  Copyright (c) 2016-2017 Anton Mironov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom
//  the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Dispatch

/// A future that has been initialized as completed
final class ConstantFuture<Success>: Future<Success> {
  private var _completion: Fallible<Success>
  override public var completion: Fallible<Success>? { return _completion }
  let releasePool = ReleasePool()

  init(completion: Fallible<Success>) {
    _completion = completion
  }

  override public func makeCompletionHandler(executor: Executor,
                                             block: @escaping (Fallible<Success>) -> Void
    ) -> CompletionHandler? {
    executor.execute { block(self._completion) }
    return nil
  }
  
  override func insertToReleasePool(_ releasable: Releasable) {
    /* do nothing because future was created as complete */
  }
}

/// Makes completed future
///
/// - Parameter value: value to complete future with
/// - Returns: completed future
public func future<Success>(value: Fallible<Success>) -> Future<Success> {
  return ConstantFuture(completion: value)
}

/// Makes completed future
///
/// - Parameter completion: value to complete future with
/// - Returns: completed future
public func future<Success>(completion: Fallible<Success>) -> Future<Success> {
  return ConstantFuture(completion: completion)
}

/// Makes succeeded future
///
/// - Parameter success: success value to complete future with
/// - Returns: succeeded future
public func future<Success>(success: Success) -> Future<Success> {
  return ConstantFuture(completion: Fallible(success: success))
}

/// Makes failed future
///
/// - Parameter failure: failure value (Error) to complete future with
/// - Returns: failed future
public func future<Success>(failure: Swift.Error) -> Future<Success> {
  return ConstantFuture(completion: Fallible(failure: failure))
}

/// Makes cancelled future (shorthand to `future(failure: AsyncNinjaError.cancelled)`)
///
/// - Returns: cancelled future
public func cancelledFuture<Success>() -> Future<Success> {
    return future(failure: AsyncNinjaError.cancelled)
}

// **internal use only**
func makeFutureOrWrapError<Success>(_ block: () throws -> Future<Success>) -> Future<Success> {
  do { return try block() }
  catch { return future(failure: error) }
}

// **internal use only**
func makeFutureOrWrapError<Success>(_ block: () throws -> Future<Success>?) -> Future<Success>? {
  do { return try block() }
  catch { return future(failure: error) }
}
