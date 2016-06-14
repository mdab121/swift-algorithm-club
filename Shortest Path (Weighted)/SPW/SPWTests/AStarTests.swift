//
//  AStarTests.swift
//  SPW
//
//  Created by Kajetan Dąbrowski on 10/06/16.
//
//

import Graph
import XCTest
@testable import SPW

class VisitableString: StringLiteralConvertible, Visitable, Hashable, Equatable, CustomDebugStringConvertible {
	let innerString: String
	var visited: Bool = false

	required init(stringLiteral value: StringLiteralType) {
		innerString = String(stringLiteral: value)
	}

	required init(unicodeScalarLiteral value: String.UnicodeScalarLiteralType) {
		innerString = String(unicodeScalarLiteral: value)
	}

	func visit() {
		visited = true
	}

	required init(extendedGraphemeClusterLiteral value: String.ExtendedGraphemeClusterLiteralType) {
		innerString = String(extendedGraphemeClusterLiteral: value)
	}

	var hashValue: Int {
		return innerString.hashValue
	}

	var debugDescription: String {
		return innerString.debugDescription
	}
}

func == (lhs: VisitableString, rhs: VisitableString) -> Bool {
	return lhs.innerString == rhs.innerString
}


class AStartTests: XCTestCase {


	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testSimpleUndirectedExample() {
		let graph = AdjacencyMatrixGraph<VisitableString>()
		let s = graph.createVertex("s")
		let g = graph.createVertex("g")

		graph.addUndirectedEdge((s, g), withWeight: 10.0)

		let result = AStar<VisitableString>.apply(graph, start: s, goal: g, heuristicDistance: {(_,_) -> Double in return 1.0})
		XCTAssertNotNil(result)

		let expectedPath: [VisitableString] = ["s", "g"]
		XCTAssertNotNil(result?.path)

		XCTAssertEqual(expectedPath, result!.path!)

		let expectedDistance: Double? = 10.0
		XCTAssertNotNil(result?.distance)
		XCTAssertEqual(result?.distance, expectedDistance)

		XCTAssertTrue(s.data.visited)
		XCTAssertTrue(g.data.visited)
	}

	func testSimpleDirectedExample() {
		let graph = AdjacencyMatrixGraph<VisitableString>()
		let s = graph.createVertex("s")
		let g = graph.createVertex("g")

		graph.addDirectedEdge(s, to: g, withWeight: 10.0)

		let result = AStar<VisitableString>.apply(graph, start: s, goal: g, heuristicDistance: {(_,_) -> Double in return 1.0})
		XCTAssertNotNil(result)

		let expectedPath: [VisitableString] = ["s", "g"]
		XCTAssertNotNil(result?.path)
		XCTAssertEqual(expectedPath, result!.path!)

		let expectedDistance: Double? = 10.0
		XCTAssertNotNil(result?.distance)
		XCTAssertEqual(result?.distance, expectedDistance)

		XCTAssertTrue(s.data.visited)
		XCTAssertTrue(g.data.visited)
	}

	func testSimpleGraphWithNoPath() {
		let graph = AdjacencyMatrixGraph<VisitableString>()
		let s = graph.createVertex("s")
		let g = graph.createVertex("g")

		graph.addDirectedEdge(g, to: s, withWeight: 10.0)

		let result = AStar<VisitableString>.apply(graph, start: s, goal: g, heuristicDistance: {(_,_) -> Double in return 1.0})
		XCTAssertNil(result)

		XCTAssertTrue(s.data.visited)
		XCTAssertFalse(g.data.visited)
	}

	func testWikipediaExample() {
		let graph = AdjacencyMatrixGraph<VisitableString>()
		let start = graph.createVertex("start")
		let a = graph.createVertex("a")
		let b = graph.createVertex("b")
		let c = graph.createVertex("c")
		let d = graph.createVertex("d")
		let e = graph.createVertex("e")
		let goal = graph.createVertex("goal")
		let away = graph.createVertex("away")

		graph.addUndirectedEdge((start,d), withWeight: 2.0)
		graph.addUndirectedEdge((d,e), withWeight: 3.0)
		graph.addUndirectedEdge((e,goal), withWeight: 2.0)

		graph.addUndirectedEdge((start,a), withWeight: 1.5)
		graph.addUndirectedEdge((a,b), withWeight: 2.0)
		graph.addUndirectedEdge((b,c), withWeight: 3.0)
		graph.addUndirectedEdge((c,goal), withWeight: 4.0)

		graph.addUndirectedEdge((away, goal), withWeight: 10.0)

		let expectedPath: [VisitableString] = ["start", "d", "e", "goal"]
		let expectedDistance: Double? = 7.0

		let result = AStar<VisitableString>.apply(graph, start: start, goal: goal, heuristicDistance: {(_,_) -> Double in return 1.0})
		XCTAssertNotNil(result)
		XCTAssertNotNil(result?.distance)
		XCTAssertNotNil(result?.path)
		XCTAssertEqual(result?.distance, expectedDistance)
		XCTAssertEqual(result!.path!, expectedPath)

		XCTAssertTrue(start.data.visited)
		XCTAssertTrue(a.data.visited)
		XCTAssertTrue(b.data.visited)
		XCTAssertTrue(c.data.visited)
		XCTAssertTrue(d.data.visited)
		XCTAssertTrue(e.data.visited)
		XCTAssertTrue(goal.data.visited)
		XCTAssertFalse(away.data.visited)

	}

  func testBigMatrixGraphPerformace() {
    let graph = AdjacencyMatrixGraph<Int>()
    var vertices: [Vertex<Int>] = []
    let edgesCount = 1000
    let edgeWeight = 10.0
    for i in 0..<edgesCount {
      vertices.append(graph.createVertex(i))
    }

    for i in 0..<edgesCount-1 {
      graph.addUndirectedEdge((vertices[i], vertices[i+1]), withWeight: edgeWeight)
    }

    measureBlock() {
      AStar<Int>.apply(graph, start: vertices.first!, goal: vertices.last!, heuristicDistance: {(_,_) -> Double in return 10.0})
    }

    let result = AStar<Int>.apply(graph, start: vertices.first!, goal: vertices.last!, heuristicDistance: {(_,_) -> Double in return edgeWeight})
    XCTAssertEqual(result?.distance, Double(edgesCount-1) * edgeWeight)
    XCTAssertEqual(result!.path!, vertices.map {return $0.data })
  }

  func testBigListGraphPerformace() {
    let graph = AdjacencyListGraph<Int>()
    var vertices: [Vertex<Int>] = []
    let edgesCount = 1000
    let edgeWeight = 10.0
    for i in 0..<edgesCount {
      vertices.append(graph.createVertex(i))
    }

    for i in 0..<edgesCount-1 {
      graph.addUndirectedEdge((vertices[i], vertices[i+1]), withWeight: edgeWeight)
    }

    measureBlock() {
      AStar<Int>.apply(graph, start: vertices.first!, goal: vertices.last!, heuristicDistance: {(_,_) -> Double in return 10.0})
    }

    let result = AStar<Int>.apply(graph, start: vertices.first!, goal: vertices.last!, heuristicDistance: {(_,_) -> Double in return edgeWeight})
    XCTAssertEqual(result?.distance, Double(edgesCount-1) * edgeWeight)
    XCTAssertEqual(result!.path!, vertices.map {return $0.data })
  }

}