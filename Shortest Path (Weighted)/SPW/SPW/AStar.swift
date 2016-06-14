//
//  AStar.swift
//  SPW
//
//  Created by Kajetan Dąbrowski on 10/06/16.
//
//

import Foundation
import Graph

public protocol Visitable {
  func visit()
}

public struct AStar<T where T: Hashable> {
  typealias V = Vertex<T>
}

extension AStar: SPWAlgorithm {
  static func apply(graph: AbstractGraph<T>, start: Vertex<T>, goal: Vertex<T>, heuristicDistance: ((T,T) -> Double)) -> AStarResult<T>? {

    var closedSet: Set<V> = Set<V>()
    var openSet: Set<V> = Set<V>(arrayLiteral: start)
    var cameFrom: [V:V] = [:]
    var gScore: [V: Double] = Dictionary<V, Double>()
    var fScore: [V: Double] = Dictionary<V, Double>()


    graph.vertices.forEach { (vertex) in
      gScore[vertex] = Double.infinity
      fScore[vertex] = Double.infinity
    }

    gScore[start] = 0.0
    fScore[start] = heuristicDistance(start.data, goal.data)

    while !openSet.isEmpty {
      guard let current = openSet.sort({return fScore[$0] < fScore[$1]}).first else { fatalError() }

      (current.data as? Visitable)?.visit()

      if current == goal {
        let path = reconstructPath(cameFrom, startCurrent: current)
        var distance: Double = 0.0
        for i in 0..<path.count-1 {
          let v0 = path[i]
          let v1 = path[i+1]
          distance += graph.weightFrom(v0, to: v1)!
        }
        return AStarResult(path: path, distance: distance)
      }
      openSet.remove(current)
      closedSet.insert(current)

      let edgesFromCurrent = graph.edgesFrom(current)

      for edge in edgesFromCurrent {
        let neighbour = edge.to
        if closedSet.contains(neighbour) { continue }
        let tenativeGScore = gScore[current]! + edge.weight!


        if !openSet.contains(neighbour) {
          openSet.insert(neighbour)
        } else if tenativeGScore >= gScore[neighbour] {
          continue
        }

        cameFrom[neighbour] = current
        fScore[neighbour] = tenativeGScore + heuristicDistance(neighbour.data, goal.data)
        gScore[neighbour] = tenativeGScore
      }
    }
    return nil
  }

  static private func reconstructPath(cameFrom: [V: V], startCurrent: V) -> [V] {
    var current = startCurrent
    var totalPath = [current]
    while cameFrom.keys.contains(current) {
      current = cameFrom[current]!
      totalPath.append(current)
    }
    return totalPath.reverse()
  }
}


public struct AStarResult<T where T: Hashable>: SPWResult {
  public private(set) var distance: Double?
  public private(set) var path: [T]?

  init(path: [Vertex<T>]?, distance: Double?) {
    self.path = path?.map {return $0.data}
    self.distance = distance
  }
}
