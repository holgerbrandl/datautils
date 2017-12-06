import java.io.File

val kotlin.Boolean.int
    get() = if (this) 1 else 0

fun main(args: Array<String>) {

    //val mdFile = File(args[0])
    val mdFile = File("/Users/brandl/Dropbox/projects/datautils/R/rnblight/example.md")

    //
    //var chunkCounter = 0
    //var isInChunk = false
    //val filtMd = mdFile.readLines().groupBy{ line->
    //
    //    if(line.startsWith("```")) {
    //        chunkCounter++
    //        isInChunk = !isInChunk
    //    }
    //
    //    chunkCounter
    //}.filterNot { (_, group) ->
    //    group.filterNot{it.startsWith("```")}.all { it.startsWith("## ") }
    //}
    //
    //File("result.md").writeText( filtMd.flatMap { it.value }.joinToString("\n"))


    fun <T : Number> List<T>.cumSum(removeNA: Boolean = false): Iterable<Double> {
        return drop(1).fold(listOf(first().toDouble()), { list, curVal -> list + (list.last().toDouble() + curVal.toDouble()) })
    }

    val lines = mdFile.readLines().take(50)
    lines.map { it.startsWith("```").int }
    lines.map { it.startsWith("```").int }.windowed(2) { (a, b) -> if (a > b) a else b }
    lines.map { it.startsWith("```").int }.cumSum().zipWithNext { a, b -> a }
}
