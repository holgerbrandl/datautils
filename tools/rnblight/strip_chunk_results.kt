#!/usr/bin/env kscript

//@file:DependsOn()

import java.io.File


val kotlin.Boolean.int get() = if (this) 1 else 0

enum class TripleType { start, end }

fun main(args: Array<String>) {

    //val mdFile = File(args[0])
    val lines = File("example.md").readLines()


    //    val lines = mdFile.readLines().take(50)

//    val lines = """
//        foo
//        ```bash
//        ls
//        ```
//
//        bla bla
//        ```r
//        ```
//        more blabla
//
//        """.trimIndent().lines()

    data class CodeChunk(val start: Int, val end: Int) {

        val isResult = lines
            .withIndex()
            .filter { it.index in start..end }
            .map { it.value }
            .drop(1)
            .dropLast(1)
            .all { it.startsWith("##") }
    }

    // 1. remove result chunks
    val resultLines = lines
        .withIndex()
        .filter { it.value.startsWith("```") }
        .windowed(2)
        .map { CodeChunk(it.first().index, it.last().index) }
        .filter { it.isResult }
        .flatMap { it.start..it.end }

    // remove all result chunks
    var filtMD = lines.filterIndexed{ idx, line -> !resultLines.contains(idx)}


    // also remove figures
    filtMD = filtMD.filter { !it.contains("figure/") }

    println("filtered nb is")
    println(filtMD.joinToString("\n"))



    // 2. join code chunks of same type if there's just empty space inbetween
    File("example_filt.md").writeText(filtMD.joinToString("\n"))
}

