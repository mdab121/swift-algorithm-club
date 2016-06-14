//
//  SPW.swift
//  SPW
//
//  Created by Kajetan Dąbrowski on 10/06/16.
//
//

import Foundation
import Graph

protocol SPWAlgorithm {
  associatedtype Q: Equatable, Hashable
  associatedtype P: SPWResult

  static func apply(graph: AbstractGraph<Q>, start: Vertex<Q>, goal: Vertex<Q>, heuristicDistance: ((Q,Q)->Double)) -> P?
}

protocol SPWResult {
  associatedtype T: Equatable, Hashable

  var distance: Double? { get }
  var path: [T]? { get }
}