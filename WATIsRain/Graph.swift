//: Playground - noun: a place where people can play

import UIKit
import MapKit

//
//  Graph.swift
//  WATIsRain
//
//  Created by Anish Chopra on 2015-06-21.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation
import MapKit

// This allows Vertex's to be comparable (needed for the Hashable protocol)
func ==(lhs: Vertex, rhs : Vertex) -> Bool{
    return lhs.location.latitude == rhs.location.latitude && lhs.location.longitude == rhs.location.longitude
}

class Vertex : Hashable {
    var location : CLLocationCoordinate2D // {latitude, longitude}
    var neighbours : Array<Edge>
    
    // This is needed for the Hashable protocol
    var hashValue : Int {
        get {
            return location.latitude.hashValue ^ location.longitude.hashValue
        }
    }
    
    init(location : CLLocationCoordinate2D) {
        self.location = location
        self.neighbours = []
    }
    
    // Returns the distance between self and v (basic Pythagorean theorem)
    func distance(v : Vertex) -> Double{
        let latDel = fabs(self.location.latitude - v.location.latitude)
        let longDel = fabs(self.location.longitude - v.location.longitude)
        return sqrt(pow(latDel, 2.0) + pow(longDel, 2.0))
    }
}

class Edge {
    var weight : Double
    var neighbour : Vertex
    var isIndoors : Bool
    
    init(distance : Double, neighbour : Vertex, isIndoors : Bool) {
        self.weight = distance
        self.neighbour = neighbour
        self.isIndoors = isIndoors
    }
}

class Graph {
    var canvas : Set<Vertex> // stores all vertices (which in turn, stores all edges)
    
    init() {
        self.canvas = []
    }
    
    func addVertex(v : Vertex) {
        self.canvas.insert(v)
    }
    
    func addEdge(source : Vertex, target : Vertex, isIndoors : Bool) {
        let edge = Edge(distance: source.distance(target), neighbour: target, isIndoors : isIndoors)
        source.neighbours.append(edge)
        
        // Every edge works in both directions
        let reverseEdge = Edge(distance: target.distance(source), neighbour: source, isIndoors : isIndoors)
        target.neighbours.append(reverseEdge)
    }
    
    func shortestPath(source : Vertex, target : Vertex, indoors : Bool) -> Path?{
        var weight = [Vertex : Double]() // weight[v] is the total weight from source to v
        var prev = [Vertex : Vertex?]() // prev[v] is the Vertex in the path before v
        var unvisited = Set<Vertex>() // the set of all Vertex's not visited by the algorithm
        
        // Set the total weight for each node from the source to infinity (except for the source, which is 0)
        // Also insert every node into the unvisited set
        for v in self.canvas {
            if (v == source) {
                weight[v] = 0
            }
            else {
                weight[v] = -1 // to represent infinity
            }
            prev[v] = nil
            unvisited.insert(v)
        }
        
        while unvisited.count != 0 {
            var u : Vertex = source // I have to set this to something
            var minDist : Double = -1
            
            // Set Vertex u to some node v with the minimum weight[v]
            // This will be set to the source Vertex for the first iteration
            for v in unvisited {
                if weight[v] >= 0 {
                    if ((minDist == -1) || (weight[v] < minDist)) {
                        minDist = weight[v]!
                        u = v // this is guaranteed to happen at least once
                    }
                }
            }
            
            // If the target node has been found, return the shortest path
            if (u == target) {
                var p = Path(dest: target)
                while (prev[u] != nil) {
                    u = (prev[u])!!
                    var newP : Path = Path(dest: u)
                    newP.next = p
                    p = newP
                }
                return p
            }
            
            unvisited.remove(u)
            
            // Set weight[v] and prev[v] for every neighbour v of u
            for e in u.neighbours {
                if (unvisited.contains(e.neighbour)) {
                    var alt = weight[u]! + e.weight
                    if (weight[e.neighbour] == -1 || alt < weight[e.neighbour]) {
                        weight[e.neighbour] = alt
                        prev[e.neighbour] = u
                    }
                }
            }
        }
        
        // If the target node cannot be found, return nil
        return nil
        
    }
}


// A Path is a linked list, and each Path structure contains a Vertex
class Path {
    var total : Double
    var destination : Vertex
    var next : Path!
    
    init(dest : Vertex) {
        self.total = 0
        self.destination = dest
    }
    
}

/* Sample graph:

var a = Vertex(location: CLLocationCoordinate2D(latitude: 0, longitude: 0))
var b = Vertex(location: CLLocationCoordinate2D(latitude: 0, longitude: 1))
var c = Vertex(location: CLLocationCoordinate2D(latitude: 2, longitude: 0))
var d = Vertex(location: CLLocationCoordinate2D(latitude: 3, longitude: 3))
var e = Vertex(location: CLLocationCoordinate2D(latitude: 0, longitude: 3))

var g = Graph()

g.addVertex(a)
g.addVertex(b)
g.addVertex(c)
g.addVertex(d)
g.addVertex(e)

g.addEdge(a, target: c, isIndoors: false)
g.addEdge(c, target: d, isIndoors: false)
g.addEdge(a, target: b,isIndoors:  false)
g.addEdge(b, target: e, isIndoors: false)
g.addEdge(e, target: d, isIndoors: false)

var p = g.shortestPath(a, target: d, indoors: true)

The path p will represent a path from a->c->d
*/
