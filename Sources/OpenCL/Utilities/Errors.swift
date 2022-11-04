//
//  Errors.swift
//
//
//  Created by Philip Turner on 11/4/22.
//

import Foundation

// Internal function for placeholders.
func notImplementedError(
  function: StaticString = #function, file: StaticString = #file,
  line: UInt = #line
) -> Never {
  fatalError("\(function) not implemented.", file: file, line: line)
}
