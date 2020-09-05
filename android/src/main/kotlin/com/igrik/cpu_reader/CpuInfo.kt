package com.igrik.cpu_reader

/**
 * POKO data object that encapsulates the CPU information
 */
data class CpuInfo(val abi: String,
                   val numberOfCores: Int,
                   val currentFrequencies: MutableMap<Int, Long>,
                   val minMaxFrequencies: MutableMap<Int, Pair<Long, Long>>,
                   val cpuTemperature: Double
                   )